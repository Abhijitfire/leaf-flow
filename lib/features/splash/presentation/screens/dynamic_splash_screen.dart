import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/routing/app_router.dart';

class DynamicSplashScreen extends ConsumerStatefulWidget {
  const DynamicSplashScreen({super.key});

  @override
  ConsumerState<DynamicSplashScreen> createState() => _DynamicSplashScreenState();
}

class _DynamicSplashScreenState extends ConsumerState<DynamicSplashScreen> {
  String _splashMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      
      // Attempt to fetch dynamic splash message with a short timeout
      final response = await supabase
          .from('app_config')
          .select('value')
          .eq('key', 'splash_message')
          .maybeSingle()
          .timeout(const Duration(seconds: 3));
          
      if (response != null && mounted) {
        setState(() {
          _splashMessage = response['value'] as String;
        });
      }
    } catch (e) {
      debugPrint('Failed to load dynamic config: $e');
      if (mounted) {
        setState(() {
          _splashMessage = 'Welcome to LeafFlow'; // Fallback
        });
      }
    }
    
    // Hold splash screen for a moment to show the logo and animation
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      // Determine routing based on current auth state
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        context.go('/login');
      } else {
        final role = getCachedUserRole() ?? session.user.userMetadata?['role'] as String?;
        if (role == 'manager') {
          context.go('/manager');
        } else if (role == 'supervisor') {
          context.go('/supervisor');
        } else if (role == 'clerk') {
          context.go('/clerk');
        } else {
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ).animate()
             .scale(duration: 600.ms, curve: Curves.easeOutBack)
             .then()
             .shimmer(duration: 1200.ms),
             
            const SizedBox(height: 32),
            
            Text(
              _splashMessage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate()
             .fade(delay: 400.ms, duration: 600.ms)
             .slideY(begin: 0.2, end: 0),
             
            const SizedBox(height: 48),
            
            const CircularProgressIndicator()
             .animate()
             .fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
