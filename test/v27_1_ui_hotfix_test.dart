import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/explore/explore_screen.dart';
import 'package:fitwithsaju/features/more/measurements_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('standalone Explore screen supplies Material for search input', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ExploreScreen(showBackButton: true),
      ),
    );
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('measurement sheet keeps save action inside bottom SafeArea', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MeasurementsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add measurements'));
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(
      FilledButton,
      'Save Measurements',
    );
    expect(saveButton, findsOneWidget);

    final safeAreas = tester.widgetList<SafeArea>(
      find.ancestor(of: saveButton, matching: find.byType(SafeArea)),
    );
    expect(
      safeAreas.any(
        (safeArea) =>
            safeArea.bottom && safeArea.maintainBottomViewPadding,
      ),
      isTrue,
    );

    await tester.enterText(find.byType(TextField).first, '102.5');
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final entries = await LocalStore.measurementEntries();
    expect(entries, hasLength(1));
    expect(entries.first['chest'], 102.5);
    expect(tester.takeException(), isNull);
  });
}
