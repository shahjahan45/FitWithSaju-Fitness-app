import 'readiness_models.dart';
import 'recovery_insights_models.dart';

class RecoveryInsightsCalculator {
  RecoveryInsightsCalculator._();

  static RecoveryInsights calculate({
    required DateTime anchorDate,
    required List<ReadinessHistoryPoint> readinessHistory,
    required List<Map<String, dynamic>> workoutHistory,
  }) {
    final anchor = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
    final start28 = anchor.subtract(const Duration(days: 27));
    final previousStart = anchor.subtract(const Duration(days: 55));
    final previousEnd = anchor.subtract(const Duration(days: 28));

    final history = readinessHistory
        .where((point) =>
            !point.date.isBefore(start28) && !point.date.isAfter(anchor))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final checkInDays = history.length;
    final averageScore = checkInDays == 0
        ? 0
        : (history.fold<int>(0, (sum, item) => sum + item.score) / checkInDays)
            .round();

    final recentStart = anchor.subtract(const Duration(days: 6));
    final priorStart = anchor.subtract(const Duration(days: 13));
    final priorEnd = anchor.subtract(const Duration(days: 7));
    final last7 = history
        .where((point) =>
            !point.date.isBefore(recentStart) && !point.date.isAfter(anchor))
        .toList();
    final previous7 = history
        .where((point) =>
            !point.date.isBefore(priorStart) && !point.date.isAfter(priorEnd))
        .toList();
    final last7Average = _averageScore(last7);
    final previous7Average = _averageScore(previous7);
    final trendDelta = last7Average == null || previous7Average == null
        ? null
        : last7Average - previous7Average;

    final averages = _signalAverages(history);
    var workouts28 = 0;
    var volume28 = 0.0;
    var previousWorkouts28 = 0;
    var previousVolume28 = 0.0;
    var last7Workouts = 0;
    var last7Volume = 0.0;
    var previous7Workouts = 0;
    var previous7Volume = 0.0;

    for (final session in workoutHistory) {
      final parsed = DateTime.tryParse(session['date']?.toString() ?? '');
      if (parsed == null) {
        continue;
      }
      final date = DateTime(parsed.year, parsed.month, parsed.day);
      final volume = _sessionVolume(session);
      if (!date.isBefore(start28) && !date.isAfter(anchor)) {
        workouts28++;
        volume28 += volume;
        if (!date.isBefore(recentStart)) {
          last7Workouts++;
          last7Volume += volume;
        } else if (!date.isBefore(priorStart) && !date.isAfter(priorEnd)) {
          previous7Workouts++;
          previous7Volume += volume;
        }
      } else if (!date.isBefore(previousStart) && !date.isAfter(previousEnd)) {
        previousWorkouts28++;
        previousVolume28 += volume;
      }
    }

    final observations = _observations(
      checkInDays: checkInDays,
      last7Average: last7Average,
      previous7Average: previous7Average,
      averageSleep: averages.$1,
      averageEnergy: averages.$2,
      averageSoreness: averages.$3,
      averageStress: averages.$4,
      volume28: volume28,
      previousVolume28: previousVolume28,
    );

    return RecoveryInsights(
      anchorDate: anchor,
      history: history,
      checkInDays: checkInDays,
      averageScore: averageScore,
      last7Average: last7Average,
      previous7Average: previous7Average,
      trendDelta: trendDelta,
      consistencyRate: (checkInDays / 28).clamp(0.0, 1.0).toDouble(),
      averageSleep: averages.$1,
      averageEnergy: averages.$2,
      averageSoreness: averages.$3,
      averageStress: averages.$4,
      workouts28: workouts28,
      volume28: volume28,
      previousWorkouts28: previousWorkouts28,
      previousVolume28: previousVolume28,
      last7Workouts: last7Workouts,
      last7Volume: last7Volume,
      previous7Workouts: previous7Workouts,
      previous7Volume: previous7Volume,
      observations: observations,
    );
  }

  static SmartTrainingGuidance guidance({
    required ReadinessAssessment? assessment,
    required bool hasProgramSessionToday,
    required bool isRestOrDeloadDay,
  }) {
    final score = assessment?.score;
    if (score == null) {
      return const SmartTrainingGuidance(
        title: 'Check in before training',
        subtitle:
            'Complete today’s readiness check-in to unlock session guidance.',
        effortLabel: 'Not set',
        volumeLabel: 'Not set',
        actions: <String>[
          'Rate sleep, energy, soreness and stress.',
          'Keep the final training decision in your control.',
        ],
        considerReschedule: false,
        readinessScore: null,
      );
    }

    if (isRestOrDeloadDay) {
      return SmartTrainingGuidance(
        title: 'Protect the recovery intent',
        subtitle:
            'Today is already scheduled as recovery or deload work. Keep it easy unless you intentionally change the plan.',
        effortLabel: 'Easy / controlled',
        volumeLabel: 'Planned recovery volume',
        actions: const <String>[
          'Keep intensity controlled.',
          'Use the session to reinforce technique and movement quality.',
          'Prioritize hydration, food and sleep after training.',
        ],
        considerReschedule: false,
        readinessScore: score,
      );
    }

    if (score >= 85) {
      return SmartTrainingGuidance(
        title: hasProgramSessionToday
            ? 'Full session looks reasonable'
            : 'Good day to train',
        subtitle:
            'Your current recovery inputs support normal training. Use your warm-up as the final check.',
        effortLabel: 'Normal effort',
        volumeLabel: '100% planned volume',
        actions: const <String>[
          'Follow the planned exercise order.',
          'Use normal working-set targets.',
          'Stop or adjust if your warm-up feels unexpectedly poor.',
        ],
        considerReschedule: false,
        readinessScore: score,
      );
    }

    if (score >= 70) {
      return SmartTrainingGuidance(
        title: 'Train as planned with awareness',
        subtitle:
            'Your recovery picture is generally supportive. Keep the plan, but let early sets confirm today’s effort.',
        effortLabel: 'Normal to moderate',
        volumeLabel: '90–100% planned volume',
        actions: const <String>[
          'Use a progressive warm-up.',
          'Keep one or two reps in reserve on demanding sets.',
          'Trim optional accessory work if energy drops.',
        ],
        considerReschedule: false,
        readinessScore: score,
      );
    }

    if (score >= 55) {
      return SmartTrainingGuidance(
        title: 'Consider a lighter session',
        subtitle:
            'A modest volume reduction may match today’s recovery signals better without changing the workout automatically.',
        effortLabel: 'Moderate',
        volumeLabel: 'About 70–85% of planned volume',
        actions: const <String>[
          'Consider one fewer set on major exercises.',
          'Avoid adding unplanned high-effort finishers.',
          'Keep technique crisp and leave extra reps in reserve.',
        ],
        considerReschedule: false,
        readinessScore: score,
      );
    }

    if (score >= 40) {
      return SmartTrainingGuidance(
        title: 'Recovery-first training day',
        subtitle:
            'If you train, keep the session shorter and easier. You remain in control of whether to proceed.',
        effortLabel: 'Easy to moderate',
        volumeLabel: 'About 50–70% of planned volume',
        actions: const <String>[
          'Extend the warm-up before deciding on working sets.',
          'Prioritize technique, mobility or lower-fatigue work.',
          'End the session early if recovery feels worse than expected.',
        ],
        considerReschedule: true,
        readinessScore: score,
      );
    }

    return SmartTrainingGuidance(
      title: 'Consider recovery or rescheduling',
      subtitle:
          'Your current inputs are low. FitWithSaju will not cancel or change the workout for you.',
      effortLabel: 'Recovery emphasis',
      volumeLabel: 'Optional / very light',
      actions: const <String>[
        'Consider moving the planned session to another day.',
        'Choose easy movement instead of forcing high training volume.',
        'Reassess later if your energy or hydration improves.',
      ],
      considerReschedule: true,
      readinessScore: score,
    );
  }

  static int? _averageScore(List<ReadinessHistoryPoint> points) {
    if (points.isEmpty) {
      return null;
    }
    return (points.fold<int>(0, (sum, item) => sum + item.score) /
            points.length)
        .round();
  }

  static (double, double, double, double) _signalAverages(
    List<ReadinessHistoryPoint> points,
  ) {
    if (points.isEmpty) {
      return (0, 0, 0, 0);
    }
    var sleep = 0.0;
    var energy = 0.0;
    var soreness = 0.0;
    var stress = 0.0;
    for (final point in points) {
      sleep += point.checkIn.sleepQuality;
      energy += point.checkIn.energy;
      soreness += point.checkIn.soreness;
      stress += point.checkIn.stress;
    }
    final count = points.length;
    return (sleep / count, energy / count, soreness / count, stress / count);
  }

  static List<String> _observations({
    required int checkInDays,
    required int? last7Average,
    required int? previous7Average,
    required double averageSleep,
    required double averageEnergy,
    required double averageSoreness,
    required double averageStress,
    required double volume28,
    required double previousVolume28,
  }) {
    if (checkInDays < 3) {
      return const <String>[
        'Complete a few more daily check-ins to build a useful recovery baseline.',
        'Insights are fitness guidance only and are not medical or clinical conclusions.',
      ];
    }

    final items = <String>[];
    if (last7Average != null && previous7Average != null) {
      final delta = last7Average - previous7Average;
      if (delta >= 6) {
        items.add(
            'Your recent 7-day readiness average is improving versus the prior week.');
      } else if (delta <= -6) {
        items.add(
            'Your recent 7-day readiness average is lower than the prior week. Consider protecting recovery time.');
      } else {
        items.add(
            'Your recent readiness average is relatively stable week to week.');
      }
    }

    if (averageSleep < 3) {
      items.add('Sleep quality is one of your lower recent check-in signals.');
    }
    if (averageEnergy < 3) {
      items.add(
          'Recent energy ratings are on the lower side; use warm-up feedback before pushing effort.');
    }
    if (averageSoreness >= 4) {
      items.add('Muscle soreness has been high across recent check-ins.');
    }
    if (averageStress >= 4) {
      items.add('Stress ratings have been high across recent check-ins.');
    }
    if (previousVolume28 > 0 && volume28 / previousVolume28 >= 1.35) {
      items.add(
          'Your 28-day training volume is substantially above the previous 28 days.');
    }

    if (items.isEmpty) {
      items.add(
          'No single recovery signal stands out strongly in your recent data.');
    }
    final limited = items.take(3).toList();
    limited.add(
        'Use these patterns as training guidance, not as a medical assessment.');
    return limited;
  }

  static double _sessionVolume(Map<String, dynamic> session) {
    final stored = _asFiniteDouble(session['totalVolume']);
    if (stored != null) {
      return stored;
    }
    final rawSets = session['sets'];
    if (rawSets is! List) {
      return 0;
    }
    var total = 0.0;
    for (final raw in rawSets) {
      if (raw is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(raw);
      total += _asFiniteDouble(map['volume']) ?? 0;
    }
    return total;
  }

  static double? _asFiniteDouble(dynamic value) {
    final parsed = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return null;
    }
    return parsed;
  }
}
