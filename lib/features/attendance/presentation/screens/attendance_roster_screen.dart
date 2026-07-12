import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../weighing/domain/models/worker_model.dart';
import 'attendance_scanner_screen.dart';
import '../../domain/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../tasks/domain/models/estate_plan_model.dart';

class AttendanceRosterScreen extends ConsumerStatefulWidget {
  final EstatePlanModel plan;

  const AttendanceRosterScreen({super.key, required this.plan});

  @override
  ConsumerState<AttendanceRosterScreen> createState() =>
      _AttendanceRosterScreenState();
}

class _AttendanceRosterScreenState
    extends ConsumerState<AttendanceRosterScreen> {
  // We'll track who is marked ABSENT. Everyone else is assumed PRESENT.
  final Set<String> _absentIds = {};
  final List<Worker> _badliWorkers = [];
  bool _isSubmitting = false;

  void _toggleAttendance(String id, bool? isPresent) {
    setState(() {
      if (isPresent == true) {
        _absentIds.remove(id);
      } else {
        _absentIds.add(id);
      }
    });
  }

  void _addSubstitute() {
    final queryController = TextEditingController();
    bool isSearching = false;
    Worker? foundWorker;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Badli Worker'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: queryController,
                  decoration: InputDecoration(
                    labelText: 'PF Number or Phone',
                    hintText: 'e.g. PF-2001',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                if (isSearching) ...[
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
                if (foundWorker != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        foundWorker!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${foundWorker!.id} • ${foundWorker!.dafaId}',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL'),
              ),
              if (foundWorker == null)
                FilledButton(
                  onPressed: isSearching
                      ? null
                      : () async {
                          if (queryController.text.trim().isEmpty) return;
                          setDialogState(() {
                            isSearching = true;
                            errorMessage = null;
                            foundWorker = null;
                          });

                          final worker = await ref
                              .read(attendanceRepositoryProvider)
                              .searchWorker(queryController.text.trim());

                          setDialogState(() {
                            isSearching = false;
                            if (worker == null) {
                              errorMessage = 'Worker not found.';
                            } else {
                              foundWorker = worker;
                            }
                          });
                        },
                  child: const Text('SEARCH'),
                )
              else
                FilledButton(
                  onPressed: () {
                    // Check if already in badli list to avoid duplicates
                    if (!_badliWorkers.any((w) => w.id == foundWorker!.id)) {
                      setState(() {
                        _badliWorkers.add(foundWorker!);
                        // Ensure they are marked present
                        _absentIds.remove(foundWorker!.id);
                      });
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text('ADD TO ROSTER'),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitHazira(List<Worker> roster) async {
    setState(() => _isSubmitting = true);

    try {
      final activePlanId = widget.plan.id;

      final records = roster
          .map(
            (worker) => AttendanceModel(
              planId: activePlanId,
              workerId: worker.id,
              recordDate: DateTime.now(),
              isPresent: !_absentIds.contains(worker.id),
              createdAt: DateTime.now(),
            ),
          )
          .toList();

      await ref.read(attendanceRepositoryProvider).submitAttendance(records);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hazira successfully synced to cloud!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = ref.watch(appTranslationsProvider);
    final rosterAsync = ref.watch(rosterWorkersProvider(widget.plan));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('attendance_roster')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search ID/Phone',
            onPressed: () async {
              // Open scanner without plan context; if scanner returns a worker id, mark them present locally
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AttendanceScannerScreen(),
                ),
              );

              if (result is String) {
                setState(() {
                  _absentIds.remove(result);
                });
              }
            },
          ),
        ],
      ),
      body: rosterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (baseRoster) {
          final roster = [...baseRoster, ..._badliWorkers];

          if (roster.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workers found for this dafa.',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ensure workers are assigned in the database.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _addSubstitute,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Badli Worker'),
                  ),
                ],
              ),
            );
          }

          final presentCount = roster.length - _absentIds.length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${t.translate('present')}: $presentCount / ${roster.length}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addSubstitute,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Worker'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: roster.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemBuilder: (context, index) {
                    final worker = roster[index];
                    final isPresent = !_absentIds.contains(worker.id);
                    final isBadli = _badliWorkers.any((w) => w.id == worker.id);

                    return Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPresent
                                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                  : theme.colorScheme.outline.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isPresent
                                    ? theme.colorScheme.primary.withValues(
                                        alpha: 0.08,
                                      )
                                    : Colors.black.withValues(alpha: 0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CheckboxListTile(
                            value: isPresent,
                            onChanged: (val) =>
                                _toggleAttendance(worker.id, val),
                            title: Row(
                              children: [
                                Text(
                                  worker.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isBadli) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.colorScheme.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Badli',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .colorScheme
                                            .onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              'ID: ${worker.id} • ${worker.dafaId}',
                            ),
                            secondary: CircleAvatar(
                              backgroundColor: isPresent
                                  ? (isBadli
                                        ? theme.colorScheme.tertiary
                                        : theme.colorScheme.primary)
                                  : Colors.grey.shade300,
                              foregroundColor: isPresent
                                  ? (isBadli
                                        ? theme.colorScheme.onTertiary
                                        : theme.colorScheme.onPrimary)
                                  : Colors.black54,
                              child: Icon(
                                isPresent ? Icons.check : Icons.person_off,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fade(delay: (50 * index).ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submitHazira(roster),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              t.translate('submit_hazira').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
