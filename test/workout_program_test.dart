import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/data/workout_factory.dart';
import 'package:fitwithsaju/data/workout_program_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('starting a program persists active state and program day ids',
      () async {
    final program = WorkoutProgramCatalog.programs.first;
    await LocalStore.startWorkoutProgram(
      programId: program.id,
      name: program.name,
      level: program.level,
      durationWeeks: program.durationWeeks,
      trainingDays: program.trainingDays,
      weeklyPlan: program.planWithProgramMetadata(),
    );

    final active = await LocalStore.activeProgram();
    final plan = await LocalStore.weeklyPlan();
    final monday = plan.firstWhere((item) => item['day'] == 'Monday');
    final workout = WorkoutFactory.fromPlan(monday);

    expect(active?['programId'], program.id);
    expect(active?['durationWeeks'], 6);
    expect(monday['programId'], program.id);
    expect(workout.id, 'program_foundation_3_monday');
  });

  test('program progress counts only matching program sessions', () {
    final active = <String, dynamic>{
      'programId': 'foundation_3',
      'durationWeeks': 6,
      'trainingDays': 3,
      'startedAt': DateTime(2026, 9, 28).toIso8601String(),
    };
    final history = <Map<String, dynamic>>[
      {
        'workoutId': 'program_foundation_3_monday',
        'date': DateTime(2026, 9, 28, 9).toIso8601String(),
      },
      {
        'workoutId': 'program_foundation_3_wednesday',
        'date': DateTime(2026, 9, 30, 9).toIso8601String(),
      },
      {
        'workoutId': 'custom_other',
        'date': DateTime(2026, 9, 30, 12).toIso8601String(),
      },
    ];

    final progress = WorkoutProgramProgress.calculate(
      activeProgram: active,
      history: history,
      now: DateTime(2026, 10, 1),
    );

    expect(progress.currentWeek, 1);
    expect(progress.completedSessions, 2);
    expect(progress.thisWeekCompleted, 2);
    expect(progress.totalSessions, 18);
  });

  test('backup restores active program metadata', () async {
    final program = WorkoutProgramCatalog.programs[1];
    await LocalStore.startWorkoutProgram(
      programId: program.id,
      name: program.name,
      level: program.level,
      durationWeeks: program.durationWeeks,
      trainingDays: program.trainingDays,
      weeklyPlan: program.planWithProgramMetadata(),
    );
    final backup = await LocalStore.exportData();

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LocalStore.importData(backup);

    final restored = await LocalStore.activeProgram();
    expect(restored?['programId'], 'strength_4');
    expect(restored?['durationWeeks'], 8);
  });
}
