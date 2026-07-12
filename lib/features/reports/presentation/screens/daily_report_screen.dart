import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DailyReportScreen extends ConsumerStatefulWidget {
  const DailyReportScreen({super.key});

  @override
  ConsumerState<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends ConsumerState<DailyReportScreen> {
  int _currentStep = 0;
  
  // Form State
  int _workersPresent = 12;
  double _leafEstimate = 200;
  String _pluckingStandard = 'Fine';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Report: Section 14'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            // Submit
            _showSuccessBottomSheet();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep == 2 ? 'SUBMIT REPORT' : 'NEXT'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('BACK'),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Attendance'),
            content: _buildAttendanceStep(theme),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Estimate'),
            content: _buildEstimateStep(theme),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Review'),
            content: _buildReviewStep(theme),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How many workers are present today?',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepperButton(Icons.remove, () {
              if (_workersPresent > 0) setState(() => _workersPresent--);
            }),
            Container(
              width: 100,
              alignment: Alignment.center,
              child: Text(
                '$_workersPresent',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            _buildStepperButton(Icons.add, () {
              setState(() => _workersPresent++);
            }),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Assigned: 12 workers',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimateStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimated Leaf Collection (kg)',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 32),
        Slider(
          value: _leafEstimate,
          min: 0,
          max: 1000,
          divisions: 20,
          label: '${_leafEstimate.round()} kg',
          onChanged: (value) {
            setState(() => _leafEstimate = value);
          },
        ),
        Center(
          child: Text(
            '${_leafEstimate.round()} kg',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Plucking Standard',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Fine', label: Text('Fine')),
            ButtonSegment(value: 'Medium', label: Text('Medium')),
            ButtonSegment(value: 'Coarse', label: Text('Coarse')),
          ],
          selected: {_pluckingStandard},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() => _pluckingStandard = newSelection.first);
          },
        ),
      ],
    );
  }

  Widget _buildReviewStep(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildReviewRow('Section', 'Section 14 - Valley', theme),
            const Divider(height: 24),
            _buildReviewRow('Workers Present', '$_workersPresent / 12', theme),
            const Divider(height: 24),
            _buildReviewRow('Leaf Estimate', '${_leafEstimate.round()} kg', theme),
            const Divider(height: 24),
            _buildReviewRow('Standard', _pluckingStandard, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Report Saved!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saved locally. Will sync when online.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.pop(); // Close sheet
                context.pop(); // Close screen
              },
              child: const Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }
}
