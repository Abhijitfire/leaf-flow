import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/services/supabase_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/models/attendance_model.dart';
import '../../../weighing/domain/models/worker_model.dart';
import '../../../tasks/domain/models/estate_plan_model.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  return AttendanceRepository(supabaseClient, db, syncService);
});

class AttendanceRepository {
  final dynamic supabaseClient;
  final AppDatabase db;
  final SyncService syncService;

  AttendanceRepository(this.supabaseClient, this.db, this.syncService);

  Future<List<Worker>> fetchWorkersByPlan(EstatePlanModel plan) async {
    try {
      if (plan.dafaId.isEmpty) {
        throw Exception('Plan dafaId is empty!');
      }
      
      // Attempt to sync from cloud (fail silently if offline)
      await syncService.syncWorkersDown();

      // Read from Local Drift DB
      final localData = await (db.select(db.localWorkers)..where((t) => t.dafaId.equals(plan.dafaId))).get();
      
      if (localData.isEmpty) {
        final totalWorkers = await db.select(db.localWorkers).get();
        final sampleDafas = totalWorkers.take(3).map((w) => w.dafaId).join(', ');
        throw Exception('0 workers found for Dafa [${plan.dafaId}]. Total workers: ${totalWorkers.length}. Sample dafaIds in local DB: [$sampleDafas]');
      }

      return localData.map((w) => Worker(
        id: w.pfNumber,
        name: w.fullName,
        dafaId: w.dafaId ?? '',
        phoneNumber: w.phoneNumber ?? '',
        dailyQuotaKg: w.dailyQuotaKg ?? 20.0,
      )).toList();
    } catch (e) {
      debugPrint('Error fetching workers from local DB: $e');
      throw Exception(e.toString()); // Propagate to UI for debugging
    }
  }

  Future<Worker?> searchWorker(String query) async {
    try {
      // First try local DB so Badli works offline
      final localWorker = await (db.select(db.localWorkers)
        ..where((t) => t.pfNumber.equals(query) | t.phoneNumber.equals(query))
        ..limit(1)
      ).getSingleOrNull();

      if (localWorker != null) {
        return Worker(
          id: localWorker.pfNumber,
          name: localWorker.fullName,
          dafaId: localWorker.dafaId ?? '',
          phoneNumber: localWorker.phoneNumber ?? '',
          dailyQuotaKg: localWorker.dailyQuotaKg ?? 20.0,
        );
      }

      // Fallback to Supabase if not found locally
      final data = await supabaseClient
          .from('workers')
          .select()
          .or('pf_number.eq.$query,phone_number.eq.$query')
          .maybeSingle();
      
      if (data == null) return null;
      return Worker.fromJson(data);
    } catch (e) {
      debugPrint('Error searching worker: $e');
      return null;
    }
  }

  Future<List<Worker>> searchWorkers(String query) async {
    if (query.isEmpty) return [];
    try {
      final localWorkers = await (db.select(db.localWorkers)
        ..where((t) => t.pfNumber.like('%$query%') | t.fullName.like('%$query%') | t.phoneNumber.like('%$query%'))
        ..limit(5)
      ).get();

      if (localWorkers.isNotEmpty) {
        return localWorkers.map((w) => Worker(
          id: w.pfNumber,
          name: w.fullName,
          dafaId: w.dafaId ?? '',
          phoneNumber: w.phoneNumber ?? '',
          dailyQuotaKg: w.dailyQuotaKg ?? 20.0,
        )).toList();
      }

      // Fallback to Supabase if not found locally
      final data = await supabaseClient
          .from('workers')
          .select()
          .or('pf_number.ilike.%$query%,full_name.ilike.%$query%,phone_number.ilike.%$query%')
          .limit(5);
      
      return (data as List).map((e) => Worker.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error searching workers: $e');
      return [];
    }
  }

  Future<void> submitAttendance(List<AttendanceModel> records) async {
    if (records.isEmpty) return;
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final workerIds = records.map((r) => r.workerId).toList();

      // Delete existing local records for these workers today for THIS plan to prevent duplicates
      final planId = records.first.planId;
      await (db.delete(db.localAttendance)
        ..where((t) => t.workerId.isIn(workerIds) & t.recordDate.isBetweenValues(todayStart, todayEnd) & t.planId.equals(planId))
      ).go();

      // Save locally first
      await db.batch((batch) {
        batch.insertAll(
          db.localAttendance,
          records.map((r) => LocalAttendanceCompanion.insert(
            planId: r.planId,
            workerId: r.workerId,
            recordDate: r.recordDate,
            isPresent: r.isPresent,
            isSynced: const drift.Value(false), // Mark as unsynced
          )),
        );
      });

      // Try to push to cloud immediately
      await syncService.syncAttendanceUp();
    } catch (e) {
      debugPrint('Error submitting attendance locally: $e');
      rethrow;
    }
  }

  Future<bool> isWorkerAbsentToday(String pfNumber, {String? planId}) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      // Check local DB first
      final localRecord = await (db.select(db.localAttendance)
        ..where((t) {
          var condition = t.workerId.equals(pfNumber) & t.recordDate.isBetweenValues(todayStart, todayEnd);
          if (planId != null) {
            condition = condition & t.planId.equals(planId);
          }
          return condition;
        })
        ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)])
        ..limit(1)
      ).getSingleOrNull();

      if (localRecord != null) {
        return !localRecord.isPresent;
      }

      // If not in local, check Supabase
      final todayDateString = todayStart.toIso8601String().split('T').first;
      var query = supabaseClient
          .from('attendance')
          .select('is_present')
          .eq('worker_id', pfNumber)
          .eq('record_date', todayDateString);
          
      if (planId != null) {
        query = query.eq('plan_id', planId);
      }
      
      final data = await query.maybeSingle();
          
      if (data == null) return false; // If no record, assume not marked absent yet
      return !(data['is_present'] as bool);
    } catch (e) {
      debugPrint('Error checking attendance: $e');
      return false; // Fail safe
    }
  }

  Future<bool> isWorkerPresentToday(String pfNumber, {String? planId}) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      // Check local DB first
      final localRecord = await (db.select(db.localAttendance)
        ..where((t) {
          var condition = t.workerId.equals(pfNumber) & t.recordDate.isBetweenValues(todayStart, todayEnd);
          if (planId != null) {
            condition = condition & t.planId.equals(planId);
          }
          return condition;
        })
        ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)])
        ..limit(1)
      ).getSingleOrNull();

      if (localRecord != null) {
        return localRecord.isPresent;
      }

      // If not in local, check Supabase
      final todayDateString = todayStart.toIso8601String().split('T').first;
      var query = supabaseClient
          .from('attendance')
          .select('is_present')
          .eq('worker_id', pfNumber)
          .eq('record_date', todayDateString);
          
      if (planId != null) {
        query = query.eq('plan_id', planId);
      }
      
      final data = await query.order('created_at', ascending: false).limit(1);
          
      if ((data as List).isEmpty) return false; // If no record, they are NOT present
      return data[0]['is_present'] as bool;
    } catch (e) {
      debugPrint('Error checking presence: $e');
      return false;
    }
  }

  Future<Set<String>> getPresentWorkerIdsToday(String planId) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      final presentIds = <String>{};

      // 1. Get from Supabase
      try {
        final todayDateString = todayStart.toIso8601String().split('T').first;
        final data = await supabaseClient
            .from('attendance')
            .select('worker_id, is_present, created_at')
            .eq('plan_id', planId)
            .eq('record_date', todayDateString);
        
        final Map<String, dynamic> latestCloud = {};
        for (var row in (data as List)) {
          final wid = row['worker_id'] as String;
          if (!latestCloud.containsKey(wid) || 
              DateTime.parse(row['created_at']).isAfter(DateTime.parse(latestCloud[wid]['created_at']))) {
            latestCloud[wid] = row;
          }
        }
        
        for (var row in latestCloud.values) {
          if (row['is_present'] == true) presentIds.add(row['worker_id']);
        }
      } catch (e) {
        debugPrint('Cloud attendance fetch failed: $e');
      }

      // 2. Get from Local DB (Overrides Cloud)
      final localRecords = await (db.select(db.localAttendance)
        ..where((t) => t.planId.equals(planId) & t.recordDate.isBetweenValues(todayStart, todayEnd))
        ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.asc)])
      ).get();

      for (var record in localRecords) {
        if (record.isPresent) {
          presentIds.add(record.workerId);
        } else {
          presentIds.remove(record.workerId);
        }
      }

      return presentIds;
    } catch (e) {
      debugPrint('Error fetching present worker IDs: $e');
      return {};
    }
  }

  Future<bool> isWorkerInPluckingPlanToday(String pfNumber) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayDateString = todayStart.toIso8601String().split('T').first;
      
      // Join attendance with estate_plans to ensure the plan is active and plucking
      final data = await supabaseClient
          .from('attendance')
          .select('is_present, estate_plans!inner(status, task_type)')
          .eq('worker_id', pfNumber)
          .eq('record_date', todayDateString)
          .eq('is_present', true)
          .eq('estate_plans.status', 'active')
          .ilike('estate_plans.task_type', '%plucking%')
          .order('created_at', ascending: false)
          .limit(1);
          
      return (data as List).isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if worker is in plucking plan: $e');
      return false;
    }
  }
}

final rosterWorkersProvider = FutureProvider.autoDispose.family<List<Worker>, EstatePlanModel>((ref, plan) async {
  return ref.read(attendanceRepositoryProvider).fetchWorkersByPlan(plan);
});
