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

  test('active workout draft can be saved and cleared', () async {
    await LocalStore.saveActiveWorkout({
      'workoutId': 'plan_Monday',
      'title': 'Push Day',
      'exerciseIds': ['bench_press'],
      'exerciseIndex': 0,
      'setIndex': 2,
      'sets': [
        {
          'exerciseId': 'bench_press',
          'exerciseName': 'Bench Press',
          'weight': 60.0,
          'reps': 10,
          'setNumber': 1,
        },
      ],
    });

    final draft = await LocalStore.activeWorkout();
    expect(draft?['title'], 'Push Day');
    expect((draft?['sets'] as List).length, 1);

    await LocalStore.clearActiveWorkout();
    expect(await LocalStore.activeWorkout(), isNull);
  });

  test('backup export can be imported into a clean store', () async {
    await LocalStore.saveCustomWorkout(
      name: 'Backup Workout',
      exerciseIds: ['squat'],
    );
    await LocalStore.addWeight(77.5);
    final backup = await LocalStore.exportData();

    SharedPreferences.setMockInitialValues({});
    await LocalStore.importData(backup);

    final workouts = await LocalStore.customWorkouts();
    final weights = await LocalStore.weightEntries();
    expect(workouts.first['name'], 'Backup Workout');
    expect(weights.first['value'], 77.5);
  });

  test('estimated 1RM uses the Epley estimate', () {
    expect(LocalStore.estimatedOneRepMax(100, 1), 100);
    expect(LocalStore.estimatedOneRepMax(100, 10), closeTo(133.33, .02));
  });

  test('resume draft converts back into a workout', () {
    final workout = WorkoutFactory.fromDraft({
      'workoutId': 'resume_test',
      'title': 'Resume Test',
      'subtitle': 'Chest',
      'durationMinutes': 25,
      'exerciseIds': ['bench_press'],
    });

    expect(workout.id, 'resume_test');
    expect(workout.title, 'Resume Test');
    expect(workout.exercises.single.id, 'bench_press');
  });

  test('history normalization recalculates edited set totals', () async {
    await LocalStore.addWorkoutHistory({
      'id': 'edit_session',
      'title': 'Edit Test',
      'date': DateTime(2026, 9, 27).toIso8601String(),
      'durationMinutes': 20,
      'completedSets': 1,
      'exerciseCount': 1,
      'totalVolume': 500.0,
      'prCount': 1,
      'sets': [
        {
          'exerciseId': 'squat',
          'exerciseName': 'Back Squat',
          'muscle': 'Legs',
          'setNumber': 1,
          'weight': 50.0,
          'reps': 10,
          'volume': 500.0,
          'isPR': true,
          'completedAt': DateTime(2026, 9, 27, 9).toIso8601String(),
        },
      ],
    });

    final session = (await LocalStore.historySessionById('edit_session'))!;
    final sets = LocalStore.sessionSets(session);
    sets.first['weight'] = 60.0;
    sets.first['reps'] = 10;
    session['sets'] = sets;
    await LocalStore.replaceHistorySession('edit_session', session);
    await LocalStore.normalizeWorkoutHistory();

    final updated = (await LocalStore.historySessionById('edit_session'))!;
    expect(updated['totalVolume'], 600.0);
    expect(updated['completedSets'], 1);
    expect(LocalStore.sessionSets(updated).first['estimated1RM'],
        closeTo(80, .01));
  });
}
