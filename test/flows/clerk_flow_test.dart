import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafflow/features/weighing/presentation/screens/weighing_dashboard.dart';
import 'package:leafflow/features/weighing/data/repositories/weighing_repository.dart';
import 'package:leafflow/core/l10n/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Clerk Flow: Weighing Dashboard loads stats correctly', (WidgetTester tester) async {
    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({'language_code': 'en'});
    final prefs = await SharedPreferences.getInstance();

    // 2. Mock Data
    const mockStats = WeighingStats(
      totalKg: 1250.5,
      workersProcessed: 42,
    );

    // 3. Pump App directly with Overrides
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          weighingStatsProvider.overrideWith((ref) => Future.value(mockStats)),
        ],
        child: const MaterialApp(
          home: WeighingDashboardScreen(),
        ),
      ),
    );

    // Wait for async providers and animations
    await tester.pumpAndSettle();

    // 4. Verification
    
    // Check if the values are loaded and formatted correctly
    expect(find.text('1250.5 kg'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);

    // Check if action buttons exist
    expect(find.byIcon(Icons.badge), findsOneWidget); // Scan button
    expect(find.byIcon(Icons.local_shipping), findsOneWidget); // Dispatch button
  });
}
