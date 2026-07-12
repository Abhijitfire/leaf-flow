import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';

class WorkerHarvest {
  final String workerId;
  final String workerName;
  final double totalKg;

  WorkerHarvest({
    required this.workerId,
    required this.workerName,
    required this.totalKg,
  });
}

class GangHarvest {
  final String gangId;
  final double totalKg;
  final List<WorkerHarvest> workers;

  GangHarvest({
    required this.gangId,
    required this.totalKg,
    required this.workers,
  });
}

class HarvestReportRepository {
  final SupabaseClient supabaseClient;

  HarvestReportRepository(this.supabaseClient);

  Future<List<GangHarvest>> getTodayHarvestReport() async {
    try {
      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String();
      
      final response = await supabaseClient
          .from('harvest_logs')
          .select('weight_kg, gang_id, worker_id, workers!inner(full_name)')
          .gte('harvest_date', todayStart.split('T').first);

      final logs = response as List;
      
      // Temporary structures for grouping
      final Map<String, Map<String, double>> gangWorkerTotals = {};
      final Map<String, String> workerNames = {};

      for (var row in logs) {
        final gangId = row['gang_id']?.toString() ?? 'Unknown';
        final workerId = row['worker_id'].toString();
        final weight = (row['weight_kg'] as num).toDouble();
        final workerName = row['workers'] != null ? row['workers']['full_name'].toString() : 'Unknown Worker';
        
        workerNames[workerId] = workerName;

        gangWorkerTotals.putIfAbsent(gangId, () => {});
        gangWorkerTotals[gangId]![workerId] = (gangWorkerTotals[gangId]![workerId] ?? 0.0) + weight;
      }

      // Build the final typed list
      final List<GangHarvest> report = [];
      
      gangWorkerTotals.forEach((gangId, workersMap) {
        double gangTotal = 0;
        final List<WorkerHarvest> gangWorkers = [];
        
        workersMap.forEach((workerId, totalKg) {
          gangTotal += totalKg;
          gangWorkers.add(WorkerHarvest(
            workerId: workerId,
            workerName: workerNames[workerId]!,
            totalKg: totalKg,
          ));
        });
        
        // Sort workers by highest harvest
        gangWorkers.sort((a, b) => b.totalKg.compareTo(a.totalKg));
        
        report.add(GangHarvest(
          gangId: gangId,
          totalKg: gangTotal,
          workers: gangWorkers,
        ));
      });
      
      // Sort gangs alphabetically
      report.sort((a, b) => a.gangId.compareTo(b.gangId));
      
      return report;
    } catch (e) {
      debugPrint('Error fetching harvest report: $e');
      return [];
    }
  }
}

final harvestReportRepositoryProvider = Provider<HarvestReportRepository>((ref) {
  return HarvestReportRepository(ref.watch(supabaseClientProvider));
});

final harvestReportProvider = FutureProvider.autoDispose<List<GangHarvest>>((ref) async {
  final repository = ref.watch(harvestReportRepositoryProvider);
  return repository.getTodayHarvestReport();
});
