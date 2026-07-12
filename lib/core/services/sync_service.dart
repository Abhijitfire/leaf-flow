import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/database/app_database.dart';
import '../../features/weighing/domain/models/worker_model.dart';


final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final db = ref.watch(appDatabaseProvider);
  return SyncService(supabase, db);
});

class SyncService {
  final SupabaseClient supabase;
  final AppDatabase db;

  SyncService(this.supabase, this.db);

  Future<bool> _hasInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity().timeout(const Duration(seconds: 2));
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      return false; // If it hangs or errors, assume offline
    }
  }

  /// Pull workers from Supabase and cache them locally in Drift.
  Future<void> syncWorkersDown() async {
    if (!await _hasInternet()) return;

    try {
      debugPrint('SyncService: Pulling workers from Supabase...');
      final data = await supabase.from('workers').select();
      final workers = (data as List).map((e) => Worker.fromJson(e)).toList();

      await db.batch((batch) {
        batch.insertAll(
          db.localWorkers,
          workers.map((w) => LocalWorkersCompanion(
            pfNumber: Value(w.id),
            fullName: Value(w.name),
            dafaId: Value(w.dafaId),
            phoneNumber: Value(w.phoneNumber),
            dailyQuotaKg: Value(w.dailyQuotaKg),
          )),
          mode: InsertMode.insertOrReplace,
        );
      });
      debugPrint('SyncService: Successfully synced ${workers.length} workers to local DB.');
    } catch (e) {
      debugPrint('SyncService Error pulling workers: $e');
    }
  }

  /// Push unsynced attendance records from Drift to Supabase.
  Future<void> syncAttendanceUp() async {
    if (!await _hasInternet()) return;

    try {
      debugPrint('SyncService: Pushing unsynced attendance to Supabase...');
      final unsynced = await (db.select(db.localAttendance)..where((t) => t.isSynced.equals(false))).get();

      if (unsynced.isEmpty) {
        debugPrint('SyncService: No unsynced attendance records found.');
        return;
      }

      final payload = unsynced.map((r) => <String, dynamic>{
        'plan_id': r.planId,
        'worker_id': r.workerId,
        'record_date': r.recordDate.toIso8601String().split('T').first,
        'is_present': r.isPresent,
      }).toList();

      await supabase.from('attendance').upsert(
        payload,
        onConflict: 'plan_id, worker_id, record_date',
      );

      // Mark as synced locally (or delete them to save space)
      final ids = unsynced.map((r) => r.id).toList();
      await (db.update(db.localAttendance)..where((t) => t.id.isIn(ids))).write(
        const LocalAttendanceCompanion(isSynced: Value(true)),
      );

      debugPrint('SyncService: Successfully pushed ${unsynced.length} records.');
    } catch (e) {
      debugPrint('SyncService Error pushing attendance: $e');
    }
  }
}
