import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../domain/models/attendance_model.dart';

class AttendanceScannerScreen extends ConsumerStatefulWidget {
  final String? initialPlanId;

  const AttendanceScannerScreen({super.key, this.initialPlanId});

  @override
  ConsumerState<AttendanceScannerScreen> createState() =>
      _AttendanceScannerScreenState();
}

class _AttendanceScannerScreenState
    extends ConsumerState<AttendanceScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _markPresent() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(attendanceRepositoryProvider);
      final worker = await repository.searchWorker(query);

      if (worker == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Worker not found')));
        }
        return;
      }

      if (widget.initialPlanId == null || widget.initialPlanId!.isEmpty) {
        if (mounted) Navigator.of(context).pop(worker.id);
        return;
      }

      final record = AttendanceModel(
        planId: widget.initialPlanId!,
        workerId: worker.id,
        recordDate: DateTime.now(),
        isPresent: true,
        createdAt: DateTime.now(),
      );

      await repository.submitAttendance([record]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked present and synced')),
        );
        Navigator.of(context).pop(worker.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mark Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.co_present, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Enter PF Number or Phone',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'e.g. 9876543210',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 24),
              ),
              onSubmitted: (_) => _markPresent(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 64,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _markPresent,
                icon: const Icon(Icons.check_circle, size: 28),
                label: Text(
                  _isSubmitting ? 'MARKING...' : 'MARK PRESENT',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
