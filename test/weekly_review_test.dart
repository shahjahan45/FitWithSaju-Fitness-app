import 'package:fitwithsaju/features/review/data/weekly_review_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weekly review compares the same point last week and parses legacy values', () {
    final snapshot = WeeklyReviewCalculator.calculate(
      anchorDate: DateTime(2026, 10, 15),
      workoutHistory: <Map<String, dynamic>>[
        {
          'date': '2026-10-12T18:00:00',
          'durationMinutes': '45',
          'completedSets': '12',
          'totalVolume': '4200.5',
          'prCount': '1',
        },
        {
          'date': '2026-10-14T18:00:00',
          'durationMinutes': 60,
          'completedSets': 16,
          'totalVolume': 6100,
          'prCount': 2,
        },
        {
          'date': '2026-10-05T18:00:00',
          'durationMinutes': 40,
          'completedSets': 10,
          'totalVolume': 3900,
          'prCount': 0,
        },
        {
          'date': '2026-10-08T18:00:00',
          'durationMinutes': 45,
          'completedSets': 11,
          'totalVolume': 4300,
          'prCount': 1,
        },
        {
          'date': '2026-09-28T18:00:00',
          'durationMinutes': 50,
          'completedSets': 12,
          'totalVolume': 4400,
          'prCount': 0,
        },
      ],
      currentHydrationDays: 3,
      currentReadinessDays: 4,
      currentReadinessAverage: 76,
      currentGoalsMet: 2,
      currentGoalProgress: .72,
      previousHydrationDays: 2,
      previousReadinessDays: 3,
      previousReadinessAverage: 70,
      previousGoalsMet: 1,
      previousGoalProgress: .56,
    );

    expect(snapshot.current.workouts, 2);
    expect(snapshot.current.trainingMinutes, 105);
    expect(snapshot.current.completedSets, 28);
    expect(snapshot.current.trainingVolume, closeTo(10300.5, .01));
    expect(snapshot.current.personalRecords, 3);
    expect(snapshot.previousComparable.workouts, 2);
    expect(snapshot.previousComparable.trainingMinutes, 85);
    expect(snapshot.minuteDelta, 20);
    expect(snapshot.current.bestTrainingDay, DateTime(2026, 10, 14));
    expect(snapshot.currentTrainingWeekStreak, 3);
    expect(snapshot.bestTrainingWeekStreak, 3);
  });

  test('weekly review calculates volume from legacy set values when total is absent', () {
    final snapshot = WeeklyReviewCalculator.calculate(
      anchorDate: DateTime(2026, 10, 15),
      workoutHistory: <Map<String, dynamic>>[
        {
          'date': '2026-10-13T18:00:00',
          'durationMinutes': 30,
          'sets': <Map<String, dynamic>>[
            {'weight': '20', 'reps': '10'},
            {'volume': '250'},
          ],
        },
      ],
      currentHydrationDays: 0,
      currentReadinessDays: 0,
      currentReadinessAverage: null,
      currentGoalsMet: 0,
      currentGoalProgress: 0,
      previousHydrationDays: 0,
      previousReadinessDays: 0,
      previousReadinessAverage: null,
      previousGoalsMet: 0,
      previousGoalProgress: 0,
    );

    expect(snapshot.current.completedSets, 2);
    expect(snapshot.current.trainingVolume, 450);
  });

  test('higher load with low readiness produces recovery-protective guidance only', () {
    final snapshot = WeeklyReviewCalculator.calculate(
      anchorDate: DateTime(2026, 10, 15),
      workoutHistory: <Map<String, dynamic>>[
        {
          'date': '2026-10-13T18:00:00',
          'durationMinutes': 60,
          'totalVolume': 8000,
        },
        {
          'date': '2026-10-14T18:00:00',
          'durationMinutes': 60,
          'totalVolume': 8000,
        },
        {
          'date': '2026-10-06T18:00:00',
          'durationMinutes': 50,
          'totalVolume': 5000,
        },
        {
          'date': '2026-10-08T18:00:00',
          'durationMinutes': 45,
          'totalVolume': 5000,
        },
      ],
      currentHydrationDays: 2,
      currentReadinessDays: 3,
      currentReadinessAverage: 52,
      currentGoalsMet: 1,
      currentGoalProgress: .5,
      previousHydrationDays: 2,
      previousReadinessDays: 3,
      previousReadinessAverage: 74,
      previousGoalsMet: 1,
      previousGoalProgress: .5,
    );

    expect(snapshot.headline, contains('Protect recovery'));
    expect(snapshot.guidance, contains('guidance only'));
    expect(snapshot.guidance, isNot(contains('automatically')));
  });
}
