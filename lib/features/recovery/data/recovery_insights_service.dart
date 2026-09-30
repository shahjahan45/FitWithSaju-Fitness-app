import '../../../core/storage/local_store.dart';
import 'readiness_service.dart';
import 'recovery_insights_calculator.dart';
import 'recovery_insights_models.dart';

class RecoveryInsightsService {
  RecoveryInsightsService._();

  static Future<RecoveryInsights> load({DateTime? date}) async {
    final targetRaw = date ?? DateTime.now();
    final target = DateTime(targetRaw.year, targetRaw.month, targetRaw.day);
    final readiness = await ReadinessService.historyFor(
      anchor: target,
      days: 28,
    );
    final workouts = await LocalStore.history();
    return RecoveryInsightsCalculator.calculate(
      anchorDate: target,
      readinessHistory: readiness,
      workoutHistory: workouts,
    );
  }
}
