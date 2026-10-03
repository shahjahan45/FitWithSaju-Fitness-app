class TrainingBalanceMetrics {
  final DateTime anchorDate;
  final int currentWorkouts;
  final double currentVolume;
  final double baselineWeeklyWorkouts;
  final double baselineWeeklyVolume;
  final double? volumeRatio;
  final String label;
  final String guidance;

  const TrainingBalanceMetrics({
    required this.anchorDate,
    required this.currentWorkouts,
    required this.currentVolume,
    required this.baselineWeeklyWorkouts,
    required this.baselineWeeklyVolume,
    required this.volumeRatio,
    required this.label,
    required this.guidance,
  });
}

class TrainingPlanPreviewItem {
  final DateTime date;
  final String title;
  final String dayLabel;
  final bool isRest;
  final bool isDeload;
  final String status;
  final bool isRescheduled;

  const TrainingPlanPreviewItem({
    required this.date,
    required this.title,
    required this.dayLabel,
    required this.isRest,
    required this.isDeload,
    required this.status,
    this.isRescheduled = false,
  });
}

class TrainingBalanceSnapshot {
  final TrainingBalanceMetrics balance;
  final List<TrainingPlanPreviewItem> upcoming;
  final int? readinessAverage7;
  final int readinessCheckIns7;
  final String? activeProgramName;

  const TrainingBalanceSnapshot({
    required this.balance,
    required this.upcoming,
    required this.readinessAverage7,
    required this.readinessCheckIns7,
    required this.activeProgramName,
  });

  bool get hasActiveProgram =>
      activeProgramName != null && activeProgramName!.trim().isNotEmpty;
}
