import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../tasks/data/repositories/estate_plan_repository.dart';

class ActivePlansScreen extends ConsumerWidget {
  const ActivePlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(activeEstatePlansProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Plans', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (plans) {
          final activePlans = plans.where((p) => p.status == 'active').toList();

          if (activePlans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No active plans right now.', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Create a new plan from the dashboard.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: activePlans.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = activePlans[index];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.map_outlined, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    plan.sectionName ?? 'Section ${plan.sectionId.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${plan.taskType} • Target: ${plan.targetKg.toStringAsFixed(0)} ${plan.targetUnit}',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
              ).animate().fade(delay: (100 * index).ms).slideX(begin: 0.05);
            },
          );
        },
      ),
    );
  }
}
