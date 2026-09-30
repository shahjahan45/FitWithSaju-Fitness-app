import 'package:fitwithsaju/core/storage/local_store.dart';
import 'package:fitwithsaju/features/recovery/data/readiness_calculator.dart';
import 'package:fitwithsaju/features/recovery/data/readiness_models.dart';
import 'package:fitwithsaju/features/recovery/data/readiness_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ReadinessCheckIn checkIn({
  int sleep = 4,
  int energy = 4,
  int soreness = 2,
  int stress = 2,
}) {
  return ReadinessCheckIn(
    dateKey: '2026-09-30',
    sleepQuality: sleep,
    energy: energy,
    soreness: soreness,
    stress: stress,
    createdAt: '2026-09-30T07:00:00',
    updatedAt: '2026-09-30T07:00:00',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('readiness score is deterministic, bounded and transparent', () {
    final result = ReadinessCalculator.calculate(
      checkIn: checkIn(),
      hydrationMl: 2000,
      hydrationTargetMl: 2500,
      trainingLoad: const TrainingLoadContext(
        last7DaysVolume: 8000,
        previous7DaysVolume: 7600,
        last7DaysWorkouts: 4,
        previous7DaysWorkouts: 4,
      ),
      hasActiveProgram: true,
      hasProgramSessionToday: true,
      isRestOrDeloadDay: false,
    );

    expect(result.score, inInclusiveRange(0, 100));
    expect(result.breakdown.total.round(), result.score);
    expect(result.breakdown.checkInPoints, closeTo(52.5, .01));
    expect(result.breakdown.hydrationPoints, closeTo(8, .01));
    expect(result.label, isNotEmpty);
  });

  test('one readiness check-in is stored per local calendar date', () async {
    final date = DateTime(2026, 9, 30, 8);
    await LocalStore.saveReadinessCheckIn(
      date: date,
      sleepQuality: 4,
      energy: 3,
      soreness: 2,
      stress: 2,
    );
    await LocalStore.saveReadinessCheckIn(
      date: DateTime(2026, 9, 30, 21),
      sleepQuality: 5,
      energy: 4,
      soreness: 1,
      stress: 1,
    );

    final items = await LocalStore.readinessCheckIns();
    expect(items, hasLength(1));
    expect(items.single['dateKey'], '2026-09-30');
    expect(items.single['sleepQuality'], 5);
  });

  test('editing a check-in preserves its createdAt and updates values',
      () async {
    final date = DateTime(2026, 9, 30);
    await LocalStore.saveReadinessCheckIn(
      date: date,
      sleepQuality: 2,
      energy: 2,
      soreness: 4,
      stress: 4,
    );
    final before = await LocalStore.readinessCheckInForDate(date);

    await LocalStore.saveReadinessCheckIn(
      date: date,
      sleepQuality: 4,
      energy: 5,
      soreness: 2,
      stress: 2,
    );
    final after = await LocalStore.readinessCheckInForDate(date);

    expect(after?['createdAt'], before?['createdAt']);
    expect(after?['energy'], 5);
    expect(after?['soreness'], 2);
  });

  test('readiness history remains date ordered and backup restores it',
      () async {
    await LocalStore.saveReadinessCheckIn(
      date: DateTime(2026, 9, 29),
      sleepQuality: 4,
      energy: 4,
      soreness: 2,
      stress: 2,
    );
    await LocalStore.saveReadinessCheckIn(
      date: DateTime(2026, 9, 30),
      sleepQuality: 5,
      energy: 4,
      soreness: 1,
      stress: 1,
    );

    final backup = await LocalStore.exportData();
    expect(backup['formatVersion'], 6);
    expect(backup['readinessCheckIns'], hasLength(2));

    SharedPreferences.setMockInitialValues({});
    await LocalStore.importData(backup);
    final restored = await LocalStore.readinessCheckIns();
    expect(restored, hasLength(2));
    expect(restored.first['dateKey'], '2026-09-30');
  });

  test('hydration contributes up to ten readiness points', () {
    final dry = ReadinessCalculator.calculate(
      checkIn: checkIn(),
      hydrationMl: 0,
      hydrationTargetMl: 2500,
      trainingLoad: const TrainingLoadContext(
        last7DaysVolume: 5000,
        previous7DaysVolume: 5000,
        last7DaysWorkouts: 3,
        previous7DaysWorkouts: 3,
      ),
      hasActiveProgram: false,
      hasProgramSessionToday: false,
      isRestOrDeloadDay: false,
    );
    final hydrated = ReadinessCalculator.calculate(
      checkIn: checkIn(),
      hydrationMl: 2500,
      hydrationTargetMl: 2500,
      trainingLoad: const TrainingLoadContext(
        last7DaysVolume: 5000,
        previous7DaysVolume: 5000,
        last7DaysWorkouts: 3,
        previous7DaysWorkouts: 3,
      ),
      hasActiveProgram: false,
      hasProgramSessionToday: false,
      isRestOrDeloadDay: false,
    );

    expect(dry.breakdown.hydrationPoints, 0);
    expect(hydrated.breakdown.hydrationPoints, 10);
    expect(hydrated.score - dry.score, 10);
  });

  test('training load context uses current and previous seven-day windows', () {
    final history = <Map<String, dynamic>>[
      {
        'date': DateTime(2026, 9, 30, 8).toIso8601String(),
        'totalVolume': 1000.0,
      },
      {
        'date': DateTime(2026, 9, 26, 8).toIso8601String(),
        'totalVolume': 2000.0,
      },
      {
        'date': DateTime(2026, 9, 22, 8).toIso8601String(),
        'totalVolume': 1500.0,
      },
    ];

    final load = ReadinessService.trainingLoadFor(
      history,
      DateTime(2026, 9, 30),
    );
    expect(load.last7DaysVolume, 3000);
    expect(load.last7DaysWorkouts, 2);
    expect(load.previous7DaysVolume, 1500);
    expect(load.previous7DaysWorkouts, 1);
  });

  test('program recovery context affects only its transparent context points',
      () {
    final trainingDay = ReadinessCalculator.calculate(
      checkIn: checkIn(),
      hydrationMl: 2000,
      hydrationTargetMl: 2500,
      trainingLoad: const TrainingLoadContext(
        last7DaysVolume: 6000,
        previous7DaysVolume: 6000,
        last7DaysWorkouts: 4,
        previous7DaysWorkouts: 4,
      ),
      hasActiveProgram: true,
      hasProgramSessionToday: true,
      isRestOrDeloadDay: false,
    );
    final deloadDay = ReadinessCalculator.calculate(
      checkIn: checkIn(),
      hydrationMl: 2000,
      hydrationTargetMl: 2500,
      trainingLoad: const TrainingLoadContext(
        last7DaysVolume: 6000,
        previous7DaysVolume: 6000,
        last7DaysWorkouts: 4,
        previous7DaysWorkouts: 4,
      ),
      hasActiveProgram: true,
      hasProgramSessionToday: true,
      isRestOrDeloadDay: true,
    );

    expect(trainingDay.breakdown.programPoints, 4);
    expect(deloadDay.breakdown.programPoints, 5);
  });
}
