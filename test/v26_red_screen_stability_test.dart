import 'package:fitwithsaju/core/motion/motion_widgets.dart';
import 'package:fitwithsaju/core/settings/app_preferences.dart';
import 'package:fitwithsaju/core/theme/app_theme.dart';
import 'package:fitwithsaju/data/workout_program_schedule.dart';
import 'package:fitwithsaju/features/home/home_screen.dart';
import 'package:fitwithsaju/features/recovery/data/recovery_insights_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.initialize();
    await AppPreferences.setReduceMotion(true);
  });

  test('recovery insights tolerate legacy string training-volume values', () {
    final result = RecoveryInsightsCalculator.calculate(
      anchorDate: DateTime(2026, 9, 30),
      readinessHistory: const [],
      workoutHistory: <Map<String, dynamic>>[
        {
          'date': DateTime(2026, 9, 30).toIso8601String(),
          'totalVolume': '1250.5',
        },
        {
          'date': DateTime(2026, 9, 29).toIso8601String(),
          'sets': <Map<String, dynamic>>[
            {'volume': '400'},
            {'volume': 350},
          ],
        },
        {
          'date': DateTime(2026, 9, 28).toIso8601String(),
          'totalVolume': 'not-a-number',
        },
      ],
    );

    expect(result.last7Workouts, 3);
    expect(result.last7Volume, closeTo(2000.5, .001));
    expect(result.volume28, closeTo(2000.5, .001));
  });

  test('program calendar tolerates string duration fields from older backups',
      () {
    final entries = WorkoutProgramSchedule.build(
      activeProgram: <String, dynamic>{
        'programId': 'foundation',
        'durationWeeks': '4',
        'startedAt': DateTime(2026, 9, 28).toIso8601String(),
        'deloadWeeks': <dynamic>['4'],
      },
      weeklyPlan: <Map<String, dynamic>>[
        {
          'day': 'Monday',
          'title': 'Full Body',
          'isRest': false,
          'durationMinutes': '12',
          'exerciseIds': <String>['squat'],
        },
      ],
      history: const <Map<String, dynamic>>[],
      overrides: const <Map<String, dynamic>>[],
      now: DateTime(2026, 9, 30),
    );

    expect(entries.length, 28);
    final deloadMonday = entries.firstWhere(
      (entry) => entry.week == 4 && entry.day == 'Monday',
    );
    expect(deloadMonday.planForWorkout()['durationMinutes'], 9);
  });

  testWidgets('breathing glow supplies a Material ancestor safely',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const BreathingGlow(
          color: Colors.green,
          child: ListTile(title: Text('Safe tile')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Safe tile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home layout stays safe on a narrow Android-size viewport',
      (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 760),
          disableAnimations: true,
        ),
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
