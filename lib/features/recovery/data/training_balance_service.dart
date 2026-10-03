import '../../../core/storage/local_store.dart';
import '../../../data/workout_program_schedule.dart';
import 'readiness_service.dart';
import 'training_balance_calculator.dart';
import 'training_balance_models.dart';

class TrainingBalanceService {
  TrainingBalanceService._();

  static Future<TrainingBalanceSnapshot> load({DateTime? date}) async {
    final raw = date ?? DateTime.now();
    final anchor = DateTime(raw.year, raw.month, raw.day);
    final history = await LocalStore.history();
    final weeklyPlan = await LocalStore.weeklyPlan();
    final activeProgram = await LocalStore.activeProgram();
    final overrides = await LocalStore.programScheduleOverrides();
    final readiness =
        await ReadinessService.historyFor(anchor: anchor, days: 7);
    final readinessAverage = readiness.isEmpty
        ? null
        : (readiness.fold<int>(0, (sum, item) => sum + item.score) /
                readiness.length)
            .round();

    final balance = TrainingBalanceCalculator.calculate(
      anchorDate: anchor,
      workoutHistory: history,
      readinessAverage7: readinessAverage,
    );

    final upcoming = activeProgram == null
        ? _weeklyPlanPreview(anchor: anchor, weeklyPlan: weeklyPlan)
        : _programPreview(
            anchor: anchor,
            activeProgram: activeProgram,
            weeklyPlan: weeklyPlan,
            history: history,
            overrides: overrides,
          );

    return TrainingBalanceSnapshot(
      balance: balance,
      upcoming: upcoming,
      readinessAverage7: readinessAverage,
      readinessCheckIns7: readiness.length,
      activeProgramName: activeProgram?['name']?.toString(),
    );
  }

  static List<TrainingPlanPreviewItem> _programPreview({
    required DateTime anchor,
    required Map<String, dynamic> activeProgram,
    required List<Map<String, dynamic>> weeklyPlan,
    required List<Map<String, dynamic>> history,
    required List<Map<String, dynamic>> overrides,
  }) {
    final end = anchor.add(const Duration(days: 6));
    final entries = WorkoutProgramSchedule.build(
      activeProgram: activeProgram,
      weeklyPlan: weeklyPlan,
      history: history,
      overrides: overrides,
      now: anchor,
    ).where((entry) {
      return !entry.scheduledDate.isBefore(anchor) &&
          !entry.scheduledDate.isAfter(end) &&
          entry.status != 'completed' &&
          entry.status != 'skipped' &&
          entry.status != 'prestart';
    }).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return entries
        .map(
          (entry) => TrainingPlanPreviewItem(
            date: entry.scheduledDate,
            title: entry.title,
            dayLabel: entry.day,
            isRest: entry.isRest,
            isDeload: entry.isDeload,
            status: entry.status,
            isRescheduled: entry.isRescheduled,
          ),
        )
        .toList();
  }

  static List<TrainingPlanPreviewItem> _weeklyPlanPreview({
    required DateTime anchor,
    required List<Map<String, dynamic>> weeklyPlan,
  }) {
    final byDay = <String, Map<String, dynamic>>{
      for (final item in weeklyPlan)
        if (item['day'] != null) item['day'].toString(): item,
    };

    return List<TrainingPlanPreviewItem>.generate(7, (index) {
      final date = anchor.add(Duration(days: index));
      final day = LocalStore.weekDays[date.weekday - 1];
      final plan = byDay[day];
      final isRest = plan?['isRest'] == true || plan == null;
      return TrainingPlanPreviewItem(
        date: date,
        title: plan?['title']?.toString() ?? 'Rest',
        dayLabel: day,
        isRest: isRest,
        isDeload: false,
        status: index == 0 ? 'today' : 'upcoming',
      );
    });
  }
}
