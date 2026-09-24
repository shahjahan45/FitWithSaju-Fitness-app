import 'exercise.dart';

class Workout {
  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.exercises,
  });
}
