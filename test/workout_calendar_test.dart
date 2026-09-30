import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/data/workout_factory.dart';
import 'package:fitwithsaju/data/workout_program_catalog.dart';
import 'package:fitwithsaju/data/workout_program_schedule.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('week one ignores program days before enrollment', () {
    final active = <String, dynamic>{
      'programId': 'foundation_3',
      'durationWeeks': 6,
      'trainingDays': 3,
      'trainingWeekdays': <int>[1, 3, 5],
      'startedAt': DateTime(2026, 9, 29, 10).toIso8601String(),
    };
    final program = WorkoutProgramCatalog.find('foundation_3')!;
    final schedule = WorkoutProgramSchedule.build(
      activeProgram: active,
      weeklyPlan: program.planWithProgramMetadata(),
      history: const [],
      overrides: const [],
      now: DateTime(2026, 9, 29),
    );

    final monday = schedule.firstWhere(
      (entry) => entry.week == 1 && entry.day == 'Monday',
    );
    final wednesday = schedule.firstWhere(
      (entry) => entry.week == 1 && entry.day == 'Wednesday',
    );

    expect(monday.status, 'prestart');
    expect(wednesday.status, 'upcoming');
  });

  test('rescheduled program session persists and is restored by backup',
      () async {
    final program = WorkoutProgramCatalog.find('foundation_3')!;
    await LocalStore.startWorkoutProgram(
      programId: program.id,
      name: program.name,
      level: program.level,
      durationWeeks: program.durationWeeks,
      trainingDays: program.trainingDays,
      weeklyPlan: program.planWithProgramMetadata(),
    );

    await LocalStore.rescheduleProgramSession(
      programId: program.id,
      sessionKey: 'foundation_3_w1_wednesday',
      scheduledDate: DateTime(2026, 10, 2),
    );

    final backup = await LocalStore.exportData();
    expect(backup['formatVersion'], 6);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LocalStore.importData(backup);
    final overrides = await LocalStore.programScheduleOverrides();

    expect(overrides, hasLength(1));
    expect(overrides.first['sessionKey'], 'foundation_3_w1_wednesday');
    expect(overrides.first['status'], 'rescheduled');
  });

  test('deload metadata reaches generated workout', () {
    final program = WorkoutProgramCatalog.find('strength_4')!;
    final plan =
        Map<String, dynamic>.from(program.planWithProgramMetadata().first)
          ..['programSessionKey'] = 'strength_4_w4_monday'
          ..['scheduledDate'] = '2026-10-19'
          ..['programWeek'] = 4
          ..['isDeload'] = true;

    final workout = WorkoutFactory.fromPlan(plan);

    expect(workout.programSessionKey, 'strength_4_w4_monday');
    expect(workout.programWeek, 4);
    expect(workout.isDeload, isTrue);
  });

  test('program progress excludes pre-enrollment training days', () {
    final active = <String, dynamic>{
      'programId': 'foundation_3',
      'durationWeeks': 6,
      'trainingDays': 3,
      'trainingWeekdays': <int>[1, 3, 5],
      'startedAt': DateTime(2026, 9, 29, 10).toIso8601String(),
    };

    final progress = WorkoutProgramProgress.calculate(
      activeProgram: active,
      history: const [],
      now: DateTime(2026, 9, 29),
    );

    expect(progress.totalSessions, 17);
    expect(progress.thisWeekPlanned, 2);
  });
}
