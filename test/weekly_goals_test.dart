import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/features/goals/data/weekly_goal_calculator.dart';
import 'package:fitwithsaju/features/goals/data/weekly_goal_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('weekly goals calculate real progress for the current Monday-Sunday week', () {
    const targets = WeeklyGoalTargets(
      workouts: 4,
      trainingMinutes: 180,
      hydrationDays: 5,
      readinessDays: 5,
    );
    final snapshot = WeeklyGoalCalculator.calculate(
      anchorDate: DateTime(2026, 10, 4),
      targets: targets,
      workoutHistory: <Map<String, dynamic>>[
        {'date': '2026-09-29T18:00:00', 'durationMinutes': 55},
        {'date': '2026-10-01T18:00:00', 'durationMinutes': '45'},
        {'date': '2026-10-03T18:00:00', 'durationMinutes': 50},
        {'date': '2026-09-23T18:00:00', 'durationMinutes': 60},
      ],
      readinessDateKeys: <String>{
        '2026-09-29',
        '2026-10-01',
        '2026-10-02',
        '2026-10-03',
      },
      waterTotalsByDate: <String, int>{
        '2026-09-29': 2500,
        '2026-09-30': 2600,
        '2026-10-01': 2400,
        '2026-10-02': 2800,
        '2026-10-03': 2500,
      },
      waterTargetMl: 2500,
    );

    expect(snapshot.workouts.current, 3);
    expect(snapshot.trainingMinutes.current, 150);
    expect(snapshot.hydrationDays.current, 4);
    expect(snapshot.readinessDays.current, 4);
    expect(snapshot.weekStart, DateTime(2026, 9, 28));
    expect(snapshot.weekEnd, DateTime(2026, 10, 4));
    expect(snapshot.overallProgress, inInclusiveRange(0, 1));
  });

  test('weekly goal calculator safely accepts legacy string durations', () {
    const targets = WeeklyGoalTargets(
      workouts: 1,
      trainingMinutes: 30,
      hydrationDays: 1,
      readinessDays: 1,
    );
    final snapshot = WeeklyGoalCalculator.calculate(
      anchorDate: DateTime(2026, 10, 4),
      targets: targets,
      workoutHistory: <Map<String, dynamic>>[
        {'date': '2026-10-04T10:00:00', 'durationMinutes': '75'},
      ],
      readinessDateKeys: const <String>{'2026-10-04'},
      waterTotalsByDate: const <String, int>{'2026-10-04': 2500},
      waterTargetMl: 2500,
    );

    expect(snapshot.trainingMinutes.current, 75);
    expect(snapshot.goalsMet, 4);
  });

  test('weekly goals persist and participate in backup restore', () async {
    await LocalStore.saveWeeklyGoals(
      workouts: 5,
      trainingMinutes: 240,
      hydrationDays: 6,
      readinessDays: 4,
    );

    final backup = await LocalStore.exportData();
    expect(backup['formatVersion'], 7);
    expect((backup['weeklyGoals'] as Map)['workouts'], 5);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LocalStore.importData(backup);
    final restored = await LocalStore.weeklyGoals();
    expect(restored['workouts'], 5);
    expect(restored['trainingMinutes'], 240);
    expect(restored['hydrationDays'], 6);
    expect(restored['readinessDays'], 4);
  });

  test('weekly goal persistence clamps unsafe values', () async {
    await LocalStore.saveWeeklyGoals(
      workouts: 99,
      trainingMinutes: -5,
      hydrationDays: 0,
      readinessDays: 20,
    );
    final stored = await LocalStore.weeklyGoals();
    expect(stored['workouts'], 7);
    expect(stored['trainingMinutes'], 30);
    expect(stored['hydrationDays'], 1);
    expect(stored['readinessDays'], 7);
  });
}
