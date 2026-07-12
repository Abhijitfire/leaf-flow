import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/reports/presentation/screens/harvest_report_screen.dart';
import '../../features/reports/presentation/screens/payroll_report_screen.dart';
import '../../features/dashboard/presentation/screens/manager_dashboard.dart';
import '../../features/reports/presentation/screens/daily_report_screen.dart';
import '../../features/sections/presentation/screens/section_details_screen.dart';
import '../../features/sections/presentation/screens/log_inspection_screen.dart';
import '../../features/sections/presentation/screens/create_section_screen.dart';
import '../../features/tasks/presentation/screens/task_assignment_screen.dart';
import '../../features/tasks/presentation/screens/active_plans_screen.dart';
import '../../features/reports/presentation/screens/today_harvest_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/splash/presentation/screens/dynamic_splash_screen.dart';
import '../../features/tasks/domain/models/estate_plan_model.dart';
import '../../features/weighing/presentation/screens/weighing_dashboard.dart';
import '../../features/weighing/presentation/screens/scanner_screen.dart';
import '../../features/weighing/presentation/screens/weight_entry_screen.dart';
import '../../features/weighing/domain/models/worker_model.dart';
import '../../features/attendance/presentation/screens/supervisor_dashboard.dart';
import '../../features/attendance/presentation/screens/attendance_roster_screen.dart';
import '../../features/attendance/presentation/screens/attendance_scanner_screen.dart';
import '../../features/weighing/presentation/screens/dispatch_screen.dart';
import '../../features/workers/presentation/screens/worker_management_screen.dart';
import '../../features/attendance/presentation/screens/worker_submissions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cached user role — set by AuthWrapper after successful auth check.
/// This avoids a DB round-trip on every navigation.
String? _cachedUserRole;
String? getCachedUserRole() => _cachedUserRole;

void setCachedUserRole(String? role) {
  _cachedUserRole = role;
  // Persist to SharedPreferences so it survives background process death
  if (role != null) {
    SharedPreferences.getInstance().then((prefs) => prefs.setString('cached_user_role', role));
  } else {
    SharedPreferences.getInstance().then((prefs) => prefs.remove('cached_user_role'));
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final currentPath = state.uri.path;
    final isAuthRoute = currentPath == '/login' || currentPath == '/signup';
    final isSplash = currentPath == '/';

    // Not logged in → force to login (unless on auth route or splash screen)
    if (!isLoggedIn && !isAuthRoute && !isSplash) {
      return '/login';
    }

    // Logged in but on an auth route → redirect to home
    if (isLoggedIn && isAuthRoute) {
      return '/';
    }

    // Role-based route guard — prevent URL hopping
    if (isLoggedIn && _cachedUserRole != null) {
      final location = currentPath;

      // Manager-only routes
      const managerRoutes = ['/manager', '/workers/new', '/tasks/new', '/sections/new', '/task-assign', '/report', '/reports/harvest', '/reports/payroll', '/plans/active', '/harvest/today'];
      if (managerRoutes.contains(location) && _cachedUserRole != 'manager') {
        return '/'; // Bounce back to their own dashboard
      }

      // Supervisor-only routes
      const supervisorRoutes = ['/supervisor', '/supervisor/roster', '/supervisor/scan', '/inspections/new'];
      if (supervisorRoutes.contains(location) && !location.startsWith('/supervisor/submissions') && _cachedUserRole != 'supervisor') {
        return '/';
      }

      // Clerk-only routes
      const clerkRoutes = ['/weighing', '/weighing/scan', '/weighing/entry', '/weighing/dispatch'];
      if (clerkRoutes.contains(location) && _cachedUserRole != 'clerk') {
        return '/';
      }
    }

    return null; // No redirect needed
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const DynamicSplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      ),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),

    // --- Manager Routes ---
    GoRoute(
      path: '/manager',
      builder: (context, state) => const ManagerDashboard(),
    ),
    GoRoute(
      path: '/workers/new',
      builder: (context, state) => const WorkerManagementScreen(),
    ),
    GoRoute(
      path: '/tasks/new',
      builder: (context, state) => const TaskAssignmentScreen(),
    ),
    GoRoute(
      path: '/sections/new',
      builder: (context, state) => const CreateSectionScreen(),
    ),
    GoRoute(
      path: '/task-assign',
      builder: (context, state) => const TaskAssignmentScreen(),
    ),
    GoRoute(
      path: '/reports/harvest',
      builder: (context, state) => const HarvestReportScreen(),
    ),
    GoRoute(
      path: '/reports/payroll',
      builder: (context, state) => const PayrollReportScreen(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const DailyReportScreen(),
    ),
    GoRoute(
      path: '/section/:id',
      builder: (context, state) => SectionDetailsScreen(
        sectionId: state.pathParameters['id']!,
      ),
    ),

    GoRoute(
      path: '/plans/active',
      builder: (context, state) => const ActivePlansScreen(),
    ),
    GoRoute(
      path: '/harvest/today',
      builder: (context, state) => const TodayHarvestScreen(),
    ),

    // --- Supervisor Routes ---
    GoRoute(
      path: '/supervisor',
      builder: (context, state) => const SupervisorDashboard(),
    ),
    GoRoute(
      path: '/supervisor/roster',
      builder: (context, state) => AttendanceRosterScreen(
        plan: state.extra as EstatePlanModel,
      ),
    ),
    GoRoute(
      path: '/supervisor/scan',
      builder: (context, state) => const AttendanceScannerScreen(),
    ),
    GoRoute(
      path: '/inspections/new',
      builder: (context, state) => LogInspectionScreen(
        initialSectionId: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/supervisor/submissions/:planId',
      builder: (context, state) => WorkerSubmissionsScreen(
        planId: state.pathParameters['planId']!,
      ),
    ),

    // --- Clerk Routes ---
    GoRoute(
      path: '/weighing',
      builder: (context, state) => const WeighingDashboardScreen(),
    ),
    GoRoute(
      path: '/weighing/scan',
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/weighing/entry',
      builder: (context, state) => WeightEntryScreen(
        worker: state.extra as Worker,
      ),
    ),
    GoRoute(
      path: '/weighing/dispatch',
      builder: (context, state) => const DispatchScreen(),
    ),
  ],
);
