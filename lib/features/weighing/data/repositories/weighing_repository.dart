import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/worker_model.dart';
import '../../domain/models/harvest_log_model.dart';

final weighingRepositoryProvider = Provider<WeighingRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return WeighingRepository(supabaseClient);
});

class WeighingStats {
  final double totalKg;
  final int workersProcessed;
  const WeighingStats({required this.totalKg, required this.workersProcessed});
}

class WeighingRepository {
  final SupabaseClient supabaseClient;

  WeighingRepository(this.supabaseClient);

  Future<void> submitHarvest(Worker worker, double weightKg) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final todayStr = DateTime(now.year, now.month, now.day).toIso8601String().split('T').first;
      
      String? matchedPlanId;
      String? matchedSectionId;

      // 1. Auto-link: Find the most recent ACTIVE PLUCKING plan the worker is present in today
      final attendanceData = await supabaseClient
          .from('attendance')
          .select('plan_id, estate_plans!inner(section_id, status, task_type)')
          .eq('worker_id', worker.id)
          .eq('record_date', todayStr)
          .eq('is_present', true)
          .eq('estate_plans.status', 'active')
          .ilike('estate_plans.task_type', '%plucking%')
          .order('created_at', ascending: false)
          .limit(1);

      if ((attendanceData as List).isNotEmpty) {
        final record = attendanceData[0];
        matchedPlanId = record['plan_id'] as String?;
        if (record['estate_plans'] != null) {
          matchedSectionId = record['estate_plans']['section_id'] as String?;
        }
      }

      final log = HarvestLogModel(
        workerId: worker.id,
        planId: matchedPlanId,
        sectionId: matchedSectionId,
        dafaId: worker.dafaId,
        harvestDate: DateTime.now(),
        weightKg: weightKg,
        clerkId: user.id,
      );

      await supabaseClient.from('harvest_logs').insert(log.toJson());
      debugPrint('Successfully logged $weightKg kg for worker ${worker.id}');
    } catch (e) {
      debugPrint('Error submitting harvest: $e');
      rethrow;
    }
  }

  Future<WeighingStats> getTodayStats() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return const WeighingStats(totalKg: 0, workersProcessed: 0);

      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String();
      
      final data = await supabaseClient
          .from('harvest_logs')
          .select('weight_kg, worker_id')
          .eq('clerk_id', user.id)
          .gte('harvest_date', todayStart);
          
      final logs = data as List;
      
      double totalKg = 0;
      final uniqueWorkers = <String>{};
      
      for (var row in logs) {
        totalKg += (row['weight_kg'] as num).toDouble();
        uniqueWorkers.add(row['worker_id'].toString());
      }
      
      return WeighingStats(
        totalKg: totalKg,
        workersProcessed: uniqueWorkers.length,
      );
    } catch (e) {
      debugPrint('Error fetching today stats: $e');
      return const WeighingStats(totalKg: 0, workersProcessed: 0);
    }
  }

  Future<void> dispatchFactory({
    required double totalWeightKg,
    required String vehicleNumber,
    required String driverName,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await supabaseClient.from('dispatch_logs').insert({
      'clerk_id': user.id,
      'total_weight_kg': totalWeightKg,
      'vehicle_number': vehicleNumber,
      'driver_name': driverName,
    });
  }
  Future<double> getPlanProgress(String planId) async {
    try {
      final data = await supabaseClient
          .from('harvest_logs')
          .select('weight_kg')
          .eq('plan_id', planId);
          
      final logs = data as List;
      double totalKg = 0;
      for (var row in logs) {
        totalKg += (row['weight_kg'] as num).toDouble();
      }
      return totalKg;
    } catch (e) {
      debugPrint('Error fetching plan progress: $e');
      return 0.0;
    }
  }
}

final weighingStatsProvider = FutureProvider.autoDispose<WeighingStats>((ref) async {
  final repository = ref.watch(weighingRepositoryProvider);
  final supabase = ref.watch(supabaseClientProvider);
  
  final channel = supabase.channel('public_harvest_logs_weighing')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'harvest_logs',
      callback: (payload) {
        ref.invalidateSelf();
      }
    ).subscribe();

  ref.onDispose(() {
    supabase.removeChannel(channel);
  });
  
  return repository.getTodayStats();
});

final planProgressProvider = FutureProvider.autoDispose.family<double, String>((ref, planId) async {
  final repository = ref.watch(weighingRepositoryProvider);
  final supabase = ref.watch(supabaseClientProvider);
  
  final channel = supabase.channel('public_harvest_logs_progress_$planId')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'harvest_logs',
      callback: (payload) {
        ref.invalidateSelf();
      }
    ).subscribe();

  ref.onDispose(() {
    supabase.removeChannel(channel);
  });
  
  return repository.getPlanProgress(planId);
});
