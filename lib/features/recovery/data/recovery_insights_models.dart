import 'readiness_models.dart';

class RecoveryInsights {
  final DateTime anchorDate;
  final List<ReadinessHistoryPoint> history;
  final int checkInDays;
  final int averageScore;
  final int? last7Average;
  final int? previous7Average;
  final int? trendDelta;
  final double consistencyRate;
  final double averageSleep;
  final double averageEnergy;
  final double averageSoreness;
  final double averageStress;
  final int workouts28;
  final double volume28;
  final int previousWorkouts28;
  final double previousVolume28;
  final int last7Workouts;
  final double last7Volume;
  final int previous7Workouts;
  final double previous7Volume;
  final List<String> observations;

  const RecoveryInsights({
    required this.anchorDate,
    required this.history,
    required this.checkInDays,
    required this.averageScore,
    required this.last7Average,
    required this.previous7Average,
    required this.trendDelta,
    required this.consistencyRate,
    required this.averageSleep,
    required this.averageEnergy,
    required this.averageSoreness,
    required this.averageStress,
    required this.workouts28,
    required this.volume28,
    required this.previousWorkouts28,
    required this.previousVolume28,
    required this.last7Workouts,
    required this.last7Volume,
    required this.previous7Workouts,
    required this.previous7Volume,
    required this.observations,
  });

  bool get hasEnoughReadinessData => checkInDays >= 3;

  String get trendLabel {
    final delta = trendDelta;
    if (delta == null) {
      return 'Building baseline';
    }
    if (delta >= 6) {
      return 'Recovery trending up';
    }
    if (delta <= -6) {
      return 'Recovery trending down';
    }
    return 'Recovery holding steady';
  }

  String get consistencyLabel {
    if (consistencyRate >= .75) {
      return 'Strong check-in consistency';
    }
    if (consistencyRate >= .45) {
      return 'Good check-in consistency';
    }
    return 'Build your check-in baseline';
  }

  double? get weeklyVolumeRatio {
    if (previous7Volume <= 0) {
      return null;
    }
    return last7Volume / previous7Volume;
  }

  String get weeklyReviewLabel {
    if (last7Average == null) {
      return 'Build this week’s recovery baseline';
    }
    final delta = trendDelta;
    if (delta != null && delta <= -6) {
      return 'Recovery is lower than last week';
    }
    if (delta != null && delta >= 6) {
      return 'Recovery is improving this week';
    }
    final loadRatio = weeklyVolumeRatio;
    if (loadRatio != null && loadRatio >= 1.35) {
      return 'Training load increased this week';
    }
    return 'Recovery is steady this week';
  }

  double? get trainingVolumeRatio {
    if (previousVolume28 <= 0) {
      return null;
    }
    return volume28 / previousVolume28;
  }
}

class SmartTrainingGuidance {
  final String title;
  final String subtitle;
  final String effortLabel;
  final String volumeLabel;
  final List<String> actions;
  final bool considerReschedule;
  final int? readinessScore;

  const SmartTrainingGuidance({
    required this.title,
    required this.subtitle,
    required this.effortLabel,
    required this.volumeLabel,
    required this.actions,
    required this.considerReschedule,
    required this.readinessScore,
  });
}
