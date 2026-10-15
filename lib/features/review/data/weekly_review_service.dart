import '../../../core/storage/local_store.dart';
import '../../goals/data/weekly_goal_service.dart';
import '../../recovery/data/readiness_models.dart';
import '../../recovery/data/readiness_service.dart';
import 'weekly_review_calculator.dart';
import 'weekly_review_models.dart';

class WeeklyReviewService {
  WeeklyReviewService._();

  static Future<WeeklyReviewSnapshot> load({DateTime? date}) async {
    final raw = date ?? DateTime.now();
    final anchor = DateTime(raw.year, raw.month, raw.day);
    final previousComparable = anchor.subtract(const Duration(days: 7));
    final historyFuture = LocalStore.history();
    final currentGoalsFuture = WeeklyGoalService.load(date: anchor);
    final previousGoalsFuture = WeeklyGoalService.load(date: previousComparable);
    final currentReadinessFuture = ReadinessService.historyFor(
      anchor: anchor,
      days: anchor.weekday,
    );
    final previousReadinessFuture = ReadinessService.historyFor(
      anchor: previousComparable,
      days: previousComparable.weekday,
    );

    final history = await historyFuture;
    final currentGoals = await currentGoalsFuture;
    final previousGoals = await previousGoalsFuture;
    final currentReadiness = await currentReadinessFuture;
    final previousReadiness = await previousReadinessFuture;

    int? average(List<ReadinessHistoryPoint> points) {
      if (points.isEmpty) {
        return null;
      }
      final total = points.fold<int>(0, (sum, item) => sum + item.score);
      return (total / points.length).round();
    }

    return WeeklyReviewCalculator.calculate(
      anchorDate: anchor,
      workoutHistory: history,
      currentHydrationDays: currentGoals.hydrationDays.current,
      currentReadinessDays: currentGoals.readinessDays.current,
      currentReadinessAverage: average(currentReadiness),
      currentGoalsMet: currentGoals.goalsMet,
      currentGoalProgress: currentGoals.overallProgress,
      previousHydrationDays: previousGoals.hydrationDays.current,
      previousReadinessDays: previousGoals.readinessDays.current,
      previousReadinessAverage: average(previousReadiness),
      previousGoalsMet: previousGoals.goalsMet,
      previousGoalProgress: previousGoals.overallProgress,
    );
  }
}
