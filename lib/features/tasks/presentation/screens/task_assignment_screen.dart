import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/estate_plan_repository.dart';
import '../../../sections/data/repositories/section_repository.dart';
import '../../../../core/services/supabase_service.dart';

final dafasProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase.from('dafas').select('id, name');
  return List<Map<String, dynamic>>.from(response);
});

class TaskAssignmentScreen extends ConsumerStatefulWidget {
  const TaskAssignmentScreen({super.key});

  @override
  ConsumerState<TaskAssignmentScreen> createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends ConsumerState<TaskAssignmentScreen> {
  String? _selectedSectionId;
  String _taskType = 'Plucking';
  String _pluckingStandard = 'Fine';
  String? _assignedDafaId;
  final _targetController = TextEditingController(text: '3500');
  bool _isSaving = false;

  Future<void> _createPlan() async {
    if (_selectedSectionId == null || _assignedDafaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select section and dafa')));
      return;
    }
    
    setState(() => _isSaving = true);
    try {
      String targetUnit = 'kg';
      Map<String, dynamic> metadata = {};

      if (_taskType == 'Plucking') {
        targetUnit = 'kg';
        metadata = {'plucking_standard': _pluckingStandard};
      } else if (_taskType == 'Pruning') {
        targetUnit = 'bushes';
      } else {
        targetUnit = 'hectares';
      }

      final repository = ref.read(estatePlanRepositoryProvider);
      
      await repository.createEstatePlan(
        sectionId: _selectedSectionId!,
        dafaId: _assignedDafaId!,
        targetValue: _targetController.text,
        taskType: _taskType,
        targetUnit: targetUnit,
        metadata: metadata,
      );
      
      if (mounted) {
        ref.invalidate(activeEstatePlansProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estate Plan created successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sectionsAsync = ref.watch(sectionsProvider);
    final dafasAsync = ref.watch(dafasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Estate Plan'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Section', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            sectionsAsync.when(
              data: (sections) => DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedSectionId,
                hint: const Text('Select a section'),
                items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedSectionId = val),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
            ),
            
            const SizedBox(height: 24),
            Text('Task Type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChoiceChip('Plucking', '🍃', theme),
                _buildChoiceChip('Pruning', '✂️', theme),
                _buildChoiceChip('Weeding', '🌿', theme),
                _buildChoiceChip('Spraying', '💊', theme),
              ],
            ),

            if (_taskType == 'Plucking') ...[
              const SizedBox(height: 24),
              Text('Plucking Standard', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Fine', label: Text('Fine')),
                  ButtonSegment(value: 'Medium', label: Text('Medium')),
                  ButtonSegment(value: 'Coarse', label: Text('Coarse')),
                ],
                selected: {_pluckingStandard},
                onSelectionChanged: (val) => setState(() => _pluckingStandard = val.first),
              ),
            ],

            const SizedBox(height: 24),
            Text('Assign Dafa (Gang)', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            dafasAsync.when(
              data: (dafas) {
                if (dafas.isEmpty) {
                  return const Text('No dafas found in database. Please run the seed script.', style: TextStyle(color: Colors.red));
                }
                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _assignedDafaId,
                  hint: const Text(
                    'Select a dafa to automatically assign its Sardar',
                    overflow: TextOverflow.ellipsis,
                  ),
                  items: dafas.map((d) => DropdownMenuItem(value: d['id'] as String, child: Text(d['name'] as String, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) => setState(() => _assignedDafaId = val),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
            ),

            const SizedBox(height: 24),
            Text(
              _taskType == 'Plucking'
                  ? 'Target Harvest (kg)'
                  : _taskType == 'Pruning'
                      ? 'Target Bushes'
                      : 'Target Area (Hectares)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixText: _taskType == 'Plucking'
                    ? 'kg'
                    : _taskType == 'Pruning'
                        ? 'bushes'
                        : 'ha',
              ),
            ),

            const SizedBox(height: 32),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isSaving ? null : _createPlan,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('PUBLISH PLAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, String emoji, ThemeData theme) {
    final isSelected = _taskType == label;
    return FilterChip(
      selected: isSelected,
      label: Text('$emoji $label'),
      onSelected: (bool selected) {
        if (selected) {
          setState(() => _taskType = label);
        }
      },
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}
