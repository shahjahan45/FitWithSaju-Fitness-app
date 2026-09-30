import '../core/storage/local_store.dart';

class ProgramCalendarEntry {
  final String sessionKey;
  final String programId;
  final int week;
  final String day;
  final String title;
  final DateTime originalDate;
  final DateTime scheduledDate;
  final bool isRest;
  final bool isDeload;
  final String status;
  final Map<String, dynamic> plan;

  const ProgramCalendarEntry({
    required this.sessionKey,
    required this.programId,
    required this.week,
    required this.day,
    required this.title,
    required this.originalDate,
    required this.scheduledDate,
    required this.isRest,
    required this.isDeload,
    required this.status,
    required this.plan,
  });

  bool get isCompleted => status == 'completed';
  bool get isMissed => status == 'missed';
  bool get isSkipped => status == 'skipped';
  bool get isUpcoming => status == 'upcoming' || status == 'today';
  bool get isToday => status == 'today';
  bool get isRescheduled => !sameDate(originalDate, scheduledDate);

  Map<String, dynamic> planForWorkout() {
    final copy = Map<String, dynamic>.from(plan);
    copy['programSessionKey'] = sessionKey;
    copy['scheduledDate'] = _dateKey(scheduledDate);
    copy['programWeek'] = week;
    copy['isDeload'] = isDeload;
    if (isDeload && copy['isRest'] != true) {
      final baseTitle = (copy['title'] ?? title).toString();
      if (!baseTitle.toLowerCase().startsWith('deload')) {
        copy['title'] = 'Deload • $baseTitle';
      }
      final duration = (copy['durationMinutes'] as num?)?.toInt() ?? 45;
      copy['durationMinutes'] = (duration * .75).round().clamp(15, duration);
    }
    return copy;
  }

  static bool sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class WorkoutProgramSchedule {
  WorkoutProgramSchedule._();

  static DateTime startMonday(Map<String, dynamic> activeProgram) {
    final started =
        DateTime.tryParse(activeProgram['startedAt']?.toString() ?? '') ??
            DateTime.now();
    final date = DateTime(started.year, started.month, started.day);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static int currentWeek(Map<String, dynamic> activeProgram, {DateTime? now}) {
    final todayRaw = now ?? DateTime.now();
    final today = DateTime(todayRaw.year, todayRaw.month, todayRaw.day);
    final start = startMonday(activeProgram);
    final duration = ((activeProgram['durationWeeks'] as num?)?.toInt() ?? 1)
        .clamp(1, 52)
        .toInt();
    final week = today.difference(start).inDays ~/ 7 + 1;
    return week.clamp(1, duration).toInt();
  }

  static List<int> deloadWeeks(Map<String, dynamic> activeProgram) {
    final raw = activeProgram['deloadWeeks'];
    if (raw is! List) {
      return const <int>[];
    }
    return raw
        .map((item) => int.tryParse(item.toString()))
        .whereType<int>()
        .where((week) => week > 0)
        .toSet()
        .toList()
      ..sort();
  }

  static List<ProgramCalendarEntry> build({
    required Map<String, dynamic> activeProgram,
    required List<Map<String, dynamic>> weeklyPlan,
    required List<Map<String, dynamic>> history,
    required List<Map<String, dynamic>> overrides,
    DateTime? now,
  }) {
    final todayRaw = now ?? DateTime.now();
    final today = DateTime(todayRaw.year, todayRaw.month, todayRaw.day);
    final programId = activeProgram['programId']?.toString() ?? '';
    final durationWeeks =
        ((activeProgram['durationWeeks'] as num?)?.toInt() ?? 1)
            .clamp(1, 52)
            .toInt();
    final start = startMonday(activeProgram);
    final deload = deloadWeeks(activeProgram).toSet();

    final planByDay = <String, Map<String, dynamic>>{};
    for (final item in weeklyPlan) {
      final day = item['day']?.toString();
      if (day != null) {
        planByDay[day] = item;
      }
    }
    final overrideByKey = <String, Map<String, dynamic>>{};
    for (final item in overrides) {
      if (item['programId']?.toString() != programId) {
        continue;
      }
      final key = item['sessionKey']?.toString();
      if (key != null && key.isNotEmpty) {
        overrideByKey[key] = item;
      }
    }

    final entries = <ProgramCalendarEntry>[];
    for (var week = 1; week <= durationWeeks; week++) {
      final weekStart = start.add(Duration(days: (week - 1) * 7));
      for (var dayIndex = 0;
          dayIndex < LocalStore.weekDays.length;
          dayIndex++) {
        final day = LocalStore.weekDays[dayIndex];
        final plan = Map<String, dynamic>.from(
          planByDay[day] ??
              <String, dynamic>{
                'day': day,
                'title': 'Rest',
                'isRest': true,
                'durationMinutes': 0,
                'exerciseIds': <String>[],
              },
        );
        final originalDate = weekStart.add(Duration(days: dayIndex));
        final sessionKey = '${programId}_w${week}_${day.toLowerCase()}';
        final override = overrideByKey[sessionKey];
        final scheduledDate =
            _parseDateOnly(override?['scheduledDate']) ?? originalDate;
        final skipped = override?['status']?.toString() == 'skipped';
        final isRest = plan['isRest'] == true;
        final workoutId = 'program_${programId}_${day.toLowerCase()}';
        final completed = !isRest &&
            _sessionCompleted(
              history: history,
              sessionKey: sessionKey,
              workoutId: workoutId,
              scheduledDate: scheduledDate,
              originalWeekStart: weekStart,
            );

        String status;
        final startedAt =
            DateTime.tryParse(activeProgram['startedAt']?.toString() ?? '');
        final startedDay = startedAt == null
            ? null
            : DateTime(startedAt.year, startedAt.month, startedAt.day);
        final beforeEnrollment = week == 1 &&
            startedDay != null &&
            scheduledDate.isBefore(startedDay);
        if (isRest) {
          status = 'rest';
        } else if (beforeEnrollment) {
          status = 'prestart';
        } else if (completed) {
          status = 'completed';
        } else if (skipped) {
          status = 'skipped';
        } else if (ProgramCalendarEntry.sameDate(scheduledDate, today)) {
          status = 'today';
        } else if (scheduledDate.isBefore(today)) {
          status = 'missed';
        } else {
          status = 'upcoming';
        }

        entries.add(ProgramCalendarEntry(
          sessionKey: sessionKey,
          programId: programId,
          week: week,
          day: day,
          title: plan['title']?.toString() ?? 'Workout',
          originalDate: originalDate,
          scheduledDate: scheduledDate,
          isRest: isRest,
          isDeload: deload.contains(week),
          status: status,
          plan: plan,
        ));
      }
    }
    return entries;
  }

  static bool _sessionCompleted({
    required List<Map<String, dynamic>> history,
    required String sessionKey,
    required String workoutId,
    required DateTime scheduledDate,
    required DateTime originalWeekStart,
  }) {
    final originalWeekEnd = originalWeekStart.add(const Duration(days: 7));
    for (final session in history) {
      if (session['programSessionKey']?.toString() == sessionKey) {
        return true;
      }
      if (session['workoutId']?.toString() != workoutId) {
        continue;
      }
      final date = DateTime.tryParse(session['date']?.toString() ?? '');
      if (date == null) {
        continue;
      }
      final d = DateTime(date.year, date.month, date.day);
      if (ProgramCalendarEntry.sameDate(d, scheduledDate)) return true;
      if (!d.isBefore(originalWeekStart) && d.isBefore(originalWeekEnd)) {
        return true;
      }
    }
    return false;
  }

  static DateTime? _parseDateOnly(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      return null;
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
