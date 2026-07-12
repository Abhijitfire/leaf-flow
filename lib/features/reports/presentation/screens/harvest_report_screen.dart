import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/harvest_report_repository.dart';

class HarvestReportScreen extends ConsumerWidget {
  const HarvestReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(harvestReportProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harvest Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(harvestReportProvider),
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading report: $e')),
        data: (gangs) {
          if (gangs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('No harvest data for today yet.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gangs.length,
            itemBuilder: (context, index) {
              final gang = gangs[index];
              return _buildGangCard(context, gang);
            },
          );
        },
      ),
    );
  }

  Widget _buildGangCard(BuildContext context, GangHarvest gang) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            gang.gangId,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(
            '${gang.workers.length} Members Weighed',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${gang.totalKg.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          children: [
            const Divider(height: 1),
            ...gang.workers.map((worker) => _buildWorkerRow(context, worker)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerRow(BuildContext context, WorkerHarvest worker) {
    final theme = Theme.of(context);
    final quota = 20.0; // Standard daily quota
    final progress = (worker.totalKg / quota).clamp(0.0, 1.0);
    final metQuota = worker.totalKg >= quota;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.workerName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                      worker.workerId,
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '${worker.totalKg.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: metQuota ? Colors.green[700] : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (metQuota) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                  ]
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: metQuota ? Colors.green : theme.colorScheme.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
