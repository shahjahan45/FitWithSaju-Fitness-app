import 'demo_repository.dart';
import 'models/exercise.dart';
import 'models/workout.dart';

class WorkoutFactory {
  WorkoutFactory._();

  static Exercise? exerciseById(String id) {
    for (final exercise in DemoRepository.exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return null;
  }

  static List<Exercise> exercisesFromIds(Iterable<dynamic> ids) {
    return ids
        .map((id) => exerciseById(id.toString()))
        .whereType<Exercise>()
        .toList();
  }

  static Workout fromPlan(Map<String, dynamic> map) {
    final exercises = exercisesFromIds(map['exerciseIds'] as Iterable? ?? const []);
    return Workout(
      id: 'plan_${map['day'] ?? 'day'}',
      title: (map['title'] ?? 'Workout').toString(),
      subtitle: muscleSummary(exercises),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ??
          (exercises.length * 10).clamp(10, 90).toInt(),
      exercises: exercises,
    );
  }

  static Workout fromCustom(Map<String, dynamic> map) {
    final exercises = exercisesFromIds(map['exerciseIds'] as Iterable? ?? const []);
    return Workout(
      id: (map['id'] ?? 'custom').toString(),
      title: (map['name'] ?? 'Custom Workout').toString(),
      subtitle: muscleSummary(exercises),
      durationMinutes: (exercises.length * 10).clamp(15, 90).toInt(),
      exercises: exercises,
    );
  }

  static String muscleSummary(List<Exercise> exercises) {
    if (exercises.isEmpty) {
      return 'Recovery day';
    }
    final muscles = <String>[];
    for (final exercise in exercises) {
      if (!muscles.contains(exercise.muscle)) {
        muscles.add(exercise.muscle);
      }
      if (muscles.length == 3) {
        break;
      }
    }
    return muscles.join(' • ');
  }
}
