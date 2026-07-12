import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../tasks/data/repositories/estate_plan_repository.dart';
import '../../../weighing/data/repositories/weighing_repository.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/skeleton_loader.dart';

final currentUserProvider = Provider((ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser;
});

final myDafasProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final response = await ref.read(supabaseClientProvider)
      .from('dafas')
      .select('id')
      .eq('sardar_id', user.id);
      
  return (response as List).map((e) => e['id'] as String).toList();
});

class SupervisorDashboard extends ConsumerWidget {
  const SupervisorDashboard({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(supabaseClientProvider).auth.signOut();
    setCachedUserRole(null);
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = ref.watch(appTranslationsProvider);
    final plansAsync = ref.watch(activeEstatePlansProvider);
    final myDafasAsync = ref.watch(myDafasProvider);
    final user = ref.watch(currentUserProvider);
    final userName = user?.userMetadata?['full_name'] ?? 'Supervisor';
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(t.translate('my_kamjari'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(Icons.wifi, size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text('Online', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
              ],
            ),
          ),
          IconButton(
            icon: const Text('A/ক', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Text(
                '${t.translate('good_morning')},',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                t.translate('todays_estate_plan'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: plansAsync.when(
                  loading: () => ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => const SkeletonCard(height: 160),
                  ),
                  error: (err, stack) => Center(child: Text('Error loading plans: $err')),
                  data: (plans) {
                    return myDafasAsync.when(
                      loading: () => ListView.separated(
                        itemCount: 3,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => const SkeletonCard(height: 160),
                      ),
                      error: (err, stack) => Center(child: Text('Error loading dafas: $err')),
                      data: (myDafaIds) {
                        final myPlans = plans.where((p) => myDafaIds.contains(p.dafaId)).toList();

                        if (myPlans.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.assignment_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                const SizedBox(height: 16),
                                Text(t.translate('no_active_plans'), style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text(t.translate('ask_manager'), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: myPlans.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 16),
                          padding: const EdgeInsets.only(bottom: 80),
                          itemBuilder: (context, index) {
                            final plan = myPlans[index];
                            final isCompleted = plan.status == 'completed';
                            
                            return _buildTaskCard(context, ref, plan, isCompleted, theme, t);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'log_inspection',
        onPressed: () => context.push('/inspections/new'),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
        icon: const Icon(Icons.camera_alt_outlined),
        label: Text(t.translate('log_inspection'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        elevation: 4,
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, dynamic plan, bool isCompleted, ThemeData theme, dynamic t) {
    return Container(
      decoration: BoxDecoration(
        color: isCompleted ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.transparent : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.sectionName ?? '${t.translate('section')} ${plan.sectionId.substring(0, 8)}',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                        : theme.colorScheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    plan.status.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.monitor_weight_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('${t.translate('target')} ${plan.targetKg.toStringAsFixed(0)} ${plan.targetUnit}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: 16),
                Icon(Icons.eco_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Task: ${plan.taskType}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 16),
            
            if (plan.taskType == 'Plucking') ...[
              Consumer(
                builder: (context, ref, child) {
                  final progressAsync = ref.watch(planProgressProvider(plan.id));
                  
                  return progressAsync.when(
                    data: (actualKg) {
                      final isMet = actualKg >= plan.targetKg;
                      final percent = (plan.targetKg > 0) ? (actualKg / plan.targetKg).clamp(0.0, 1.0) : 0.0;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${actualKg.toStringAsFixed(1)} kg / ${plan.targetKg.toStringAsFixed(0)} kg',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isMet ? Colors.green : theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${(percent * 100).toInt()}%',
                                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percent,
                              backgroundColor: theme.colorScheme.surfaceContainer,
                              color: isMet ? Colors.green : theme.colorScheme.primary,
                              minHeight: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () => context.push('/supervisor/submissions/${plan.id}'),
                                  icon: const Icon(Icons.people_alt_outlined),
                                  label: const Text('View Submissions'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const SkeletonCard(height: 80),
                    error: (err, stack) => const Text('Error loading progress'),
                  );
                },
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => context.push('/supervisor/submissions/${plan.id}'),
                      icon: const Icon(Icons.checklist),
                      label: const Text('Review Task'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.push('/supervisor/roster', extra: plan),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.how_to_reg, size: 24, color: theme.colorScheme.onTertiaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.translate('tap_to_take_hazira'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onTertiaryContainer),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
