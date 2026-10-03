import 'package:fitwithsaju/features/recovery/data/training_balance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('training balance compares last 7 days with previous 3-week baseline',
      () {
    final anchor = DateTime(2026, 10, 3);
    final workouts = <Map<String, dynamic>>[
      {'date': DateTime(2026, 10, 3).toIso8601String(), 'totalVolume': 1200},
      {'date': DateTime(2026, 9, 30).toIso8601String(), 'totalVolume': 1800},
      {'date': DateTime(2026, 9, 25).toIso8601String(), 'totalVolume': 1000},
      {'date': DateTime(2026, 9, 20).toIso8601String(), 'totalVolume': 1000},
      {'date': DateTime(2026, 9, 15).toIso8601String(), 'totalVolume': 1000},
    ];

    final result = TrainingBalanceCalculator.calculate(
      anchorDate: anchor,
      workoutHistory: workouts,
      readinessAverage7: 78,
    );

    expect(result.currentWorkouts, 2);
    expect(result.currentVolume, 3000);
    expect(result.baselineWeeklyVolume, 1000);
    expect(result.volumeRatio, 3);
    expect(result.label, 'Well above recent baseline');
  });

  test('training balance tolerates legacy numeric strings and set volume', () {
    final anchor = DateTime(2026, 10, 3);
    final result = TrainingBalanceCalculator.calculate(
      anchorDate: anchor,
      workoutHistory: <Map<String, dynamic>>[
        {
          'date': DateTime(2026, 10, 2).toIso8601String(),
          'totalVolume': '1250.5',
        },
        {
          'date': DateTime(2026, 10, 1).toIso8601String(),
          'sets': <Map<String, dynamic>>[
            {'volume': '300'},
            {'volume': 449.5},
          ],
        },
        {
          'date': DateTime(2026, 9, 20).toIso8601String(),
          'totalVolume': '750',
        },
      ],
    );

    expect(result.currentVolume, closeTo(2000, .001));
    expect(result.baselineWeeklyVolume, closeTo(250, .001));
  });

  test('training balance builds baseline safely when prior volume is empty',
      () {
    final result = TrainingBalanceCalculator.calculate(
      anchorDate: DateTime(2026, 10, 3),
      workoutHistory: <Map<String, dynamic>>[
        {
          'date': DateTime(2026, 10, 3).toIso8601String(),
          'totalVolume': 1200,
        },
      ],
    );

    expect(result.volumeRatio, isNull);
    expect(result.label, 'Building training baseline');
    expect(result.guidance, contains('Keep logging workouts'));
  });

  test('low readiness and high load produce recovery-first optional guidance',
      () {
    final anchor = DateTime(2026, 10, 3);
    final workouts = <Map<String, dynamic>>[
      {'date': DateTime(2026, 10, 3).toIso8601String(), 'totalVolume': 2500},
      {'date': DateTime(2026, 10, 1).toIso8601String(), 'totalVolume': 2500},
      {'date': DateTime(2026, 9, 20).toIso8601String(), 'totalVolume': 1000},
      {'date': DateTime(2026, 9, 15).toIso8601String(), 'totalVolume': 1000},
      {'date': DateTime(2026, 9, 10).toIso8601String(), 'totalVolume': 1000},
    ];

    final result = TrainingBalanceCalculator.calculate(
      anchorDate: anchor,
      workoutHistory: workouts,
      readinessAverage7: 48,
    );

    expect(result.volumeRatio, greaterThan(1.5));
    expect(result.guidance, contains('Consider protecting recovery time'));
    expect(result.guidance, isNot(contains('automatically')));
  });
}
