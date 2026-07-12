import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/payroll_record.dart';

final payrollRepositoryProvider = Provider<PayrollRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return PayrollRepository(supabaseClient);
});

// A family provider to fetch payroll for a specific date
final payrollProvider = FutureProvider.family<List<PayrollRecord>, DateTime>((ref, date) async {
  final repository = ref.watch(payrollRepositoryProvider);
  return repository.getPayrollForDate(date);
});

class PayrollRepository {
  final SupabaseClient supabaseClient;

  PayrollRepository(this.supabaseClient);

  Future<List<PayrollRecord>> getPayrollForDate(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T').first;

      // 1. Fetch all workers
      final workersData = await supabaseClient.from('workers').select();
      
      // 2. Fetch attendance for the specific date
      final attendanceData = await supabaseClient
          .from('attendance')
          .select('worker_id, is_present')
          .eq('record_date', dateString);
          
      final attendanceMap = {
        for (var row in (attendanceData as List))
          row['worker_id'].toString(): row['is_present'] as bool
      };

      // 3. Fetch harvest logs for the specific date
      final harvestData = await supabaseClient
          .from('harvest_logs')
          .select('worker_id, weight_kg')
          .eq('harvest_date', dateString);
          
      // Aggregate weights by worker
      final harvestMap = <String, double>{};
      for (var row in (harvestData as List)) {
        final workerId = row['worker_id'].toString();
        final weight = (row['weight_kg'] as num).toDouble();
        harvestMap[workerId] = (harvestMap[workerId] ?? 0.0) + weight;
      }

      // 4. Calculate wages
      final records = <PayrollRecord>[];
      const baseWageAmount = 250.0;
      const incentivePerKg = 5.0;

      for (var row in (workersData as List)) {
        final workerId = row['pf_number'].toString();
        final workerName = row['full_name'].toString();
        final gangId = row['gang_id'].toString();
        final quota = (row['daily_quota_kg'] as num).toDouble();

        final isPresent = attendanceMap[workerId] ?? false;
        final totalKg = harvestMap[workerId] ?? 0.0;

        double baseWage = isPresent ? baseWageAmount : 0.0;
        double incentiveWage = 0.0;

        if (isPresent && totalKg > quota) {
          final extraKg = totalKg - quota;
          incentiveWage = extraKg * incentivePerKg;
        }

        records.add(PayrollRecord(
          workerId: workerId,
          workerName: workerName,
          gangId: gangId,
          isPresent: isPresent,
          totalKg: totalKg,
          quotaKg: quota,
          baseWage: baseWage,
          incentiveWage: incentiveWage,
          totalWage: baseWage + incentiveWage,
        ));
      }

      // Sort by gang, then by name
      records.sort((a, b) {
        final gangComp = a.gangId.compareTo(b.gangId);
        if (gangComp != 0) return gangComp;
        return a.workerName.compareTo(b.workerName);
      });

      return records;
    } catch (e) {
      debugPrint('Error calculating payroll: $e');
      throw Exception('Failed to calculate payroll: $e');
    }
  }
}
