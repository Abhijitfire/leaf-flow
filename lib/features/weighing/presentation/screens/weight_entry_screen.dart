import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/worker_model.dart';
import '../../data/repositories/weighing_repository.dart';

class WeightEntryScreen extends ConsumerStatefulWidget {
  final Worker worker;
  const WeightEntryScreen({super.key, required this.worker});

  @override
  ConsumerState<WeightEntryScreen> createState() => _WeightEntryScreenState();
}

class _WeightEntryScreenState extends ConsumerState<WeightEntryScreen> {
  String _weightInput = '';
  bool _showSuccess = false;
  bool _isSaving = false;

  void _onKeyPress(String value) {
    if (_isSaving) return;
    setState(() {
      if (value == 'C') {
        _weightInput = '';
      } else if (value == '.' && _weightInput.contains('.')) {
        return;
      } else if (_weightInput.length < 5) {
        _weightInput += value;
      }
    });
  }

  void _onSave() async {
    if (_weightInput.isEmpty) return;
    
    final enteredWeight = double.tryParse(_weightInput);
    if (enteredWeight == null || enteredWeight <= 0) return;

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(weighingRepositoryProvider);
      await repository.submitHarvest(widget.worker, enteredWeight);

      if (!mounted) return;
      setState(() {
        _showSuccess = true;
        _isSaving = false;
      });
      
      // Flash for 1 second, then return to dashboard
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        context.pop(); // pop entry screen
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 120, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                'SAVED',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final double enteredWeight = double.tryParse(_weightInput) ?? 0.0;
    final double incentive = enteredWeight - widget.worker.dailyQuotaKg;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Weight'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: Column(
          children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.worker.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    Text(
                      '${widget.worker.id} • ${widget.worker.dafaId}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Target: ${widget.worker.dailyQuotaKg} kg',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Display
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _weightInput.isEmpty ? '0.0' : _weightInput,
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Text('kilograms', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  const SizedBox(height: 16),
                  if (enteredWeight > 0)
                    Text(
                      incentive > 0
                          ? '+${incentive.toStringAsFixed(1)} kg Bonus'
                          : 'Under Quota',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: incentive > 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Numpad
          Expanded(
            flex: 5,
            child: SafeArea(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(child: _buildRow(['7', '8', '9'])),
                  Expanded(child: _buildRow(['4', '5', '6'])),
                  Expanded(child: _buildRow(['1', '2', '3'])),
                  Expanded(child: _buildRow(['C', '0', '.'])),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 80,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _onSave,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isSaving 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'CONFIRM & SAVE',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        )],
      ),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: keys.map((k) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: k == 'C'
                ? FilledButton.tonal(
                    onPressed: () => _onKeyPress(k),
                    child: Text(k, style: const TextStyle(fontSize: 32, color: Colors.red)),
                  )
                : OutlinedButton(
                    onPressed: () => _onKeyPress(k),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Text(
                      k,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }
}
