import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/repositories/section_repository.dart';

class LogInspectionScreen extends ConsumerStatefulWidget {
  final String? initialSectionId;
  
  const LogInspectionScreen({
    super.key,
    this.initialSectionId,
  });

  @override
  ConsumerState<LogInspectionScreen> createState() => _LogInspectionScreenState();
}

class _LogInspectionScreenState extends ConsumerState<LogInspectionScreen> {
  String? _selectedSectionId;
  bool _pestSpotted = false;
  bool _diseaseSpotted = false;
  final _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedSectionId = widget.initialSectionId;
  }

  Future<void> _submitInspection() async {
    if (_selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a section')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      await supabase.from('inspections').insert({
        'section_id': _selectedSectionId,
        'supervisor_id': user.id,
        'inspection_date': DateTime.now().toIso8601String().split('T').first,
        'pest_spotted': _pestSpotted,
        'disease_spotted': _diseaseSpotted,
        'notes': _notesController.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inspection logged successfully!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging inspection: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(sectionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Field Inspection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Section', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            sectionsAsync.when(
              data: (sections) => DropdownButtonFormField<String>(
                initialValue: _selectedSectionId,
                hint: const Text('Select a section'),
                items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedSectionId = val),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
            ),
            
            const SizedBox(height: 24),
            Text('Observations', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('Pests Spotted'),
              subtitle: const Text('E.g. Red Spider Mite, Tea Mosquito Bug'),
              value: _pestSpotted,
              onChanged: (val) => setState(() => _pestSpotted = val),
              secondary: const Icon(Icons.bug_report, color: Colors.redAccent),
            ),
            
            SwitchListTile(
              title: const Text('Disease Spotted'),
              subtitle: const Text('E.g. Blister Blight, Black Rot'),
              value: _diseaseSpotted,
              onChanged: (val) => setState(() => _diseaseSpotted = val),
              secondary: const Icon(Icons.coronavirus, color: Colors.orangeAccent),
            ),
            
            const SizedBox(height: 24),
            Text('Notes', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter any additional observations here...',
              ),
            ),
            
            const SizedBox(height: 32),
            SafeArea(
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isSaving ? null : _submitInspection,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SUBMIT REPORT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
