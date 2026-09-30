class WorkoutProgramDefinition {
  final String id;
  final String name;
  final String level;
  final String description;
  final int trainingDays;
  final int durationWeeks;
  final List<String> tags;
  final List<Map<String, dynamic>> weeklyPlan;

  const WorkoutProgramDefinition({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.trainingDays,
    required this.durationWeeks,
    required this.tags,
    required this.weeklyPlan,
  });

  List<Map<String, dynamic>> planWithProgramMetadata() {
    return weeklyPlan.map((day) {
      final copy = Map<String, dynamic>.from(day);
      copy['programId'] = id;
      copy['programName'] = name;
      copy['programDayKey'] =
          '${id}_${(day['day'] ?? '').toString().toLowerCase()}';
      return copy;
    }).toList();
  }
}

class WorkoutProgramCatalog {
  WorkoutProgramCatalog._();

  static const programs = <WorkoutProgramDefinition>[
    WorkoutProgramDefinition(
      id: 'foundation_3',
      name: 'Foundation 3-Day',
      level: 'Beginner',
      description:
          'A recovery-friendly full-body structure for building consistency, movement quality, and basic strength.',
      trainingDays: 3,
      durationWeeks: 6,
      tags: ['Full body', 'Consistency', 'Recovery friendly'],
      weeklyPlan: [
        {
          'day': 'Monday',
          'title': 'Full Body A',
          'isRest': false,
          'durationMinutes': 45,
          'exerciseIds': ['2Qh2J1e', '3TZduzM', '7F1DVzn', '6cKQC5E'],
        },
        {
          'day': 'Tuesday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
        {
          'day': 'Wednesday',
          'title': 'Full Body B',
          'isRest': false,
          'durationMinutes': 45,
          'exerciseIds': ['5bpPTHv', '3eGE2JC', '7I6LNUG', '8eqjhOl'],
        },
        {
          'day': 'Thursday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
        {
          'day': 'Friday',
          'title': 'Full Body C',
          'isRest': false,
          'durationMinutes': 45,
          'exerciseIds': ['2ORFMoR', '5uFK1xr', '4dF3maG', '8xUv4J7'],
        },
        {
          'day': 'Saturday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
        {
          'day': 'Sunday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
      ],
    ),
    WorkoutProgramDefinition(
      id: 'strength_4',
      name: 'Strength 4-Day',
      level: 'Intermediate',
      description:
          'An upper/lower split with four focused training days and recovery between the heavier sessions.',
      trainingDays: 4,
      durationWeeks: 8,
      tags: ['Upper / lower', 'Strength', '4 days'],
      weeklyPlan: [
        {
          'day': 'Monday',
          'title': 'Upper Strength',
          'isRest': false,
          'durationMinutes': 55,
          'exerciseIds': ['3TZduzM', '7F1DVzn', '5uFK1xr', '6cKQC5E'],
        },
        {
          'day': 'Tuesday',
          'title': 'Lower Strength',
          'isRest': false,
          'durationMinutes': 55,
          'exerciseIds': ['2Qh2J1e', '5bpPTHv', '2ORFMoR', '8eqjhOl'],
        },
        {
          'day': 'Wednesday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
        {
          'day': 'Thursday',
          'title': 'Upper Volume',
          'isRest': false,
          'durationMinutes': 50,
          'exerciseIds': ['3eGE2JC', '7I6LNUG', '4dF3maG', '8oYqOt9'],
        },
        {
          'day': 'Friday',
          'title': 'Lower Volume',
          'isRest': false,
          'durationMinutes': 50,
          'exerciseIds': ['2Qh2J1e', '5bpPTHv', '8xUv4J7', '8eqjhOl'],
        },
        {
          'day': 'Saturday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
        {
          'day': 'Sunday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
      ],
    ),
    WorkoutProgramDefinition(
      id: 'hypertrophy_5',
      name: 'Hypertrophy 5-Day',
      level: 'Intermediate / Advanced',
      description:
          'A five-day muscle-building split for users who recover well and prefer more weekly training volume.',
      trainingDays: 5,
      durationWeeks: 8,
      tags: ['Muscle gain', 'Higher volume', '5 days'],
      weeklyPlan: [
        {
          'day': 'Monday',
          'title': 'Push',
          'isRest': false,
          'durationMinutes': 60,
          'exerciseIds': ['3TZduzM', '3eGE2JC', '5uFK1xr', '6cKQC5E'],
        },
        {
          'day': 'Tuesday',
          'title': 'Pull',
          'isRest': false,
          'durationMinutes': 60,
          'exerciseIds': ['7F1DVzn', '7I6LNUG', '4dF3maG', '8oYqOt9'],
        },
        {
          'day': 'Wednesday',
          'title': 'Legs',
          'isRest': false,
          'durationMinutes': 60,
          'exerciseIds': ['2Qh2J1e', '5bpPTHv', '2ORFMoR', '8eqjhOl'],
        },
        {
          'day': 'Thursday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
        {
          'day': 'Friday',
          'title': 'Upper',
          'isRest': false,
          'durationMinutes': 60,
          'exerciseIds': ['5v7KYld', '7F1DVzn', '3eGE2JC', '6cKQC5E'],
        },
        {
          'day': 'Saturday',
          'title': 'Lower + Core',
          'isRest': false,
          'durationMinutes': 55,
          'exerciseIds': ['2Qh2J1e', '5bpPTHv', '8xUv4J7', '8eqjhOl'],
        },
        {
          'day': 'Sunday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
      ],
    ),
  ];

  static WorkoutProgramDefinition? find(String id) {
    for (final program in programs) {
      if (program.id == id) {
        return program;
      }
    }
    return null;
  }
}

class WorkoutProgramProgress {
  final int currentWeek;
  final int durationWeeks;
  final int completedSessions;
  final int totalSessions;
  final int thisWeekCompleted;
  final int thisWeekPlanned;
  final double completion;
  final bool durationElapsed;

  const WorkoutProgramProgress({
    required this.currentWeek,
    required this.durationWeeks,
    required this.completedSessions,
    required this.totalSessions,
    required this.thisWeekCompleted,
    required this.thisWeekPlanned,
    required this.completion,
    required this.durationElapsed,
  });

  static WorkoutProgramProgress calculate({
    required Map<String, dynamic> activeProgram,
    required List<Map<String, dynamic>> history,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final programId = activeProgram['programId']?.toString() ?? '';
    final durationWeeks =
        ((activeProgram['durationWeeks'] as num?)?.toInt() ?? 1)
            .clamp(1, 52)
            .toInt();
    final trainingDays = ((activeProgram['trainingDays'] as num?)?.toInt() ?? 1)
        .clamp(1, 7)
        .toInt();
    final startedAt =
        DateTime.tryParse(activeProgram['startedAt']?.toString() ?? '') ??
            current;
    final startDay = DateTime(startedAt.year, startedAt.month, startedAt.day);
    final today = DateTime(current.year, current.month, current.day);
    final elapsedDays =
        today.difference(startDay).inDays.clamp(0, 9999).toInt();
    final currentWeek = (elapsedDays ~/ 7 + 1).clamp(1, durationWeeks).toInt();
    final rawWeekdays = activeProgram['trainingWeekdays'];
    final trainingWeekdays = rawWeekdays is List
        ? rawWeekdays
            .map((item) => int.tryParse(item.toString()))
            .whereType<int>()
            .where((day) => day >= 1 && day <= 7)
            .toSet()
            .toList()
        : <int>[];
    final preStartSessions = trainingWeekdays.isEmpty
        ? 0
        : trainingWeekdays.where((day) => day < startDay.weekday).length;
    final totalSessions = (trainingDays * durationWeeks - preStartSessions)
        .clamp(0, trainingDays * durationWeeks)
        .toInt();

    final monday = today.subtract(Duration(days: today.weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));
    var completedSessions = 0;
    var thisWeekCompleted = 0;

    for (final session in history) {
      final workoutId = session['workoutId']?.toString() ?? '';
      if (!workoutId.startsWith('program_${programId}_')) {
        continue;
      }
      final date = DateTime.tryParse(session['date']?.toString() ?? '');
      if (date == null || date.isBefore(startedAt)) {
        continue;
      }
      completedSessions++;
      if (!date.isBefore(monday) && date.isBefore(nextMonday)) {
        thisWeekCompleted++;
      }
    }

    final cappedCompleted = completedSessions.clamp(0, totalSessions);
    return WorkoutProgramProgress(
      currentWeek: currentWeek,
      durationWeeks: durationWeeks,
      completedSessions: cappedCompleted.toInt(),
      totalSessions: totalSessions,
      thisWeekCompleted: thisWeekCompleted.clamp(0, trainingDays).toInt(),
      thisWeekPlanned: currentWeek == 1 && trainingWeekdays.isNotEmpty
          ? trainingWeekdays.where((day) => day >= startDay.weekday).length
          : trainingDays,
      completion: totalSessions == 0 ? 0 : cappedCompleted / totalSessions,
      durationElapsed: elapsedDays >= durationWeeks * 7,
    );
  }
}
