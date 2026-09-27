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
  final String thumbnailUrl;
  final String mediaUrl;
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
    this.thumbnailUrl = '',
    this.mediaUrl = '',
    this.sets = 3,
    this.reps = '10–12',
    this.restSeconds = 60,
  });

  factory Exercise.fromApi(Map<String, dynamic> json) {
    List<String> strings(dynamic value) {
      if (value is List) {
        return value.map((item) => item.toString()).toList(growable: false);
      }
      if (value is String && value.trim().isNotEmpty) {
        return <String>[value.trim()];
      }
      return const <String>[];
    }

    return Exercise(
      id: (json['id'] ?? json['exercise_id'] ?? '').toString(),
      name: (json['name'] ?? 'Exercise').toString(),
      targetMuscles: strings(json['target_muscles'] ?? json['targetMuscles']),
      bodyParts: strings(json['body_parts'] ?? json['bodyParts']),
      equipments: strings(json['equipments'] ?? json['equipment']),
      secondaryMuscles:
          strings(json['secondary_muscles'] ?? json['secondaryMuscles']),
      instructionSteps: strings(json['instructions']),
      thumbnailUrl: (json['thumbnail_url'] ?? '').toString(),
      mediaUrl: (json['media_url'] ?? '').toString(),
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      reps: (json['reps'] ?? '10–12').toString(),
      restSeconds: (json['rest_seconds'] as num?)?.toInt() ?? 60,
    );
  }

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'target_muscles': targetMuscles,
        'body_parts': bodyParts,
        'equipments': equipments,
        'secondary_muscles': secondaryMuscles,
        'instructions': instructionSteps,
        'thumbnail_url': thumbnailUrl,
        'media_url': mediaUrl,
        'sets': sets,
        'reps': reps,
        'rest_seconds': restSeconds,
      };

  String get muscle => _prettyList(targetMuscles, fallback: 'General');

  String get equipment => _prettyList(equipments, fallback: 'Body weight');

  String get bodyPart => _prettyList(bodyParts, fallback: 'Full body');

  String get secondaryMuscleText =>
      _prettyList(secondaryMuscles, fallback: '—');

  String get instructions => instructionSteps.join('\n');

  String get difficulty => 'Guided';

  bool get hasThumbnail => thumbnailAsset.isNotEmpty || thumbnailUrl.isNotEmpty;

  bool get hasMedia => mediaAsset.isNotEmpty || mediaUrl.isNotEmpty;

  bool get hasRemoteThumbnail => thumbnailUrl.isNotEmpty;

  bool get hasRemoteMedia => mediaUrl.isNotEmpty;

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
