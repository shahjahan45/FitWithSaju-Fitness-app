import 'weekly_review_models.dart';

class WeeklyReviewCalculator {
  WeeklyReviewCalculator._();

  static WeeklyReviewSnapshot calculate({
    required DateTime anchorDate,
    required List<Map<String, dynamic>> workoutHistory,
    required int currentHydrationDays,
    required int currentReadinessDays,
    required int? currentReadinessAverage,
    required int currentGoalsMet,
    required double currentGoalProgress,
    required int previousHydrationDays,
    required int previousReadinessDays,
    required int? previousReadinessAverage,
    required int previousGoalsMet,
    required double previousGoalProgress,
  }) {
    final anchor = _day(anchorDate);
    final currentStart = anchor.subtract(Duration(days: anchor.weekday - 1));
    final previousStart = currentStart.subtract(const Duration(days: 7));
    final previousComparableEnd = previousStart.add(
      Duration(days: anchor.weekday - 1),
    );

    final current = _period(
      workoutHistory: workoutHistory,
      start: currentStart,
      end: anchor,
      hydrationDays: currentHydrationDays,
      readinessDays: currentReadinessDays,
      readinessAverage: currentReadinessAverage,
      goalsMet: currentGoalsMet,
      goalProgress: currentGoalProgress,
    );
    final previous = _period(
      workoutHistory: workoutHistory,
      start: previousStart,
      end: previousComparableEnd,
      hydrationDays: previousHydrationDays,
      readinessDays: previousReadinessDays,
      readinessAverage: previousReadinessAverage,
      goalsMet: previousGoalsMet,
      goalProgress: previousGoalProgress,
    );

    final streaks = _trainingWeekStreaks(
      workoutHistory: workoutHistory,
      anchor: anchor,
    );
    final coaching = _coaching(current: current, previous: previous);

    return WeeklyReviewSnapshot(
      anchorDate: anchor,
      current: current,
      previousComparable: previous,
      currentTrainingWeekStreak: streaks.$1,
      bestTrainingWeekStreak: streaks.$2,
      headline: coaching.$1,
      guidance: coaching.$2,
    );
  }

  static WeeklyReviewPeriodMetrics _period({
    required List<Map<String, dynamic>> workoutHistory,
    required DateTime start,
    required DateTime end,
    required int hydrationDays,
    required int readinessDays,
    required int? readinessAverage,
    required int goalsMet,
    required double goalProgress,
  }) {
    var workouts = 0;
    var minutes = 0;
    var volume = 0.0;
    var sets = 0;
    var prs = 0;
    final days = <DateTime, _DayTotals>{};

    for (final session in workoutHistory) {
      final parsed = DateTime.tryParse(session['date']?.toString() ?? '');
      if (parsed == null) {
        continue;
      }
      final date = _day(parsed);
      if (date.isBefore(start) || date.isAfter(end)) {
        continue;
      }

      final sessionMinutes = _nonNegativeInt(session['durationMinutes']);
      final sessionSets = _sessionSetCount(session);
      final sessionVolume = _sessionVolume(session);
      final sessionPrs = _sessionPrCount(session);
      workouts++;
      minutes += sessionMinutes;
      sets += sessionSets;
      volume += sessionVolume;
      prs += sessionPrs;

      final day = days.putIfAbsent(date, _DayTotals.new);
      day.minutes += sessionMinutes;
      day.volume += sessionVolume;
    }

    DateTime? bestDay;
    var bestVolume = 0.0;
    var bestMinutes = 0;
    for (final entry in days.entries) {
      final candidate = entry.value;
      final betterVolume = candidate.volume > bestVolume;
      final sameVolumeLonger = candidate.volume == bestVolume &&
          candidate.minutes > bestMinutes;
      if (bestDay == null || betterVolume || sameVolumeLonger) {
        bestDay = entry.key;
        bestVolume = candidate.volume;
        bestMinutes = candidate.minutes;
      }
    }

    return WeeklyReviewPeriodMetrics(
      start: start,
      end: end,
      workouts: workouts,
      trainingMinutes: minutes,
      trainingVolume: volume,
      completedSets: sets,
      personalRecords: prs,
      hydrationDays: hydrationDays,
      readinessDays: readinessDays,
      readinessAverage: readinessAverage,
      goalsMet: goalsMet.clamp(0, 4).toInt(),
      goalProgress: goalProgress.clamp(0.0, 1.0).toDouble(),
      bestTrainingDay: bestDay,
      bestTrainingDayVolume: bestVolume,
      bestTrainingDayMinutes: bestMinutes,
    );
  }

  static (int, int) _trainingWeekStreaks({
    required List<Map<String, dynamic>> workoutHistory,
    required DateTime anchor,
  }) {
    final activeWeeks = <DateTime>{};
    for (final session in workoutHistory) {
      final parsed = DateTime.tryParse(session['date']?.toString() ?? '');
      if (parsed == null) {
        continue;
      }
      final day = _day(parsed);
      if (day.isAfter(anchor)) {
        continue;
      }
      final monday = day.subtract(Duration(days: day.weekday - 1));
      activeWeeks.add(monday);
    }
    if (activeWeeks.isEmpty) {
      return (0, 0);
    }

    final sorted = activeWeeks.toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 7) {
        run++;
        if (run > best) {
          best = run;
        }
      } else {
        run = 1;
      }
    }

    final thisMonday = anchor.subtract(Duration(days: anchor.weekday - 1));
    var cursor = activeWeeks.contains(thisMonday)
        ? thisMonday
        : thisMonday.subtract(const Duration(days: 7));
    var current = 0;
    while (activeWeeks.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 7));
    }
    return (current, best);
  }

  static (String, String) _coaching({
    required WeeklyReviewPeriodMetrics current,
    required WeeklyReviewPeriodMetrics previous,
  }) {
    if (current.workouts == 0 &&
        current.hydrationDays == 0 &&
        current.readinessDays == 0) {
      return (
        'Your week is ready to begin',
        'Log training, hydration and readiness as the week unfolds. The review will build from your real activity without changing your plan automatically.',
      );
    }

    final readiness = current.readinessAverage;
    final previousVolume = previous.trainingVolume;
    final volumeRatio = previousVolume <= 0
        ? null
        : current.trainingVolume / previousVolume;

    if (readiness != null && readiness < 60 && volumeRatio != null && volumeRatio > 1.2) {
      return (
        'Protect recovery while load is higher',
        'Training volume is ahead of the same point last week while recent readiness is lower. Use this as guidance only: keep recovery, planned rest and your own judgement in control.',
      );
    }
    if (current.goalsMet == 4) {
      return (
        'A complete consistency week',
        'All four weekly goals are already met. Maintain the plan instead of adding unnecessary sessions just to push the numbers higher.',
      );
    }
    if (current.workouts > previous.workouts &&
        current.trainingMinutes >= previous.trainingMinutes) {
      return (
        'Momentum is building',
        'You are ahead of the same point last week for training frequency and time. Keep that momentum aligned with readiness and planned recovery.',
      );
    }
    if (current.workouts < previous.workouts && current.goalsMet <= 1) {
      return (
        'Keep this week realistic',
        'This week is lighter than the same point last week. There is no need to catch up all at once—follow the sessions that fit your plan and recovery.',
      );
    }
    return (
      'A steady week in progress',
      'Your current week is developing around a similar rhythm. Use the comparison as context, not a requirement to match or exceed last week.',
    );
  }

  static int _sessionSetCount(Map<String, dynamic> session) {
    final stored = _nonNegativeInt(session['completedSets']);
    if (stored > 0) {
      return stored;
    }
    final raw = session['sets'];
    return raw is List ? raw.length : 0;
  }

  static int _sessionPrCount(Map<String, dynamic> session) {
    final stored = _nonNegativeInt(session['prCount']);
    if (stored > 0) {
      return stored;
    }
    final raw = session['sets'];
    if (raw is! List) {
      return 0;
    }
    return raw.where((value) {
      if (value is! Map) {
        return false;
      }
      return value['isPR'] == true;
    }).length;
  }

  static double _sessionVolume(Map<String, dynamic> session) {
    final stored = _nonNegativeDouble(session['totalVolume']);
    if (stored != null) {
      return stored;
    }
    final raw = session['sets'];
    if (raw is! List) {
      return 0;
    }
    var result = 0.0;
    for (final value in raw) {
      if (value is! Map) {
        continue;
      }
      final set = Map<String, dynamic>.from(value);
      final direct = _nonNegativeDouble(set['volume']);
      if (direct != null) {
        result += direct;
        continue;
      }
      final weight = _nonNegativeDouble(set['weight']) ?? 0;
      final reps = _nonNegativeInt(set['reps']);
      result += weight * reps;
    }
    return result;
  }

  static int _nonNegativeInt(dynamic value) {
    final parsed = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    return parsed < 0 ? 0 : parsed;
  }

  static double? _nonNegativeDouble(dynamic value) {
    final parsed = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return null;
    }
    return parsed;
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

class _DayTotals {
  int minutes = 0;
  double volume = 0;
}
