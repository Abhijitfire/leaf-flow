import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';

final managerStatsRepositoryProvider = Provider<ManagerStatsRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ManagerStatsRepository(supabaseClient);
});

class ManagerStats {
  final double todayTargetKg;
  final double todayHarvestKg;
  final int workersPresent;
  final int pendingSections;

  const ManagerStats({
    required this.todayTargetKg,
    required this.todayHarvestKg,
    required this.workersPresent,
    required this.pendingSections,
  });
}

class ManagerStatsRepository {
  final SupabaseClient supabaseClient;

  ManagerStatsRepository(this.supabaseClient);

  Future<ManagerStats> getTodayStats() async {
    try {
      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String();
      
      // 1. Get today's targets from estate plans (including plans regardless of date for target sum)
      final plansData = await supabaseClient
          .from('estate_plans')
          .select('target_kg, status')
          .gte('plan_date', todayStart.split('T').first);

      double target = 0;
      for (var row in (plansData as List)) {
        target += (row['target_kg'] as num).toDouble();
      }

      // 2. Count total active plans irrespective of date
      final activePlansData = await supabaseClient
          .from('estate_plans')
          .select('id')
          .eq('status', 'active');
      final activePlansCount = (activePlansData as List).length;

      // 3. Get today's total harvest from harvest_logs
      final harvestData = await supabaseClient
          .from('harvest_logs')
          .select('weight_kg, worker_id')
          .gte('harvest_date', todayStart);

      double harvest = 0;
      final uniqueWorkers = <String>{};
      for (var row in (harvestData as List)) {
        harvest += (row['weight_kg'] as num).toDouble();
        uniqueWorkers.add(row['worker_id'].toString());
      }

      // 4. Use activePlansCount as pending sections (active plans)
      final pendingSections = activePlansCount;

      return ManagerStats(
        todayTargetKg: target > 0 ? target : 3500.0,
        todayHarvestKg: harvest,
        workersPresent: uniqueWorkers.length,
        pendingSections: pendingSections,
      );
    } catch (e) {
      debugPrint('Error fetching manager stats: $e');
      return const ManagerStats(
        todayTargetKg: 3500,
        todayHarvestKg: 0,
        workersPresent: 0,
        pendingSections: 0,
      );
    }
  }
}

final managerStatsProvider = FutureProvider.autoDispose<ManagerStats>((ref) async {
  final repository = ref.watch(managerStatsRepositoryProvider);
  final supabase = ref.watch(supabaseClientProvider);
  
  final channel1 = supabase.channel('public_harvest_logs_stats')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'harvest_logs',
      callback: (payload) {
        ref.invalidateSelf();
      }
    ).subscribe();
    
  final channel2 = supabase.channel('public_estate_plans_stats')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'estate_plans',
      callback: (payload) {
        ref.invalidateSelf();
      }
    ).subscribe();

  ref.onDispose(() {
    supabase.removeChannel(channel1);
    supabase.removeChannel(channel2);
  });
  
  return repository.getTodayStats();
});
