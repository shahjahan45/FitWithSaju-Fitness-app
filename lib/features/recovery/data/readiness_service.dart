import '../../../core/storage/local_store.dart';
import '../../../data/workout_program_schedule.dart';
import '../../nutrition/data/nutrition_store.dart';
import 'readiness_calculator.dart';
import 'readiness_models.dart';

class ReadinessService {
  ReadinessService._();

  static Future<ReadinessSnapshot> load({DateTime? date}) async {
    final targetRaw = date ?? DateTime.now();
    final target = DateTime(targetRaw.year, targetRaw.month, targetRaw.day);
    final history = await LocalStore.history();
    final activeProgram = await LocalStore.activeProgram();
    final weeklyPlan = await LocalStore.weeklyPlan();
    final overrides = await LocalStore.programScheduleOverrides();
    final checkInMap = await LocalStore.readinessCheckInForDate(target);
    final waterMl = await NutritionStore.waterTotalMl(target);
    final nutritionPreferences = await NutritionStore.preferences();
    final load = trainingLoadFor(history, target);
    final programSession = _programSessionForDate(
      date: target,
      activeProgram: activeProgram,
      weeklyPlan: weeklyPlan,
      history: history,
      overrides: overrides,
    );

    final checkIn =
        checkInMap == null ? null : ReadinessCheckIn.fromJson(checkInMap);
    final assessment = checkIn == null
        ? null
        : ReadinessCalculator.calculate(
            checkIn: checkIn,
            hydrationMl: waterMl,
            hydrationTargetMl: nutritionPreferences.waterTargetMl,
            trainingLoad: load,
            hasActiveProgram: activeProgram != null,
            hasProgramSessionToday:
                programSession != null && !programSession.isRest,
            isRestOrDeloadDay: programSession?.isRest == true ||
                programSession?.isDeload == true,
          );

    final recentHistory = await _recentHistory(
      anchor: target,
      workoutHistory: history,
      activeProgram: activeProgram,
      weeklyPlan: weeklyPlan,
      overrides: overrides,
      waterTargetMl: nutritionPreferences.waterTargetMl,
    );

    return ReadinessSnapshot(
      date: target,
      checkIn: checkIn,
      assessment: assessment,
      waterMl: waterMl,
      waterTargetMl: nutritionPreferences.waterTargetMl,
      trainingLoad: load,
      programSession: programSession,
      history: recentHistory,
    );
  }

  static TrainingLoadContext trainingLoadFor(
    List<Map<String, dynamic>> history,
    DateTime date,
  ) {
    final anchor = DateTime(date.year, date.month, date.day);
    final currentStart = anchor.subtract(const Duration(days: 6));
    final previousStart = anchor.subtract(const Duration(days: 13));
    final previousEnd = anchor.subtract(const Duration(days: 7));
    var currentVolume = 0.0;
    var previousVolume = 0.0;
    var currentWorkouts = 0;
    var previousWorkouts = 0;

    for (final session in history) {
      final parsed = DateTime.tryParse(session['date']?.toString() ?? '');
      if (parsed == null) {
        continue;
      }
      final day = DateTime(parsed.year, parsed.month, parsed.day);
      final volume = _sessionVolume(session);
      if (!day.isBefore(currentStart) && !day.isAfter(anchor)) {
        currentVolume += volume;
        currentWorkouts++;
      } else if (!day.isBefore(previousStart) && !day.isAfter(previousEnd)) {
        previousVolume += volume;
        previousWorkouts++;
      }
    }

    return TrainingLoadContext(
      last7DaysVolume: currentVolume,
      previous7DaysVolume: previousVolume,
      last7DaysWorkouts: currentWorkouts,
      previous7DaysWorkouts: previousWorkouts,
    );
  }

  static Future<List<ReadinessHistoryPoint>> _recentHistory({
    required DateTime anchor,
    required List<Map<String, dynamic>> workoutHistory,
    required Map<String, dynamic>? activeProgram,
    required List<Map<String, dynamic>> weeklyPlan,
    required List<Map<String, dynamic>> overrides,
    required int waterTargetMl,
  }) async {
    final all = await LocalStore.readinessCheckIns();
    final start = anchor.subtract(const Duration(days: 6));
    final points = <ReadinessHistoryPoint>[];
    for (final item in all) {
      final date =
          LocalStore.dateFromLocalKey(item['dateKey']?.toString() ?? '');
      if (date == null || date.isBefore(start) || date.isAfter(anchor)) {
        continue;
      }
      final checkIn = ReadinessCheckIn.fromJson(item);
      final water = await NutritionStore.waterTotalMl(date);
      final load = trainingLoadFor(workoutHistory, date);
      final session = _programSessionForDate(
        date: date,
        activeProgram: activeProgram,
        weeklyPlan: weeklyPlan,
        history: workoutHistory,
        overrides: overrides,
      );
      final assessment = ReadinessCalculator.calculate(
        checkIn: checkIn,
        hydrationMl: water,
        hydrationTargetMl: waterTargetMl,
        trainingLoad: load,
        hasActiveProgram: activeProgram != null,
        hasProgramSessionToday: session != null && !session.isRest,
        isRestOrDeloadDay: session?.isRest == true || session?.isDeload == true,
      );
      points.add(ReadinessHistoryPoint(
        date: date,
        score: assessment.score,
        checkIn: checkIn,
      ));
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  static ProgramCalendarEntry? _programSessionForDate({
    required DateTime date,
    required Map<String, dynamic>? activeProgram,
    required List<Map<String, dynamic>> weeklyPlan,
    required List<Map<String, dynamic>> history,
    required List<Map<String, dynamic>> overrides,
  }) {
    if (activeProgram == null) {
      return null;
    }
    final entries = WorkoutProgramSchedule.build(
      activeProgram: activeProgram,
      weeklyPlan: weeklyPlan,
      history: history,
      overrides: overrides,
      now: date,
    );
    ProgramCalendarEntry? restFallback;
    for (final entry in entries) {
      if (!ProgramCalendarEntry.sameDate(entry.scheduledDate, date)) {
        continue;
      }
      if (!entry.isRest) {
        return entry;
      }
      restFallback ??= entry;
    }
    return restFallback;
  }

  static double _sessionVolume(Map<String, dynamic> session) {
    final stored = (session['totalVolume'] as num?)?.toDouble();
    if (stored != null) {
      return stored;
    }
    return LocalStore.sessionSets(session).fold<double>(
      0,
      (sum, set) => sum + ((set['volume'] as num?)?.toDouble() ?? 0),
    );
  }
}
