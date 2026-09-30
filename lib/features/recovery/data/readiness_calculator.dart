import 'readiness_models.dart';

class ReadinessCalculator {
  ReadinessCalculator._();

  static ReadinessAssessment calculate({
    required ReadinessCheckIn checkIn,
    required int hydrationMl,
    required int hydrationTargetMl,
    required TrainingLoadContext trainingLoad,
    required bool hasActiveProgram,
    required bool hasProgramSessionToday,
    required bool isRestOrDeloadDay,
  }) {
    final sleepPoints = _positiveRating(checkIn.sleepQuality, 20);
    final energyPoints = _positiveRating(checkIn.energy, 20);
    final sorenessPoints = _inverseRating(checkIn.soreness, 15);
    final stressPoints = _inverseRating(checkIn.stress, 15);
    final checkInPoints =
        sleepPoints + energyPoints + sorenessPoints + stressPoints;

    final hydrationProgress = hydrationTargetMl <= 0
        ? 0.0
        : (hydrationMl / hydrationTargetMl).clamp(0.0, 1.0).toDouble();
    final hydrationPoints = hydrationProgress * 10;
    final trainingLoadPoints = _trainingLoadPoints(trainingLoad);
    final frequencyPoints = _frequencyPoints(trainingLoad.last7DaysWorkouts);
    final programPoints = _programPoints(
      hasActiveProgram: hasActiveProgram,
      hasProgramSessionToday: hasProgramSessionToday,
      isRestOrDeloadDay: isRestOrDeloadDay,
    );

    final breakdown = ReadinessBreakdown(
      checkInPoints: checkInPoints,
      hydrationPoints: hydrationPoints,
      trainingLoadPoints: trainingLoadPoints,
      frequencyPoints: frequencyPoints,
      programPoints: programPoints,
    );
    final score = breakdown.total.round().clamp(0, 100).toInt();
    final guidance = guidanceFor(score);

    return ReadinessAssessment(
      score: score,
      label: guidance.$1,
      recommendation: guidance.$2,
      breakdown: breakdown,
    );
  }

  static (String, String) guidanceFor(int score) {
    if (score >= 85) {
      return (
        'Ready to train',
        'Your check-in and recent training context support a strong session. Train normally if that matches how you feel.',
      );
    }
    if (score >= 70) {
      return (
        'Train as planned',
        'Your recovery signals are generally supportive. Keep the planned session and use normal warm-up feedback to guide effort.',
      );
    }
    if (score >= 55) {
      return (
        'Consider reducing workout volume',
        'A lighter session may fit today better. You can reduce sets, duration, or intensity while keeping the workout under your control.',
      );
    }
    if (score >= 40) {
      return (
        'Prioritize recovery',
        'Recovery signals are lower today. Consider an easier session, extra rest, hydration, food, and sleep before pushing volume.',
      );
    }
    return (
      'Consider rescheduling today’s session',
      'Your current recovery inputs are low. If you do not feel ready, consider moving the session rather than forcing it. FitWithSaju will not change your plan automatically.',
    );
  }

  static double _positiveRating(int rating, double maxPoints) {
    final normalized = (rating.clamp(1, 5) - 1) / 4;
    return normalized * maxPoints;
  }

  static double _inverseRating(int rating, double maxPoints) {
    final normalized = (5 - rating.clamp(1, 5)) / 4;
    return normalized * maxPoints;
  }

  static double _trainingLoadPoints(TrainingLoadContext load) {
    if (load.last7DaysWorkouts == 0 || load.last7DaysVolume <= 0) {
      return 8;
    }
    if (load.previous7DaysVolume <= 0) {
      if (load.last7DaysWorkouts <= 3) {
        return 9;
      }
      if (load.last7DaysWorkouts <= 5) {
        return 7;
      }
      return 5;
    }
    final ratio = load.last7DaysVolume / load.previous7DaysVolume;
    if (ratio <= .85) {
      return 9;
    }
    if (ratio <= 1.15) {
      return 10;
    }
    if (ratio <= 1.35) {
      return 8;
    }
    if (ratio <= 1.60) {
      return 6;
    }
    return 4;
  }

  static double _frequencyPoints(int workouts) {
    if (workouts <= 4) {
      return 5;
    }
    if (workouts == 5) {
      return 4;
    }
    if (workouts == 6) {
      return 2.5;
    }
    return 1;
  }

  static double _programPoints({
    required bool hasActiveProgram,
    required bool hasProgramSessionToday,
    required bool isRestOrDeloadDay,
  }) {
    if (!hasActiveProgram) {
      return 4.5;
    }
    if (isRestOrDeloadDay) {
      return 5;
    }
    if (hasProgramSessionToday) {
      return 4;
    }
    return 4.5;
  }
}
