class Exercise {
  final String id;
  final String name;
  final List<String> targetMuscles;
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> secondaryMuscles;
  final List<String> instructionSteps;
  final String thumbnailAsset;
  final String mediaAsset;
  final int sets;
  final String reps;
  final int restSeconds;

  const Exercise({
    required this.id,
    required this.name,
    this.targetMuscles = const <String>[],
    this.bodyParts = const <String>[],
    this.equipments = const <String>[],
    this.secondaryMuscles = const <String>[],
    this.instructionSteps = const <String>[],
    this.thumbnailAsset = '',
    this.mediaAsset = '',
    this.sets = 3,
    this.reps = '10–12',
    this.restSeconds = 60,
  });

  String get muscle => _prettyList(targetMuscles, fallback: 'General');

  String get equipment => _prettyList(equipments, fallback: 'Body weight');

  String get bodyPart => _prettyList(bodyParts, fallback: 'Full body');

  String get secondaryMuscleText =>
      _prettyList(secondaryMuscles, fallback: '—');

  String get instructions => instructionSteps.join('\n');

  String get difficulty => 'Guided';

  bool get hasThumbnail => thumbnailAsset.isNotEmpty;

  bool get hasMedia => mediaAsset.isNotEmpty;

  Iterable<String> get searchableTerms sync* {
    yield name;
    yield* targetMuscles;
    yield* secondaryMuscles;
    yield* bodyParts;
    yield* equipments;
  }

  static String _prettyList(
    List<String> values, {
    required String fallback,
  }) {
    if (values.isEmpty) {
      return fallback;
    }
    return values.map(_titleCase).join(', ');
  }

  static String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
