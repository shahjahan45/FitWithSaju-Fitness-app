class WeeklyReviewPeriodMetrics {
  final DateTime start;
  final DateTime end;
  final int workouts;
  final int trainingMinutes;
  final double trainingVolume;
  final int completedSets;
  final int personalRecords;
  final int hydrationDays;
  final int readinessDays;
  final int? readinessAverage;
  final int goalsMet;
  final double goalProgress;
  final DateTime? bestTrainingDay;
  final double bestTrainingDayVolume;
  final int bestTrainingDayMinutes;

  const WeeklyReviewPeriodMetrics({
    required this.start,
    required this.end,
    required this.workouts,
    required this.trainingMinutes,
    required this.trainingVolume,
    required this.completedSets,
    required this.personalRecords,
    required this.hydrationDays,
    required this.readinessDays,
    required this.readinessAverage,
    required this.goalsMet,
    required this.goalProgress,
    required this.bestTrainingDay,
    required this.bestTrainingDayVolume,
    required this.bestTrainingDayMinutes,
  });
}

class WeeklyReviewSnapshot {
  final DateTime anchorDate;
  final WeeklyReviewPeriodMetrics current;
  final WeeklyReviewPeriodMetrics previousComparable;
  final int currentTrainingWeekStreak;
  final int bestTrainingWeekStreak;
  final String headline;
  final String guidance;

  const WeeklyReviewSnapshot({
    required this.anchorDate,
    required this.current,
    required this.previousComparable,
    required this.currentTrainingWeekStreak,
    required this.bestTrainingWeekStreak,
    required this.headline,
    required this.guidance,
  });

  int get workoutDelta => current.workouts - previousComparable.workouts;
  int get minuteDelta =>
      current.trainingMinutes - previousComparable.trainingMinutes;
  double get volumeDelta =>
      current.trainingVolume - previousComparable.trainingVolume;
  int get goalDelta => current.goalsMet - previousComparable.goalsMet;

  bool get hasAnyActivity =>
      current.workouts > 0 ||
      current.hydrationDays > 0 ||
      current.readinessDays > 0;
}
