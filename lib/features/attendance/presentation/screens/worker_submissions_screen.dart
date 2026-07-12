import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';
import 'package:intl/intl.dart';
import '../../../tasks/data/repositories/estate_plan_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../tasks/domain/models/estate_plan_model.dart';

// Provider to fetch worker submissions
final workerSubmissionsProvider = FutureProvider.family<({String taskType, List<Map<String, dynamic>> workers, EstatePlanModel plan}), String>((ref, planId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final attendanceRepo = ref.read(attendanceRepositoryProvider);
  final plans = await ref.read(activeEstatePlansProvider.future);
  final plan = plans.firstWhere((p) => p.id == planId);
  
  final allWorkers = await attendanceRepo.fetchWorkersByPlan(plan);
  final presentWorkers = <Map<String, String>>[];
  final presentIds = await attendanceRepo.getPresentWorkerIdsToday(planId);
  
  for (var w in allWorkers) {
    if (presentIds.contains(w.id)) {
      presentWorkers.add({'worker_id': w.id, 'worker_name': w.name});
    }
  }

  final isPlucking = plan.taskType.toLowerCase() == 'plucking';

  // 2. Get all harvest logs for this plan
  // For Plucking: logs contain weight
  // For Non-Plucking: log with weight 0 indicates completion
  final harvestData = await supabase
      .from('harvest_logs')
      .select('worker_id, weight_kg, created_at')
      .eq('plan_id', planId);

  final List<Map<String, dynamic>> harvestList = List<Map<String, dynamic>>.from(harvestData as List<dynamic>? ?? []);
  final List<Map<String, dynamic>> results = [];

  for (var att in presentWorkers) {
    final workerId = att['worker_id']!;
    final workerName = att['worker_name']!;
    
    // Find matching harvest log
    final matchingLog = harvestList.where((log) => log['worker_id'] == workerId).toList();
    
    if (matchingLog.isNotEmpty) {
      if (isPlucking) {
        // Sum weights if multiple submissions
        double totalWeight = 0;
        DateTime? latestTime;
        
        for (var log in matchingLog) {
          totalWeight += (log['weight_kg'] as num).toDouble();
          final logTime = DateTime.parse(log['created_at']);
          if (latestTime == null || logTime.isAfter(latestTime)) {
            latestTime = logTime;
          }
        }
        
        results.add({
          'worker_id': workerId,
          'worker_name': workerName,
          'status': 'submitted',
          'weight_kg': totalWeight,
          'time': latestTime,
        });
      } else {
        results.add({
          'worker_id': workerId,
          'worker_name': workerName,
          'status': 'completed',
        });
      }
    } else {
      results.add({
        'worker_id': workerId,
        'worker_name': workerName,
        'status': 'pending',
      });
    }
  }

  // Sort: Submitted/Completed first, then pending
  results.sort((a, b) {
    final aStatus = a['status'] == 'pending' ? 1 : 0;
    final bStatus = b['status'] == 'pending' ? 1 : 0;
    return aStatus.compareTo(bStatus);
  });

  return (taskType: plan.taskType, workers: results, plan: plan);
});

class WorkerSubmissionsScreen extends ConsumerWidget {
  final String planId;
  
  const WorkerSubmissionsScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(workerSubmissionsProvider(planId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Submissions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(workerSubmissionsProvider(planId)),
          ),
        ],
      ),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final taskType = data.taskType;
          final workers = data.workers;
          final isPlucking = taskType.toLowerCase() == 'plucking';

          if (workers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('No workers marked as present for this plan yet.'),
                ],
              ),
            );
          }

          int submittedCount = workers.where((w) => w['status'] == 'submitted' || w['status'] == 'completed').length;
          double totalWeight = workers.fold(0.0, (sum, w) => sum + (w['weight_kg'] ?? 0.0));

          return Column(
            children: [
              if (isPlucking)
                Container(
                  padding: const EdgeInsets.all(24),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Present', workers.length.toString(), theme),
                      _buildStatColumn('Submitted', submittedCount.toString(), theme),
                      _buildStatColumn('Total Collected', '${totalWeight.toStringAsFixed(1)} kg', theme),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Present', workers.length.toString(), theme),
                      _buildStatColumn('Task', taskType, theme),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(workerSubmissionsProvider(planId));
                    await ref.read(workerSubmissionsProvider(planId).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: workers.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final worker = workers[index];
                      final isSubmitted = worker['status'] == 'submitted';
                      final isCompleted = worker['status'] == 'completed';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSubmitted || isCompleted ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                          child: Icon(
                            isSubmitted || isCompleted ? Icons.check : Icons.hourglass_empty,
                            color: isSubmitted || isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                        title: Text(worker['worker_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(worker['worker_id']),
                        trailing: isPlucking
                            ? (isSubmitted
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${worker['weight_kg'].toStringAsFixed(1)} kg', 
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
                                      Text(DateFormat.jm().format(worker['time'] as DateTime), 
                                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('In Field', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ))
                            : (isCompleted 
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('Task Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                  )
                                : FilledButton.tonal(
                                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                                    onPressed: () async {
                                      try {
                                        final supabase = ref.read(supabaseClientProvider);
                                        await supabase.from('harvest_logs').insert({
                                          'worker_id': worker['worker_id'],
                                          'plan_id': planId,
                                          'section_id': data.plan.sectionId,
                                          'supervisor_id': supabase.auth.currentUser!.id,
                                          'harvest_date': DateTime.now().toIso8601String().split('T').first,
                                          'weight_kg': 0.0,
                                          'leaf_quality': 'Non-Harvest',
                                          'clerk_id': supabase.auth.currentUser!.id,
                                        });
                                        ref.invalidate(workerSubmissionsProvider(planId));
                                      } catch (e) {
                                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                      }
                                    },
                                    child: const Text('Complete Task'),
                                  )),
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16 + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: (!isPlucking && (workers.length - submittedCount) > 0) ? null : () async {
                    final pendingCount = workers.length - submittedCount;
                    
                    if (isPlucking && pendingCount > 0) {
                      final proceed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Warning: Missing Weights', style: TextStyle(color: Colors.red)),
                          content: Text('You have $pendingCount workers who haven\'t been weighed yet. Are you sure you want to close this plan?\n\nThey will not be able to submit weights after this.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('CANCEL'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('CLOSE ANYWAY'),
                            ),
                          ],
                        ),
                      );
                      
                      if (proceed != true) return;
                    } else if (!isPlucking) {
                      final proceed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Finalize Task'),
                          content: const Text('Are you sure you want to submit and close this task? It will be moved to the completed state and removed from Active Plans.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('CANCEL'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('SUBMIT'),
                            ),
                          ],
                        ),
                      );
                      
                      if (proceed != true) return;
                    }
                    
                    if (!context.mounted) return;
                    
                    try {
                      await ref.read(estatePlanRepositoryProvider).completeEstatePlan(planId);
                      ref.invalidate(activeEstatePlansProvider);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Plan finalized and closed!')),
                        );
                        context.pop();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error closing plan: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(!isPlucking && (workers.length - submittedCount) > 0 ? 'WAITING FOR ALL WORKERS' : (isPlucking ? 'FINALIZE TASK' : 'SUBMIT'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.tertiary,
                    foregroundColor: theme.colorScheme.onTertiary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
