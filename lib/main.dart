import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/l10n/locale_provider.dart';

import 'dart:ui';
import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'core/database/app_database.dart';
import 'core/services/sync_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await dotenv.load(fileName: '.env');
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
        await Supabase.initialize(
          url: supabaseUrl,
          publishableKey: supabaseKey,
        );
      }

      final db = AppDatabase();
      final syncService = SyncService(Supabase.instance.client, db);
      await syncService.syncAttendanceUp();
      return Future.value(true);
    } catch (e) {
      debugPrint('Background sync failed: $e');
      return Future.value(false);
    }
  });
}

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Catch all Flutter framework errors
      FlutterError.onError = (details) {
        debugPrint('FlutterError: ${details.exceptionAsString()}');
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Platform error: $error');
        return true;
      };

      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        debugPrint('dotenv load failed: $e — using fallback');
      }

      // Initialize Supabase
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
        try {
          await Supabase.initialize(
            url: supabaseUrl,
            publishableKey: supabaseKey,
          );
        } catch (e) {
          debugPrint('Supabase initialization failed: $e');
        }
      } else {
        debugPrint('WARNING: SUPABASE_URL or SUPABASE_ANON_KEY is empty!');
      }

      final prefs = await SharedPreferences.getInstance();

      final savedRole = prefs.getString('cached_user_role');
      if (savedRole != null) {
        setCachedUserRole(savedRole);
      }

      try {
        await Workmanager().initialize(callbackDispatcher);
        await Workmanager().registerPeriodicTask(
          'sync_attendance',
          'syncAttendanceTask',
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
        );
      } catch (e) {
        debugPrint(
          'Workmanager init failed (may not be supported on this platform): $e',
        );
      }

      runApp(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const LeafFlowApp(),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('runZonedGuarded Caught Error: $error');
      runApp(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.red[900],
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Text(
                    'FATAL ERROR:\n\n$error\n\n$stackTrace',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class LeafFlowApp extends ConsumerWidget {
  const LeafFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'LeafFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Force light mode to match the Figma design
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
