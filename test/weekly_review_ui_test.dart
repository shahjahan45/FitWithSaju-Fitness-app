import 'package:fitwithsaju/core/settings/app_preferences.dart';
import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/features/review/weekly_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final anchorDate = DateTime(2026, 10, 15);

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppPreferences.initialize();
    await AppPreferences.setReduceMotion(true);
    await LocalStore.addWorkoutHistory(<String, dynamic>{
      'id': 'weekly-review-test-session',
      'title': 'Upper Body',
      'date': '2026-10-14T18:00:00',
      'durationMinutes': '52',
      'completedSets': '14',
      'totalVolume': '5600',
      'prCount': '1',
      'sets': <Map<String, dynamic>>[],
    });
    await LocalStore.saveReadinessCheckIn(
      date: anchorDate,
      sleepQuality: 4,
      energy: 4,
      soreness: 2,
      stress: 2,
    );
  });

  testWidgets('weekly review renders safely with reduced motion', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          disableAnimations: true,
          viewPadding: EdgeInsets.only(bottom: 24),
        ),
        child: MaterialApp(
          theme: AppTheme.light,
          home: WeeklyReviewScreen(anchorDate: anchorDate),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('weekly-review-scroll')), findsOneWidget);
    expect(find.byKey(const Key('weekly-review-hero')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final list = find.byKey(const Key('weekly-review-scroll'));
    for (var attempt = 0;
        attempt < 6 &&
            find.byKey(const Key('weekly-review-disclaimer')).evaluate().isEmpty;
        attempt++) {
      await tester.drag(list, const Offset(0, -220));
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const Key('weekly-review-guidance')), findsOneWidget);
    expect(find.byKey(const Key('weekly-review-disclaimer')), findsOneWidget);
    expect(find.textContaining('not medical or clinical'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
