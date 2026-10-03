import 'training_balance_models.dart';

class TrainingBalanceCalculator {
  TrainingBalanceCalculator._();

  static TrainingBalanceMetrics calculate({
    required DateTime anchorDate,
    required List<Map<String, dynamic>> workoutHistory,
    int? readinessAverage7,
  }) {
    final anchor = _day(anchorDate);
    final currentStart = anchor.subtract(const Duration(days: 6));
    final baselineStart = anchor.subtract(const Duration(days: 27));
    final baselineEnd = anchor.subtract(const Duration(days: 7));

    var currentWorkouts = 0;
    var currentVolume = 0.0;
    var baselineWorkouts = 0;
    var baselineVolume = 0.0;

    for (final session in workoutHistory) {
      final parsed = DateTime.tryParse(session['date']?.toString() ?? '');
      if (parsed == null) {
        continue;
      }
      final date = _day(parsed);
      final volume = _sessionVolume(session);
      if (!date.isBefore(currentStart) && !date.isAfter(anchor)) {
        currentWorkouts++;
        currentVolume += volume;
      } else if (!date.isBefore(baselineStart) && !date.isAfter(baselineEnd)) {
        baselineWorkouts++;
        baselineVolume += volume;
      }
    }

    final baselineWeeklyWorkouts = baselineWorkouts / 3;
    final baselineWeeklyVolume = baselineVolume / 3;
    final ratio =
        baselineWeeklyVolume > 0 ? currentVolume / baselineWeeklyVolume : null;

    final label = _label(ratio);
    final guidance = _guidance(
      ratio: ratio,
      readinessAverage7: readinessAverage7,
      currentWorkouts: currentWorkouts,
      baselineWeeklyWorkouts: baselineWeeklyWorkouts,
    );

    return TrainingBalanceMetrics(
      anchorDate: anchor,
      currentWorkouts: currentWorkouts,
      currentVolume: currentVolume,
      baselineWeeklyWorkouts: baselineWeeklyWorkouts,
      baselineWeeklyVolume: baselineWeeklyVolume,
      volumeRatio: ratio,
      label: label,
      guidance: guidance,
    );
  }

  static String _label(double? ratio) {
    if (ratio == null) {
      return 'Building training baseline';
    }
    if (ratio < .65) {
      return 'Lighter than recent baseline';
    }
    if (ratio <= 1.20) {
      return 'Near your recent baseline';
    }
    if (ratio <= 1.50) {
      return 'Above your recent baseline';
    }
    return 'Well above recent baseline';
  }

  static String _guidance({
    required double? ratio,
    required int? readinessAverage7,
    required int currentWorkouts,
    required double baselineWeeklyWorkouts,
  }) {
    if (ratio == null) {
      return 'Keep logging workouts to build a useful comparison. Use readiness and your warm-up to guide today’s effort.';
    }
    if (ratio > 1.50 && readinessAverage7 != null && readinessAverage7 < 60) {
      return 'Training volume is high versus your recent baseline while recovery check-ins are lower. Consider protecting recovery time or choosing a lighter session.';
    }
    if (ratio > 1.35) {
      return 'Your recent training volume is elevated. Keep the planned schedule if it feels appropriate, but avoid adding unnecessary extra volume.';
    }
    if (ratio < .65 && currentWorkouts < baselineWeeklyWorkouts.round()) {
      return 'This has been a lighter training week. Continue the plan you chose rather than trying to make up missed volume all at once.';
    }
    if (readinessAverage7 != null && readinessAverage7 < 55) {
      return 'Training load is near your baseline, but recent readiness is lower. Use a progressive warm-up and keep reductions optional and user-controlled.';
    }
    return 'Your recent training load is close to your established baseline. Continue using readiness, warm-up feedback and your planned schedule together.';
  }

  static double _sessionVolume(Map<String, dynamic> session) {
    final stored = _finiteDouble(session['totalVolume']);
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
      final set = Map<String, dynamic>.from(raw);
      total += _finiteDouble(set['volume']) ?? 0;
    }
    return total;
  }

  static double? _finiteDouble(dynamic value) {
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
