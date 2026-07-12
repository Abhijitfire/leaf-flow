import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/attendance/data/repositories/attendance_repository.dart';
import '../../domain/models/worker_model.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _searchWorker() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(attendanceRepositoryProvider);
      final worker = await repository.searchWorker(query);
      
      if (!mounted) return;

      if (worker != null) {
        // Strict Validation: Only allow workers marked present for PLUCKING today
        final isPresentInPlucking = await repository.isWorkerInPluckingPlanToday(worker.id);
        
        if (!mounted) return;
        
        if (!isPresentInPlucking) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${worker.name} (${worker.id}) is not marked present for a Plucking plan today.')),
          );
          return;
        }
        
        context.pushReplacement('/weighing/entry', extra: worker);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker not found')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      appBar: AppBar(
        title: const Text('Find Worker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.badge, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Enter PF Number or Phone',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Autocomplete<Worker>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Worker>.empty();
                }
                final repository = ref.read(attendanceRepositoryProvider);
                final allWorkers = await repository.searchWorkers(textEditingValue.text);
                
                final presentWorkers = <Worker>[];
                for (var w in allWorkers) {
                  final isPresentInPlucking = await repository.isWorkerInPluckingPlanToday(w.id);
                  if (isPresentInPlucking) {
                    presentWorkers.add(w);
                  }
                }
                return presentWorkers;
              },
              displayStringForOption: (Worker option) => option.id,
              onSelected: (Worker selection) {
                _controller.text = selection.id;
                _searchWorker();
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                // Keep our _controller in sync if needed, but it's better to just use their controller for submission
                _controller.text = controller.text;
                controller.addListener(() {
                  _controller.text = controller.text;
                });
                
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'e.g. PF-1042 or Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 24),
                  ),
                  onSubmitted: (_) {
                    onEditingComplete();
                    _searchWorker();
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 300,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${option.id} • ${option.phoneNumber}'),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 64,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _searchWorker,
                icon: _isLoading 
                    ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white))
                    : const Icon(Icons.search, size: 28),
                label: const Text('SEARCH', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

