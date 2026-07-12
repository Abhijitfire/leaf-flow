import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/models/section_model.dart';

class SectionDetailsScreen extends ConsumerWidget {
  final String sectionId;

  const SectionDetailsScreen({super.key, required this.sectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final section = MockData.sections.firstWhere((s) => s.id == sectionId,
        orElse: () => MockData.sections.first);

    return Scaffold(
      appBar: AppBar(
        title: Text(section.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agronomic Profile',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                StatusBadge(status: section.status),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfileGrid(context, section, theme),
            const SizedBox(height: 32),
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActivityTimeline(context, theme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/report'),
        icon: const Icon(Icons.add_chart),
        label: const Text('New Report'),
      ),
    );
  }

  Widget _buildProfileGrid(BuildContext context, SectionModel section, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          children: [
            _buildGridItem('Area', '${section.areaHectares} ha', theme),
            _buildGridItem('Clone', section.clone, theme),
            _buildGridItem('Plant Year', '${section.plantYear}', theme),
            _buildGridItem('Last Plucked', '${section.lastPluckedDaysAgo} days ago', theme),
            _buildGridItem('Est. Yield', '${section.estimatedYieldKg} kg', theme),
            _buildGridItem('Prune Cycle', 'Year 2 of 4', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTimeline(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildTimelineItem(
            'Field Report Submitted', 'Today, 8:45 AM', 'Binod Oraon', Icons.assignment, theme),
        _buildTimelineItem(
            'Task Assigned: Spraying', 'Yesterday, 5:30 PM', 'Rajesh Sharma', Icons.task, theme),
        _buildTimelineItem(
            'Status changed to Active', '2 days ago', 'Rajesh Sharma', Icons.update, theme),
      ],
    );
  }

  Widget _buildTimelineItem(
      String title, String time, String user, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$time • $user',
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
}
