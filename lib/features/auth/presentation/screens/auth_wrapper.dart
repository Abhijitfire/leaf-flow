import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/routing/app_router.dart';
import '../../../dashboard/presentation/screens/manager_dashboard.dart';
import '../../../attendance/presentation/screens/supervisor_dashboard.dart';
import '../../../weighing/presentation/screens/weighing_dashboard.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isLoading = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkAuthAndRole();
  }

  Future<void> _checkAuthAndRole() async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setCachedUserRole(null);
        context.go('/login');
      }
      return;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single()
          .timeout(const Duration(seconds: 5));
          
      if (mounted) {
        final role = response['role'] as String?;
        setCachedUserRole(role); // Cache role for route guards
        setState(() {
          _role = role;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching role: $e');
      if (mounted) {
        // Fallback to supervisor if error
        setCachedUserRole('supervisor');
        setState(() {
          _role = 'supervisor';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (_role) {
      case 'manager':
        return const ManagerDashboard();
      case 'clerk':
        return const WeighingDashboardScreen();
      case 'supervisor':
      default:
        return const SupervisorDashboard();
    }
  }
}
