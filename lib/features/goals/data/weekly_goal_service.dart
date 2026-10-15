import '../../../core/storage/local_store.dart';
import '../../nutrition/data/nutrition_store.dart';
import 'weekly_goal_calculator.dart';
import 'weekly_goal_models.dart';

class WeeklyGoalService {
  WeeklyGoalService._();

  static Future<WeeklyGoalsSnapshot> load({DateTime? date}) async {
    final raw = date ?? DateTime.now();
    final anchor = DateTime(raw.year, raw.month, raw.day);
    final targets = WeeklyGoalTargets.fromMap(await LocalStore.weeklyGoals());
    final history = await LocalStore.history();
    final readiness = await LocalStore.readinessCheckIns();
    final preferences = await NutritionStore.preferences();
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final previousMonday = monday.subtract(const Duration(days: 7));
    final waterTotals = await NutritionStore.waterTotalsBetween(
      start: previousMonday,
      end: anchor,
    );

    return WeeklyGoalCalculator.calculate(
      anchorDate: anchor,
      targets: targets,
      workoutHistory: history,
      readinessDateKeys: readiness
          .map((item) => item['dateKey']?.toString() ?? '')
          .where((value) => value.isNotEmpty)
          .toSet(),
      waterTotalsByDate: waterTotals,
      waterTargetMl: preferences.waterTargetMl,
    );
  }
}
