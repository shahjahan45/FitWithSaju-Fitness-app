import '../../../data/workout_program_schedule.dart';

class ReadinessCheckIn {
  final String dateKey;
  final int sleepQuality;
  final int energy;
  final int soreness;
  final int stress;
  final String createdAt;
  final String updatedAt;

  const ReadinessCheckIn({
    required this.dateKey,
    required this.sleepQuality,
    required this.energy,
    required this.soreness,
    required this.stress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReadinessCheckIn.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    return ReadinessCheckIn(
      dateKey: json['dateKey']?.toString() ?? '',
      sleepQuality: _rating(json['sleepQuality']),
      energy: _rating(json['energy']),
      soreness: _rating(json['soreness']),
      stress: _rating(json['stress']),
      createdAt: json['createdAt']?.toString() ?? now,
      updatedAt: json['updatedAt']?.toString() ?? now,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'dateKey': dateKey,
        'sleepQuality': sleepQuality,
        'energy': energy,
        'soreness': soreness,
        'stress': stress,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static int _rating(dynamic value) {
    final parsed = int.tryParse(value?.toString() ?? '') ?? 3;
    return parsed.clamp(1, 5).toInt();
  }
}

class ReadinessBreakdown {
  final double checkInPoints;
  final double hydrationPoints;
  final double trainingLoadPoints;
  final double frequencyPoints;
  final double programPoints;

  const ReadinessBreakdown({
    required this.checkInPoints,
    required this.hydrationPoints,
    required this.trainingLoadPoints,
    required this.frequencyPoints,
    required this.programPoints,
  });

  double get total =>
      checkInPoints +
      hydrationPoints +
      trainingLoadPoints +
      frequencyPoints +
      programPoints;
}

class ReadinessAssessment {
  final int score;
  final String label;
  final String recommendation;
  final ReadinessBreakdown breakdown;

  const ReadinessAssessment({
    required this.score,
    required this.label,
    required this.recommendation,
    required this.breakdown,
  });

  bool get isLow => score < 55;
}

class TrainingLoadContext {
  final double last7DaysVolume;
  final double previous7DaysVolume;
  final int last7DaysWorkouts;
  final int previous7DaysWorkouts;

  const TrainingLoadContext({
    required this.last7DaysVolume,
    required this.previous7DaysVolume,
    required this.last7DaysWorkouts,
    required this.previous7DaysWorkouts,
  });

  double? get volumeRatio {
    if (previous7DaysVolume <= 0) {
      return null;
    }
    return last7DaysVolume / previous7DaysVolume;
  }
}

class ReadinessHistoryPoint {
  final DateTime date;
  final int score;
  final ReadinessCheckIn checkIn;

  const ReadinessHistoryPoint({
    required this.date,
    required this.score,
    required this.checkIn,
  });
}

class ReadinessSnapshot {
  final DateTime date;
  final ReadinessCheckIn? checkIn;
  final ReadinessAssessment? assessment;
  final int waterMl;
  final int waterTargetMl;
  final TrainingLoadContext trainingLoad;
  final ProgramCalendarEntry? programSession;
  final List<ReadinessHistoryPoint> history;

  const ReadinessSnapshot({
    required this.date,
    required this.checkIn,
    required this.assessment,
    required this.waterMl,
    required this.waterTargetMl,
    required this.trainingLoad,
    required this.programSession,
    required this.history,
  });

  double get hydrationProgress {
    if (waterTargetMl <= 0) {
      return 0;
    }
    return (waterMl / waterTargetMl).clamp(0.0, 1.0).toDouble();
  }

  int? get averageScore {
    if (history.isEmpty) {
      return assessment?.score;
    }
    final total = history.fold<int>(0, (sum, item) => sum + item.score);
    return (total / history.length).round();
  }

  ReadinessHistoryPoint? get bestDay {
    if (history.isEmpty) {
      return null;
    }
    return history.reduce((a, b) => a.score >= b.score ? a : b);
  }

  ReadinessHistoryPoint? get lowestDay {
    if (history.isEmpty) {
      return null;
    }
    return history.reduce((a, b) => a.score <= b.score ? a : b);
  }
}
