import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/data/workout_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('weekly plan seeds seven days', () async {
    final plan = await LocalStore.weeklyPlan();
    expect(plan.length, 7);
    expect(plan.first['day'], 'Monday');
  });

  test('day plan can be edited and converted into a workout', () async {
    await LocalStore.saveDayPlan({
      'day': 'Monday',
      'title': 'Test Day',
      'isRest': false,
      'durationMinutes': 30,
      'exerciseIds': ['bench_press', 'squat'],
    });

    final plan = await LocalStore.weeklyPlan();
    final monday = plan.firstWhere((item) => item['day'] == 'Monday');
    final workout = WorkoutFactory.fromPlan(monday);

    expect(workout.title, 'Test Day');
    expect(workout.exercises.length, 2);
  });

  test('custom workout persists locally', () async {
    await LocalStore.saveCustomWorkout(
      name: 'My Test Workout',
      exerciseIds: ['bench_press'],
    );

    final items = await LocalStore.customWorkouts();
    expect(items.length, 1);
    expect(items.first['name'], 'My Test Workout');
  });


  test('set history builds previous-set data and personal records', () async {
    await LocalStore.addWorkoutHistory({
      'title': 'Push Day',
      'date': DateTime(2026, 9, 26).toIso8601String(),
      'durationMinutes': 42,
      'completedSets': 2,
      'exerciseCount': 1,
      'totalVolume': 1300.0,
      'prCount': 1,
      'sets': [
        {
          'exerciseId': 'bench_press',
          'exerciseName': 'Bench Press',
          'muscle': 'Chest',
          'setNumber': 1,
          'weight': 60.0,
          'reps': 10,
          'volume': 600.0,
          'isPR': true,
          'completedAt': DateTime(2026, 9, 26, 10).toIso8601String(),
        },
        {
          'exerciseId': 'bench_press',
          'exerciseName': 'Bench Press',
          'muscle': 'Chest',
          'setNumber': 2,
          'weight': 70.0,
          'reps': 10,
          'volume': 700.0,
          'isPR': true,
          'completedAt': DateTime(2026, 9, 26, 10, 2).toIso8601String(),
        },
      ],
    });

    final previous = await LocalStore.latestSetForExercise(
      'bench_press',
      setNumber: 2,
    );
    final records = await LocalStore.exerciseRecords();

    expect(previous?['weight'], 70.0);
    expect(records['bench_press']?['bestWeight'], 70.0);
    expect(records['bench_press']?['repsAtBestWeight'], 10);
  });
}
