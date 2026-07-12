import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../sections/data/repositories/section_repository.dart';
import '../../../tasks/data/repositories/estate_plan_repository.dart';
import '../../data/repositories/manager_stats_repository.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../sections/domain/models/section_model.dart';

class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile: _ManagerMobileView(),
      tablet: _ManagerTabletView(),
    );
  }
}

class _ManagerMobileView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(managerStatsProvider);
    final sectionsAsync = ref.watch(sectionsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(context, ref),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(managerStatsProvider);
          ref.invalidate(sectionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context,
              ).animate().fade(duration: 150.ms).slideY(begin: -0.1, end: 0),
              const SizedBox(height: 32),
              _buildHeroCard(
                context,
                statsAsync,
              ).animate().fade(delay: 50.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 32),
              Text(
                'Estate Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fade(delay: 150.ms),
              const SizedBox(height: 16),
              _buildKpiGrid(
                context,
                ref,
                statsAsync,
                sectionsAsync,
              ).animate().fade(delay: 200.ms),
              const SizedBox(height: 24),
              _buildQuickActions(context).animate().fade(delay: 220.ms),
              const SizedBox(height: 32),
              _buildActivePlans(context, ref).animate().fade(delay: 250.ms),
              const SizedBox(height: 32),
              _buildAttentionSections(
                context,
                ref,
                sectionsAsync,
              ).animate().fade(delay: 300.ms),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
}

class _ManagerTabletView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(managerStatsProvider);
    final sectionsAsync = ref.watch(sectionsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (index) {
              if (index == 1) context.push('/workers/new');
              if (index == 2) context.push('/tasks/new');
              if (index == 3) context.push('/sections/new');
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_add),
                label: Text('Workers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_add),
                label: Text('Plans'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map),
                label: Text('Sections'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            flex: 5,
            child: Scaffold(
              appBar: _buildAppBar(context, ref),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(managerStatsProvider);
                  ref.invalidate(sectionsProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context).animate().fade(duration: 150.ms),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeroCard(
                                  context,
                                  statsAsync,
                                ).animate().fade(),
                                const SizedBox(height: 32),
                                Text(
                                  'Estate Overview',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildKpiGrid(
                                  context,
                                  ref,
                                  statsAsync,
                                  sectionsAsync,
                                  crossAxisCount: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildQuickActions(context),
                                const SizedBox(height: 32),
                                _buildActivePlans(context, ref),
                                const SizedBox(height: 32),
                                _buildAttentionSections(
                                  context,
                                  ref,
                                  sectionsAsync,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [], // Placeholder for future content
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted UI Components

AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
  return AppBar(
    title: const Text(
      'LeafFlow',
      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
    ),
    centerTitle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: const Text(
          'A / ক',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        tooltip: 'Toggle Language',
        onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
      ),
      IconButton(
        icon: const Icon(Icons.scale),
        tooltip: 'Weighing Station',
        onPressed: () => context.push('/weighing'),
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        tooltip: 'Logout',
        onPressed: () async {
          await ref.read(supabaseClientProvider).auth.signOut();
          setCachedUserRole(null);
          if (context.mounted) context.go('/login');
        },
      ),
      const SizedBox(width: 16),
    ],
  );
}

Widget _buildHeader(BuildContext context) {
  final theme = Theme.of(context);
  final now = DateTime.now();
  final dateStr = DateFormat('EEEE, MMMM d').format(now);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Good morning',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      Row(
        children: [
          Icon(Icons.cloud_queue, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '72°F',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildHeroCard(
  BuildContext context,
  AsyncValue<ManagerStats> statsAsync,
) {
  final theme = Theme.of(context);
  final formatter = NumberFormat("#,##0", "en_US");

  return statsAsync.when(
    data: (stats) {
      final achievement = stats.todayTargetKg > 0
          ? (stats.todayHarvestKg / stats.todayTargetKg)
          : 0.0;
      final harvestGap = stats.todayTargetKg - stats.todayHarvestKg;

      return GestureDetector(
        onTap: () => context.push('/harvest/today'),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Today\'s Harvest',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.9,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${(achievement * 100).toStringAsFixed(1)}% Achieved',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatter.format(stats.todayHarvestKg),
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'kg',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: achievement.clamp(0.0, 1.0),
                  backgroundColor: theme.colorScheme.onPrimary.withValues(
                    alpha: 0.2,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.secondary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Target: ${formatter.format(stats.todayTargetKg)} kg',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    },
    loading: () => const SkeletonCard(height: 200),
    error: (err, stack) => Center(child: Text('Error loading stats: $err')),
  );
}

Widget _buildQuickActions(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () => context.push('/tasks/new'),
            icon: const Icon(Icons.assignment_add),
            label: const Text('Create Plan'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: SizedBox(
          height: 52,
          child: FilledButton.tonalIcon(
            onPressed: () => context.push('/workers/new'),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add Worker'),
          ),
        ),
      ),
    ],
  );
}

Widget _buildKpiGrid(
  BuildContext context,
  WidgetRef ref,
  AsyncValue<ManagerStats> statsAsync,
  AsyncValue<List<SectionModel>> sectionsAsync, {
  int crossAxisCount = 2,
}) {
  final theme = Theme.of(context);
  final formatter = NumberFormat("#,##0", "en_US");
  // Derive counts from their canonical providers to avoid stale/duplicate queries
  final activePlansAsync = ref.watch(activeEstatePlansProvider);
  final completedPlansAsync = ref.watch(completedTodayEstatePlansProvider);

  return statsAsync.when(
    data: (stats) {
      final activePlansCount = activePlansAsync.when(
        data: (plans) => plans.length,
        loading: () => null,
        error: (_, _) => 0,
      );
      final attentionCount = sectionsAsync.when(
        data: (sections) =>
            sections.where((s) => s.lastPluckedDaysAgo > 7).length,
        loading: () => null,
        error: (_, _) => 0,
      );

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          _buildKpiCard(
            context,
            'Active Plans',
            activePlansCount != null ? '$activePlansCount' : '—',
            Icons.map_outlined,
            theme.colorScheme.primary,
            onTap: () => context.push('/plans/active'),
          ),
          _buildKpiCard(
            context,
            'Completed Today',
            completedPlansAsync.when(
              data: (plans) => '${plans.length}',
              loading: () => '—',
              error: (_, __) => '0',
            ),
            Icons.check_circle_outline,
            Colors.green,
            onTap: () => context.push('/plans/completed'),
          ),
          _buildKpiCard(
            context,
            'Total Plucked',
            '${formatter.format(stats.todayHarvestKg)} kg',
            Icons.eco_outlined,
            theme.colorScheme.secondary,
            onTap: () => context.push('/harvest/today'),
          ),
          _buildKpiCard(
            context,
            'Workers Present',
            stats.workersPresent > 0 ? '${stats.workersPresent}' : '—',
            Icons.people_outline,
            theme.colorScheme.tertiary,
            onTap: () => context.push('/reports/payroll'),
          ),
          _buildKpiCard(
            context,
            'Attention Needed',
            attentionCount != null ? '$attentionCount' : '—',
            Icons.warning_amber_rounded,
            theme
                .colorScheme
                .error, // This will be handled by the dedicated section
            onTap: () => context.push('/sections/attention'),
          ),
        ],
      );
    },
    loading: () => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: List.generate(4, (i) => const SkeletonCard(height: 100)),
    ),
    error: (err, stack) => const Text('Error'),
  );
}

Widget _buildKpiCard(
  BuildContext context,
  String title,
  String value,
  IconData icon,
  Color color, {
  VoidCallback? onTap,
}) {
  final theme = Theme.of(context);
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
              const Spacer(),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

Widget _buildAttentionSections(
  // Renamed for clarity
  BuildContext context,
  WidgetRef ref,
  AsyncValue<List<SectionModel>> sectionsAsync,
) {
  final theme = Theme.of(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Needs Attention',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
            size: 20,
          ),
        ],
      ),
      const SizedBox(height: 16),
      sectionsAsync.when(
        loading: () => const SkeletonCard(height: 120),
        error: (err, stack) => Text('Error: $err'),
        data: (sections) {
          final attentionSections = sections
              .where((s) => s.lastPluckedDaysAgo > 7)
              .toList();

          if (attentionSections.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Good!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No sections are currently overdue for harvest.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attentionSections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final section = attentionSections[index];
              return Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => context.push('/section/${section.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      // Keep decoration inside InkWell's child
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                section.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusBadge(status: section.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Overdue by ${section.lastPluckedDaysAgo - 7} days',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () => context.push(
                              '/tasks/new',
                              extra: {'sectionId': section.id},
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                            ),
                            child: const Text('Create Plan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ],
  );
}

Widget _buildActivePlans(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final activePlansAsync = ref.watch(activeEstatePlansProvider);

  return activePlansAsync.when(
    loading: () => const SkeletonCard(height: 80),
    error: (err, stack) => const SizedBox.shrink(),
    data: (plans) {
      if (plans.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Active Plans',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // For brevity, we'll just show a summary card. A list could also be used.
          ListTile(
            onTap: () => context.push('/plans/active'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            leading: const Icon(Icons.list_alt),
            title: Text('${plans.length} plans are active'),
            subtitle: const Text('Tap to view details'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      );
    },
  );
}

Widget _buildBottomNav(BuildContext context) {
  return NavigationBar(
    selectedIndex: 0,
    onDestinationSelected: (index) {
      if (index == 1) context.push('/workers/new');
      if (index == 2) context.push('/tasks/new');
      if (index == 3) context.push('/sections/new');
    },
    destinations: const [
      NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.person_add), label: 'Worker'),
      NavigationDestination(icon: Icon(Icons.assignment_add), label: 'Plan'),
      NavigationDestination(icon: Icon(Icons.map), label: 'Section'),
    ],
  );
}
