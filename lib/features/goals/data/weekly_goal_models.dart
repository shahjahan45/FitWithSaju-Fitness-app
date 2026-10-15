class WeeklyGoalTargets {
  final int workouts;
  final int trainingMinutes;
  final int hydrationDays;
  final int readinessDays;

  const WeeklyGoalTargets({
    required this.workouts,
    required this.trainingMinutes,
    required this.hydrationDays,
    required this.readinessDays,
  });

  factory WeeklyGoalTargets.fromMap(Map<String, dynamic> map) {
    int value(String key, int fallback, int min, int max) {
      final parsed = int.tryParse(map[key]?.toString() ?? '') ?? fallback;
      return parsed.clamp(min, max).toInt();
    }

    return WeeklyGoalTargets(
      workouts: value('workouts', 4, 1, 7),
      trainingMinutes: value('trainingMinutes', 180, 30, 840),
      hydrationDays: value('hydrationDays', 5, 1, 7),
      readinessDays: value('readinessDays', 5, 1, 7),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'workouts': workouts,
        'trainingMinutes': trainingMinutes,
        'hydrationDays': hydrationDays,
        'readinessDays': readinessDays,
      };
}

class WeeklyGoalProgress {
  final int current;
  final int target;

  const WeeklyGoalProgress({required this.current, required this.target});

  double get ratio => target <= 0 ? 0 : (current / target).clamp(0.0, 1.0);
  bool get complete => current >= target;
}

class WeeklyGoalsSnapshot {
  final DateTime weekStart;
  final DateTime weekEnd;
  final WeeklyGoalTargets targets;
  final WeeklyGoalProgress workouts;
  final WeeklyGoalProgress trainingMinutes;
  final WeeklyGoalProgress hydrationDays;
  final WeeklyGoalProgress readinessDays;
  final int previousWeekGoalsMet;
  final String coachingTitle;
  final String coachingMessage;

  const WeeklyGoalsSnapshot({
    required this.weekStart,
    required this.weekEnd,
    required this.targets,
    required this.workouts,
    required this.trainingMinutes,
    required this.hydrationDays,
    required this.readinessDays,
    required this.previousWeekGoalsMet,
    required this.coachingTitle,
    required this.coachingMessage,
  });

  List<WeeklyGoalProgress> get goals => <WeeklyGoalProgress>[
        workouts,
        trainingMinutes,
        hydrationDays,
        readinessDays,
      ];

  int get goalsMet => goals.where((goal) => goal.complete).length;

  double get overallProgress {
    final values = goals.map((goal) => goal.ratio).toList();
    return values.fold<double>(0, (sum, value) => sum + value) / values.length;
  }
}
