import 'exercise.dart';

class Workout {
  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final List<Exercise> exercises;
  final String? programSessionKey;
  final String? scheduledDate;
  final int? programWeek;
  final bool isDeload;

  const Workout({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.exercises,
    this.programSessionKey,
    this.scheduledDate,
    this.programWeek,
    this.isDeload = false,
  });
}
