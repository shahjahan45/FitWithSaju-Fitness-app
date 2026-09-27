import 'package:fitwithsaju/data/demo_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user-provided exercise catalog has 30 unique media-backed exercises',
      () {
    final exercises = DemoRepository.exercises;
    final ids = exercises.map((exercise) => exercise.id).toSet();

    expect(exercises.length, 30);
    expect(ids.length, exercises.length);
    expect(exercises.every((exercise) => exercise.hasThumbnail), isTrue);
    expect(exercises.every((exercise) => exercise.hasMedia), isTrue);
    expect(
      exercises.every((exercise) => exercise.instructionSteps.isNotEmpty),
      isTrue,
    );
  });

  test('legacy ids remain resolvable without appearing in Explore catalog', () {
    expect(DemoRepository.findExerciseById('bench_press'), isNotNull);
    expect(
      DemoRepository.exercises.any((exercise) => exercise.id == 'bench_press'),
      isFalse,
    );
  });
}
