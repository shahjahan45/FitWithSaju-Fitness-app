class Exercise {
  final String id;
  final String name;
  final String muscle;
  final String equipment;
  final String difficulty;
  final String instructions;
  final int sets;
  final String reps;
  final int restSeconds;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.sets,
    required this.reps,
    required this.restSeconds,
  });
}
