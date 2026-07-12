import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/section_repository.dart';

class CreateSectionScreen extends ConsumerStatefulWidget {
  const CreateSectionScreen({super.key});

  @override
  ConsumerState<CreateSectionScreen> createState() => _CreateSectionScreenState();
}

class _CreateSectionScreenState extends ConsumerState<CreateSectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _cloneController = TextEditingController();
  final _plantYearController = TextEditingController();
  final _yieldController = TextEditingController();
  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final repository = ref.read(sectionRepositoryProvider);
      
      await repository.createSection(
        name: _nameController.text.trim(),
        areaHectares: double.parse(_areaController.text.trim()),
        clone: _cloneController.text.trim(),
        plantYear: int.parse(_plantYearController.text.trim()),
        estimatedYieldKg: int.parse(_yieldController.text.trim()),
      );
      
      if (mounted) {
        ref.invalidate(sectionsProvider); // Invalidate the sections provider so dropdowns refresh
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Section created successfully!')));
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
    _nameController.dispose();
    _areaController.dispose();
    _cloneController.dispose();
    _plantYearController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Section'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Section Name',
                      hintText: 'e.g. 10A, 4B',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _areaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Area (Hectares)',
                      hintText: 'e.g. 15.5',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cloneController,
                    decoration: const InputDecoration(
                      labelText: 'Clone Type',
                      hintText: 'e.g. TV1, S3A3',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _plantYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Plant Year',
                      hintText: 'e.g. 2005',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Must be an integer';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yieldController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Yield (kg)',
                      hintText: 'e.g. 4500',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Must be an integer';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('CREATE SECTION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
