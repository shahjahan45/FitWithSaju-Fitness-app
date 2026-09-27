import 'package:fitwithsaju/data/models/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Exercise.fromApi maps the remote catalog contract', () {
    final exercise = Exercise.fromApi(<String, dynamic>{
      'id': 'remote-1',
      'name': 'Remote Press',
      'target_muscles': <String>['pectorals'],
      'body_parts': <String>['chest'],
      'equipments': <String>['barbell'],
      'secondary_muscles': <String>['triceps'],
      'instructions': <String>['Set the bench.', 'Press the bar.'],
      'thumbnail_url': 'https://example.com/thumb.gif',
      'media_url': 'https://example.com/media.gif',
      'sets': 4,
      'reps': '8–10',
      'rest_seconds': 90,
    });

    expect(exercise.id, 'remote-1');
    expect(exercise.name, 'Remote Press');
    expect(exercise.targetMuscles, <String>['pectorals']);
    expect(exercise.hasRemoteThumbnail, isTrue);
    expect(exercise.hasRemoteMedia, isTrue);
    expect(exercise.sets, 4);
    expect(exercise.reps, '8–10');
    expect(exercise.restSeconds, 90);
  });

  test('Exercise.fromApi tolerates missing optional arrays and media', () {
    final exercise = Exercise.fromApi(<String, dynamic>{
      'id': 'minimal',
      'name': 'Minimal Exercise',
    });

    expect(exercise.targetMuscles, isEmpty);
    expect(exercise.instructionSteps, isEmpty);
    expect(exercise.hasRemoteMedia, isFalse);
    expect(exercise.sets, 3);
    expect(exercise.restSeconds, 60);
  });
}
