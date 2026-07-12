import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';

class WorkerManagementScreen extends ConsumerStatefulWidget {
  const WorkerManagementScreen({super.key});

  @override
  ConsumerState<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends ConsumerState<WorkerManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pfController = TextEditingController();
  final _nameController = TextEditingController();
  final _dafaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _quotaController = TextEditingController(text: '20.0');
  
  bool _isSaving = false;

  Future<void> _addWorker() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final supabase = ref.read(supabaseClientProvider);
      
      await supabase.from('workers').insert({
        'pf_number': _pfController.text.trim(),
        'full_name': _nameController.text.trim(),
        'dafa_id': _dafaController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'daily_quota_kg': double.tryParse(_quotaController.text.trim()) ?? 20.0,
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worker added successfully!')),
      );
      
      _formKey.currentState!.reset();
      _pfController.clear();
      _nameController.clear();
      _dafaController.clear();
      _phoneController.clear();
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding worker: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _pfController.dispose();
    _nameController.dispose();
    _dafaController.dispose();
    _phoneController.dispose();
    _quotaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Worker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _pfController,
                decoration: const InputDecoration(
                  labelText: 'PF Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dafaController,
                decoration: const InputDecoration(
                  labelText: 'Dafa ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quotaController,
                decoration: const InputDecoration(
                  labelText: 'Daily Quota (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isSaving ? null : _addWorker,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ADD WORKER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
