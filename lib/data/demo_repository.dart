import 'models/exercise.dart';
import 'models/workout.dart';

class DemoRepository {
  static const exercises = <Exercise>[
    Exercise(
      id: 'bench_press',
      name: 'Bench Press',
      muscle: 'Chest',
      equipment: 'Barbell',
      difficulty: 'Intermediate',
      instructions:
          'Keep your feet planted, lower the bar with control, and press upward while keeping your shoulder blades stable.',
      sets: 4,
      reps: '8–10',
      restSeconds: 90,
    ),
    Exercise(
      id: 'incline_db_press',
      name: 'Incline Dumbbell Press',
      muscle: 'Upper Chest',
      equipment: 'Dumbbells',
      difficulty: 'Intermediate',
      instructions:
          'Use a moderate incline, keep wrists stacked, lower the dumbbells under control, and press smoothly.',
      sets: 4,
      reps: '10–12',
      restSeconds: 75,
    ),
    Exercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      muscle: 'Back',
      equipment: 'Cable',
      difficulty: 'Beginner',
      instructions:
          'Pull the bar toward the upper chest while keeping your torso stable and avoid swinging.',
      sets: 4,
      reps: '10–12',
      restSeconds: 75,
    ),
    Exercise(
      id: 'shoulder_press',
      name: 'Shoulder Press',
      muscle: 'Shoulders',
      equipment: 'Dumbbells',
      difficulty: 'Intermediate',
      instructions:
          'Brace your core and press overhead without excessively arching your lower back.',
      sets: 3,
      reps: '10',
      restSeconds: 75,
    ),
    Exercise(
      id: 'squat',
      name: 'Back Squat',
      muscle: 'Legs',
      equipment: 'Barbell',
      difficulty: 'Intermediate',
      instructions:
          'Brace before descending, keep knees tracking over toes, and drive through the full foot.',
      sets: 4,
      reps: '8–10',
      restSeconds: 120,
    ),
    Exercise(
      id: 'biceps_curl',
      name: 'Dumbbell Curl',
      muscle: 'Biceps',
      equipment: 'Dumbbells',
      difficulty: 'Beginner',
      instructions:
          'Keep elbows close to the body and curl without using momentum.',
      sets: 3,
      reps: '12',
      restSeconds: 60,
    ),
  ];

  static Workout get todaysWorkout => Workout(
        id: 'push_day',
        title: 'Push Day',
        subtitle: 'Chest • Shoulders • Triceps',
        durationMinutes: 45,
        exercises: exercises.take(4).toList(),
      );
}
