import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/weighing_repository.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class WeighingDashboardScreen extends ConsumerWidget {
  const WeighingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = ref.watch(appTranslationsProvider);
    final statsAsyncValue = ref.watch(weighingStatsProvider);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(t.translate('weighing_station'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(weighingStatsProvider),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () async {
              await ref.read(supabaseClientProvider).auth.signOut();
              setCachedUserRole(null);
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stats Header
                  statsAsyncValue.when(
                    data: (stats) => Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: t.translate('total_collected'),
                            value: '${stats.totalKg.toStringAsFixed(1)} kg',
                            icon: Icons.scale,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: t.translate('workers_processed'),
                            value: '${stats.workersProcessed}',
                            icon: Icons.people,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    loading: () => Row(
                      children: const [
                        Expanded(child: SkeletonCard(height: 120)),
                        SizedBox(width: 16),
                        Expanded(child: SkeletonCard(height: 120)),
                      ],
                    ),
                    error: (e, st) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('Error loading stats: $e', style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.1),
                  
                  // Big Scan Button
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.8 > 300 ? 300 : constraints.maxWidth * 0.8,
                        maxHeight: constraints.maxWidth * 0.8 > 300 ? 300 : constraints.maxWidth * 0.8,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: FilledButton(
                          onPressed: () async {
                            await context.push('/weighing/scan');
                            ref.invalidate(weighingStatsProvider);
                          },
                          style: FilledButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            elevation: 8,
                            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.badge, size: constraints.maxWidth > 350 ? 80 : 60),
                              const SizedBox(height: 16),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  t.translate('enter_id'),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onPrimary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.05),
                  
                  Text(
                    t.translate('ready_for_next'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: constraints.maxHeight * 0.1),
                  
                  SizedBox(
                    height: 56,
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        await context.push('/weighing/dispatch');
                        ref.invalidate(weighingStatsProvider);
                      },
                      icon: const Icon(Icons.local_shipping),
                      label: Text(t.translate('dispatch_transport'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        foregroundColor: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
