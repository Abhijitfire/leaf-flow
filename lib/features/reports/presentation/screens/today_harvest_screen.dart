import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/supabase_service.dart';

// Provider to fetch today's harvest logs with worker names
final todayHarvestLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final todayStr = DateTime.now().toIso8601String().split('T').first;

  final data = await supabase
      .from('harvest_logs')
      .select('*, workers(full_name)')
      .gte('harvest_date', todayStr)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(data as List);
});

class TodayHarvestScreen extends ConsumerWidget {
  const TodayHarvestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todayHarvestLogsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Harvest', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(todayHarvestLogsProvider),
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No harvest recorded today yet.', style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          // Summary stats
          double totalWeight = 0;
          final uniqueWorkers = <String>{};
          for (var log in logs) {
            totalWeight += (log['weight_kg'] as num).toDouble();
            uniqueWorkers.add(log['worker_id'].toString());
          }

          return Column(
            children: [
              // Summary bar
              Container(
                padding: const EdgeInsets.all(20),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Total', '${totalWeight.toStringAsFixed(1)} kg', theme),
                    _buildStat('Entries', '${logs.length}', theme),
                    _buildStat('Workers', '${uniqueWorkers.length}', theme),
                  ],
                ),
              ),
              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(todayHarvestLogsProvider);
                    await ref.read(todayHarvestLogsProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final workerName = log['workers']?['full_name'] ?? log['worker_id'];
                      final weight = (log['weight_kg'] as num).toDouble();
                      final time = DateTime.tryParse(log['created_at'] ?? '');
                      final timeStr = time != null ? DateFormat.jm().format(time.toLocal()) : '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.eco, color: theme.colorScheme.primary, size: 20),
                        ),
                        title: Text(workerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(timeStr, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                        trailing: Text(
                          '${weight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ).animate().fade(delay: (50 * index).ms);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
