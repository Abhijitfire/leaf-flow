import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/weighing_repository.dart';

class DispatchScreen extends ConsumerStatefulWidget {
  const DispatchScreen({super.key});

  @override
  ConsumerState<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends ConsumerState<DispatchScreen> {
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _driverController = TextEditingController();
  bool _isSubmitting = false;
  
  Future<void> _submitDispatch(double totalWeightKg) async {
    if (_vehicleController.text.isEmpty || _driverController.text.isEmpty) return;
    
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(weighingRepositoryProvider);
      await repo.dispatchFactory(
        totalWeightKg: totalWeightKg,
        vehicleNumber: _vehicleController.text.trim(),
        driverName: _driverController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leaf dispatched to factory successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(weighingStatsProvider);
    final formatter = NumberFormat("#,##0", "en_US");
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Transport'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Total Leaf Ready for Factory', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    statsAsync.when(
                      data: (stats) => Text(
                        '${formatter.format(stats.totalKg)} kg',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => const Text('Error loading stats'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _vehicleController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number (e.g. WB-74-A-1234)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_shipping),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _driverController,
              decoration: const InputDecoration(
                labelText: 'Driver Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 64,
              child: FilledButton.icon(
                onPressed: _isSubmitting || !statsAsync.hasValue
                    ? null
                    : () => _submitDispatch(statsAsync.value!.totalKg),
                icon: const Icon(Icons.send),
                label: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CONFIRM DISPATCH',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
