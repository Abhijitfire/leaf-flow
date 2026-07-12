import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafflow/features/dashboard/presentation/screens/manager_dashboard.dart';
import 'package:leafflow/features/dashboard/data/repositories/manager_stats_repository.dart';
import 'package:leafflow/features/sections/domain/models/section_model.dart';
import 'package:leafflow/features/sections/data/repositories/section_repository.dart';
import 'package:leafflow/core/l10n/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Manager Flow: Dashboard loads and displays KPI cards', (WidgetTester tester) async {
    // 1. Setup Mock SharedPreferences
    SharedPreferences.setMockInitialValues({'cached_user_role': 'manager'});
    final prefs = await SharedPreferences.getInstance();

    // 2. Setup Mock Providers
    final mockStats = const ManagerStats(
      todayTargetKg: 5000,
      todayHarvestKg: 2500,
      workersPresent: 150,
      pendingSections: 3,
    );
    
    final List<SectionModel> mockSections = [
      SectionModel(
        id: '1',
        name: 'Test Section Alpha',
        areaHectares: 12.5,
        plantYear: 2010,
        clone: 'TV1',
        status: 'active',
        estimatedYieldKg: 1200,
        lastPluckedDaysAgo: 10,
      ),
    ];

    // 3. Pump the App directly (Bypassing Router and AuthWrapper)
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          managerStatsProvider.overrideWith((ref) => Future.value(mockStats)),
          sectionsProvider.overrideWith((ref) => Future.value(mockSections)),
        ],
        child: const MaterialApp(
          home: ManagerDashboard(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 4. Verify UI Elements
    expect(find.byType(ManagerDashboard), findsOneWidget);
    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('Workers Present'), findsOneWidget);
    
    expect(find.text('2,500'), findsOneWidget); 
    expect(find.text('Target: 5,000 kg'), findsOneWidget); 
    expect(find.text('50.0% Achieved'), findsOneWidget); 
    
    expect(find.text('Test Section Alpha'), findsOneWidget);
    expect(find.text('Overdue by 3 days'), findsOneWidget);

  });
}
