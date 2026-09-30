import 'package:fitwithsaju/features/recovery/data/readiness_models.dart';
import 'package:fitwithsaju/features/recovery/data/recovery_insights_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

ReadinessHistoryPoint point(
  DateTime date,
  int score, {
  int sleep = 4,
  int energy = 4,
  int soreness = 2,
  int stress = 2,
}) {
  return ReadinessHistoryPoint(
    date: date,
    score: score,
    checkIn: ReadinessCheckIn(
      dateKey:
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      sleepQuality: sleep,
      energy: energy,
      soreness: soreness,
      stress: stress,
      createdAt: date.toIso8601String(),
      updatedAt: date.toIso8601String(),
    ),
  );
}

ReadinessAssessment assessment(int score) {
  return ReadinessAssessment(
    score: score,
    label: 'Guidance',
    recommendation: 'Guidance only',
    breakdown: ReadinessBreakdown(
      checkInPoints: score.toDouble(),
      hydrationPoints: 0,
      trainingLoadPoints: 0,
      frequencyPoints: 0,
      programPoints: 0,
    ),
  );
}

void main() {
  test('28-day insights calculate averages, trend and consistency', () {
    final anchor = DateTime(2026, 9, 30);
    final history = <ReadinessHistoryPoint>[
      point(DateTime(2026, 9, 18), 62, sleep: 3, energy: 3),
      point(DateTime(2026, 9, 20), 66, sleep: 3, energy: 3),
      point(DateTime(2026, 9, 22), 70),
      point(DateTime(2026, 9, 24), 76),
      point(DateTime(2026, 9, 26), 80),
      point(DateTime(2026, 9, 28), 84),
      point(DateTime(2026, 9, 30), 88),
    ];

    final result = RecoveryInsightsCalculator.calculate(
      anchorDate: anchor,
      readinessHistory: history,
      workoutHistory: const <Map<String, dynamic>>[],
    );

    expect(result.checkInDays, 7);
    expect(result.averageScore, 75);
    expect(result.last7Average, 82);
    expect(result.previous7Average, 66);
    expect(result.trendDelta, 16);
    expect(result.consistencyRate, closeTo(7 / 28, .001));
    expect(result.averageSleep, greaterThan(3));
  });

  test('training context separates current and previous 28-day windows', () {
    final anchor = DateTime(2026, 9, 30);
    final workouts = <Map<String, dynamic>>[
      {
        'date': DateTime(2026, 9, 30, 8).toIso8601String(),
        'totalVolume': 1200.0,
      },
      {
        'date': DateTime(2026, 9, 10, 8).toIso8601String(),
        'totalVolume': 1800.0,
      },
      {
        'date': DateTime(2026, 8, 28, 8).toIso8601String(),
        'totalVolume': 1500.0,
      },
      {
        'date': DateTime(2026, 8, 10, 8).toIso8601String(),
        'totalVolume': 500.0,
      },
    ];

    final result = RecoveryInsightsCalculator.calculate(
      anchorDate: anchor,
      readinessHistory: const <ReadinessHistoryPoint>[],
      workoutHistory: workouts,
    );

    expect(result.workouts28, 2);
    expect(result.volume28, 3000);
    expect(result.previousWorkouts28, 2);
    expect(result.previousVolume28, 2000);
    expect(result.trainingVolumeRatio, 1.5);
    expect(result.last7Workouts, 1);
    expect(result.last7Volume, 1200);
  });

  test('weekly recovery review compares the latest two seven-day windows', () {
    final anchor = DateTime(2026, 9, 30);
    final readiness = <ReadinessHistoryPoint>[
      point(DateTime(2026, 9, 18), 60),
      point(DateTime(2026, 9, 20), 64),
      point(DateTime(2026, 9, 24), 78),
      point(DateTime(2026, 9, 27), 82),
      point(DateTime(2026, 9, 30), 86),
    ];
    final workouts = <Map<String, dynamic>>[
      {'date': DateTime(2026, 9, 29).toIso8601String(), 'totalVolume': 1400},
      {'date': DateTime(2026, 9, 25).toIso8601String(), 'totalVolume': 1100},
      {'date': DateTime(2026, 9, 20).toIso8601String(), 'totalVolume': 1200},
    ];

    final result = RecoveryInsightsCalculator.calculate(
      anchorDate: anchor,
      readinessHistory: readiness,
      workoutHistory: workouts,
    );

    expect(result.last7Average, 82);
    expect(result.previous7Average, 62);
    expect(result.last7Workouts, 2);
    expect(result.previous7Workouts, 1);
    expect(result.weeklyReviewLabel, contains('improving'));
  });

  test('smart guidance never mutates a workout and scales suggestions by score',
      () {
    final high = RecoveryInsightsCalculator.guidance(
      assessment: assessment(90),
      hasProgramSessionToday: true,
      isRestOrDeloadDay: false,
    );
    final moderate = RecoveryInsightsCalculator.guidance(
      assessment: assessment(60),
      hasProgramSessionToday: true,
      isRestOrDeloadDay: false,
    );
    final low = RecoveryInsightsCalculator.guidance(
      assessment: assessment(35),
      hasProgramSessionToday: true,
      isRestOrDeloadDay: false,
    );

    expect(high.volumeLabel, contains('100%'));
    expect(moderate.volumeLabel, contains('70–85%'));
    expect(low.considerReschedule, isTrue);
    expect(low.subtitle, contains('will not cancel or change'));
  });

  test('rest or deload guidance protects recovery intent regardless of score',
      () {
    final result = RecoveryInsightsCalculator.guidance(
      assessment: assessment(92),
      hasProgramSessionToday: true,
      isRestOrDeloadDay: true,
    );

    expect(result.title, 'Protect the recovery intent');
    expect(result.volumeLabel, 'Planned recovery volume');
    expect(result.considerReschedule, isFalse);
  });

  test('insights call out sustained high soreness and training-load increase',
      () {
    final anchor = DateTime(2026, 9, 30);
    final readiness = List<ReadinessHistoryPoint>.generate(
      7,
      (index) => point(
        anchor.subtract(Duration(days: index)),
        58,
        soreness: 5,
      ),
    );
    final workouts = <Map<String, dynamic>>[
      {
        'date': DateTime(2026, 9, 29).toIso8601String(),
        'totalVolume': 5000.0,
      },
      {
        'date': DateTime(2026, 8, 20).toIso8601String(),
        'totalVolume': 2000.0,
      },
    ];

    final result = RecoveryInsightsCalculator.calculate(
      anchorDate: anchor,
      readinessHistory: readiness,
      workoutHistory: workouts,
    );

    expect(
      result.observations.any((item) => item.contains('soreness')),
      isTrue,
    );
    expect(
      result.observations.any((item) => item.contains('training volume')),
      isTrue,
    );
  });
}
