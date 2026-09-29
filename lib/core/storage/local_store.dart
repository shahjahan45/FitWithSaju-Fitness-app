import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void _notify() => changes.value++;
  static const _onboardingKey = 'onboarding_complete';
  static const _goalKey = 'fitness_goal';
  static const _levelKey = 'fitness_level';
  static const _placeKey = 'training_place';
  static const _favoritesKey = 'favorite_exercises';
  static const _historyKey = 'workout_history';
  static const _weeklyPlanKey = 'weekly_plan_v1';
  static const _customWorkoutsKey = 'custom_workouts_v1';
  static const _weightEntriesKey = 'weight_entries_v1';
  static const _measurementEntriesKey = 'measurement_entries_v1';
  static const _activeWorkoutKey = 'active_workout_v1';
  static const _activeProgramKey = 'active_program_v1';
  static const _programHistoryKey = 'program_history_v1';

  static const List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static Future<bool> onboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<Map<String, String>> profile() async {
    final prefs = await SharedPreferences.getInstance();
    return <String, String>{
      'goal': prefs.getString(_goalKey) ?? 'Build Muscle',
      'level': prefs.getString(_levelKey) ?? 'Beginner',
      'place': prefs.getString(_placeKey) ?? 'Gym',
    };
  }

  static Future<void> saveProfile({
    required String goal,
    required String level,
    required String place,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalKey, goal);
    await prefs.setString(_levelKey, level);
    await prefs.setString(_placeKey, place);
    await prefs.setBool(_onboardingKey, true);
    _notify();
  }

  static Future<void> skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    _notify();
  }

  static Future<Set<String>> favorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? const <String>[]).toSet();
  }

  static Future<bool> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = (prefs.getStringList(_favoritesKey) ?? <String>[]).toSet();
    final added = !items.contains(id);
    if (added) {
      items.add(id);
    } else {
      items.remove(id);
    }
    await prefs.setStringList(_favoritesKey, items.toList());
    _notify();
    return added;
  }

  static Future<List<Map<String, dynamic>>> history() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_historyKey));
  }

  static Future<void> addWorkoutHistory(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await history();
    current.insert(0, item);
    await prefs.setString(_historyKey, jsonEncode(current.take(100).toList()));
    _notify();
  }

  static Future<List<Map<String, dynamic>>> weeklyPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weeklyPlanKey);
    if (raw == null || raw.isEmpty) {
      final defaults = _defaultWeeklyPlan();
      await prefs.setString(_weeklyPlanKey, jsonEncode(defaults));
      return defaults;
    }
    return _decodeList(raw);
  }

  static Future<Map<String, dynamic>> todayPlan() async {
    final plan = await weeklyPlan();
    final today = weekDays[DateTime.now().weekday - 1];
    return plan.firstWhere(
      (item) => item['day'] == today,
      orElse: () => <String, dynamic>{
        'day': today,
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[],
      },
    );
  }

  static Future<void> saveDayPlan(Map<String, dynamic> dayPlan) async {
    final prefs = await SharedPreferences.getInstance();
    final plan = await weeklyPlan();
    final day = dayPlan['day'] as String;
    final index = plan.indexWhere((item) => item['day'] == day);
    if (index >= 0) {
      plan[index] = dayPlan;
    } else {
      plan.add(dayPlan);
    }
    await prefs.setString(_weeklyPlanKey, jsonEncode(plan));
    _notify();
  }

  static Future<void> replaceWeeklyPlan(
    List<Map<String, dynamic>> weeklyPlan,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = weekDays.map((day) {
      Map<String, dynamic>? match;
      for (final item in weeklyPlan) {
        if (item['day'] == day) {
          match = item;
          break;
        }
      }
      if (match == null) {
        return <String, dynamic>{
          'day': day,
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        };
      }
      return Map<String, dynamic>.from(match);
    }).toList();
    await prefs.setString(_weeklyPlanKey, jsonEncode(normalized));
    _notify();
  }

  static Future<void> copyDayPlan(String fromDay, String toDay) async {
    final plan = await weeklyPlan();
    final source = plan.firstWhere((item) => item['day'] == fromDay);
    final copy = Map<String, dynamic>.from(source)..['day'] = toDay;
    await saveDayPlan(copy);
  }

  static Future<void> setRestDay(String day) async {
    final plan = await weeklyPlan();
    Map<String, dynamic>? existing;
    for (final item in plan) {
      if (item['day'] == day) {
        existing = item;
        break;
      }
    }
    await saveDayPlan(<String, dynamic>{
      'day': day,
      'title': 'Rest',
      'isRest': true,
      'durationMinutes': 0,
      'exerciseIds': <String>[],
      if (existing?['programId'] != null) 'programId': existing!['programId'],
      if (existing?['programName'] != null)
        'programName': existing!['programName'],
      if (existing?['programDayKey'] != null)
        'programDayKey': existing!['programDayKey'],
    });
  }

  static Future<Map<String, dynamic>?> activeProgram() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeProgramKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(decoded);
  }

  static Future<List<Map<String, dynamic>>> programHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_programHistoryKey));
  }

  static Future<void> startWorkoutProgram({
    required String programId,
    required String name,
    required String level,
    required int durationWeeks,
    required int trainingDays,
    required List<Map<String, dynamic>> weeklyPlan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await activeProgram();
    if (existing != null) {
      final archive = await programHistory();
      archive.insert(0, <String, dynamic>{
        ...existing,
        'status': 'switched',
        'endedAt': DateTime.now().toIso8601String(),
      });
      await prefs.setString(
        _programHistoryKey,
        jsonEncode(archive.take(20).toList()),
      );
    }

    final normalized = weekDays.map((day) {
      Map<String, dynamic>? match;
      for (final item in weeklyPlan) {
        if (item['day'] == day) {
          match = item;
          break;
        }
      }
      if (match == null) {
        return <String, dynamic>{
          'day': day,
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
          'programId': programId,
          'programName': name,
          'programDayKey': '${programId}_${day.toLowerCase()}',
        };
      }
      return Map<String, dynamic>.from(match);
    }).toList();

    await prefs.setString(_weeklyPlanKey, jsonEncode(normalized));
    await prefs.setString(
      _activeProgramKey,
      jsonEncode(<String, dynamic>{
        'programId': programId,
        'name': name,
        'level': level,
        'durationWeeks': durationWeeks,
        'trainingDays': trainingDays,
        'startedAt': DateTime.now().toIso8601String(),
        'status': 'active',
      }),
    );
    _notify();
  }

  static Future<void> endActiveProgram({String status = 'ended'}) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await activeProgram();
    if (existing == null) {
      return;
    }
    final archive = await programHistory();
    archive.insert(0, <String, dynamic>{
      ...existing,
      'status': status,
      'endedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(
      _programHistoryKey,
      jsonEncode(archive.take(20).toList()),
    );
    await prefs.remove(_activeProgramKey);
    _notify();
  }

  static Future<List<Map<String, dynamic>>> customWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_customWorkoutsKey));
  }

  static Future<void> saveCustomWorkout({
    String? id,
    required String name,
    required List<String> exerciseIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await customWorkouts();
    final workoutId = id ?? 'custom_${DateTime.now().microsecondsSinceEpoch}';
    final map = <String, dynamic>{
      'id': workoutId,
      'name': name.trim().isEmpty ? 'My Workout' : name.trim(),
      'exerciseIds': exerciseIds,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    final index = items.indexWhere((item) => item['id'] == workoutId);
    if (index >= 0) {
      items[index] = map;
    } else {
      items.insert(0, map);
    }
    await prefs.setString(_customWorkoutsKey, jsonEncode(items));
    _notify();
  }

  static Future<void> deleteCustomWorkout(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await customWorkouts();
    items.removeWhere((item) => item['id'] == id);
    await prefs.setString(_customWorkoutsKey, jsonEncode(items));
    _notify();
  }

  static Future<List<Map<String, dynamic>>> weightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_weightEntriesKey));
  }

  static Future<void> addWeight(double value) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await weightEntries();
    items.insert(0, <String, dynamic>{
      'value': value,
      'date': DateTime.now().toIso8601String(),
    });
    await prefs.setString(
        _weightEntriesKey, jsonEncode(items.take(120).toList()));
    _notify();
  }

  static Future<void> deleteWeightAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await weightEntries();
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
    }
    await prefs.setString(_weightEntriesKey, jsonEncode(items));
    _notify();
  }

  static Future<List<Map<String, dynamic>>> measurementEntries() async {
    final prefs = await SharedPreferences.getInstance();
    return _decodeList(prefs.getString(_measurementEntriesKey));
  }

  static Future<void> addMeasurements(Map<String, double> values) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await measurementEntries();
    items.insert(0, <String, dynamic>{
      'date': DateTime.now().toIso8601String(),
      ...values,
    });
    await prefs.setString(
      _measurementEntriesKey,
      jsonEncode(items.take(60).toList()),
    );
    _notify();
  }

  static Future<void> deleteMeasurementAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await measurementEntries();
    if (index < 0 || index >= items.length) {
      return;
    }
    items.removeAt(index);
    await prefs.setString(_measurementEntriesKey, jsonEncode(items));
    _notify();
  }

  static Future<Map<String, dynamic>?> activeWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeWorkoutKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(decoded);
  }

  static Future<void> saveActiveWorkout(Map<String, dynamic> draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeWorkoutKey, jsonEncode(draft));
    _notify();
  }

  static Future<void> clearActiveWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeWorkoutKey);
    _notify();
  }

  static Future<void> replaceHistorySession(
    String sessionId,
    Map<String, dynamic> session,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await history();
    final index =
        items.indexWhere((item) => item['id']?.toString() == sessionId);
    if (index < 0) {
      return;
    }
    items[index] = session;
    await prefs.setString(_historyKey, jsonEncode(items));
    _notify();
  }

  static Future<Map<String, dynamic>?> historySessionById(
      String sessionId) async {
    final items = await history();
    for (final item in items) {
      if (item['id']?.toString() == sessionId) {
        return Map<String, dynamic>.from(item);
      }
    }
    return null;
  }

  static Future<void> normalizeWorkoutHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final items = await history();
    final records = <String, Map<String, dynamic>>{};

    for (final session in items.reversed) {
      final sets = _mapList(session['sets']);
      var prCount = 0;
      var totalVolume = 0.0;
      final counts = <String, int>{};

      for (final set in sets) {
        final exerciseId = set['exerciseId']?.toString() ?? '';
        if (exerciseId.isEmpty) {
          continue;
        }
        counts[exerciseId] = (counts[exerciseId] ?? 0) + 1;
        set['setNumber'] = counts[exerciseId];
        final weight = (set['weight'] as num?)?.toDouble() ?? 0;
        final reps = (set['reps'] as num?)?.toInt() ?? 0;
        final volume = weight * reps;
        final current = records[exerciseId];
        final bestWeight = (current?['bestWeight'] as num?)?.toDouble() ?? -1;
        final repsAtBest =
            (current?['repsAtBestWeight'] as num?)?.toInt() ?? -1;
        final isPr = current == null ||
            weight > bestWeight ||
            (weight == bestWeight && reps > repsAtBest);

        set['volume'] = volume;
        set['estimated1RM'] = estimatedOneRepMax(weight, reps);
        set['isPR'] = isPr;
        totalVolume += volume;
        if (isPr) {
          prCount++;
        }

        if (current == null) {
          records[exerciseId] = <String, dynamic>{
            'bestWeight': weight,
            'repsAtBestWeight': reps,
          };
        } else if (weight > bestWeight ||
            (weight == bestWeight && reps > repsAtBest)) {
          current['bestWeight'] = weight;
          current['repsAtBestWeight'] = reps;
        }
      }

      session['sets'] = sets;
      session['completedSets'] = sets.length;
      session['totalVolume'] = totalVolume;
      session['prCount'] = prCount;
    }

    await prefs.setString(_historyKey, jsonEncode(items));
    _notify();
  }

  static Future<List<Map<String, dynamic>>> exerciseSetHistory(
    String exerciseId,
  ) async {
    final items = await history();
    final result = <Map<String, dynamic>>[];
    for (final session in items.reversed) {
      final sessionDate = session['date']?.toString();
      for (final set in _mapList(session['sets'])) {
        if (set['exerciseId']?.toString() != exerciseId) {
          continue;
        }
        final copy = Map<String, dynamic>.from(set);
        copy['sessionDate'] = sessionDate;
        copy['sessionTitle'] = session['title']?.toString() ?? 'Workout';
        result.add(copy);
      }
    }
    return result;
  }

  static double estimatedOneRepMax(double weight, int reps) {
    if (weight <= 0 || reps <= 0) {
      return 0;
    }
    if (reps == 1) {
      return weight;
    }
    return weight * (1 + (reps / 30.0));
  }

  static Future<Map<String, dynamic>> exportData() async {
    return <String, dynamic>{
      'app': 'FitWithSaju',
      'formatVersion': 4,
      'exportedAt': DateTime.now().toIso8601String(),
      'onboardingComplete': await onboardingComplete(),
      'profile': await profile(),
      'weeklyPlan': await weeklyPlan(),
      'customWorkouts': await customWorkouts(),
      'favorites': (await favorites()).toList(),
      'workoutHistory': await history(),
      'weightEntries': await weightEntries(),
      'measurements': await measurementEntries(),
      'activeWorkout': await activeWorkout(),
      'activeProgram': await activeProgram(),
      'programHistory': await programHistory(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    if (data['app']?.toString() != 'FitWithSaju') {
      throw const FormatException('This backup is not a FitWithSaju export.');
    }

    final prefs = await SharedPreferences.getInstance();
    final profileValue = data['profile'];
    if (profileValue is Map) {
      final profileMap = Map<String, dynamic>.from(profileValue);
      await prefs.setString(
        _goalKey,
        profileMap['goal']?.toString() ?? 'Build Muscle',
      );
      await prefs.setString(
        _levelKey,
        profileMap['level']?.toString() ?? 'Beginner',
      );
      await prefs.setString(
        _placeKey,
        profileMap['place']?.toString() ?? 'Gym',
      );
    }
    if (data['onboardingComplete'] is bool) {
      await prefs.setBool(
        _onboardingKey,
        data['onboardingComplete'] as bool,
      );
    } else if (profileValue is Map) {
      await prefs.setBool(_onboardingKey, true);
    }

    final weekly = _mapList(data['weeklyPlan']);
    final custom = _mapList(data['customWorkouts']);
    final historyItems = _mapList(data['workoutHistory']);
    final weights = _mapList(data['weightEntries']);
    final measurements = _mapList(data['measurements']);
    final activeWorkoutValue = data['activeWorkout'];
    final activeProgramValue = data['activeProgram'];
    final programHistoryItems = _mapList(data['programHistory']);
    final favoritesValue = data['favorites'];
    final favoriteIds = favoritesValue is List
        ? favoritesValue.map((item) => item.toString()).toList()
        : <String>[];

    if (weekly.isNotEmpty) {
      await prefs.setString(_weeklyPlanKey, jsonEncode(weekly));
    }
    await prefs.setString(_customWorkoutsKey, jsonEncode(custom));
    await prefs.setString(
        _historyKey, jsonEncode(historyItems.take(100).toList()));
    await prefs.setString(
        _weightEntriesKey, jsonEncode(weights.take(120).toList()));
    await prefs.setString(
        _measurementEntriesKey, jsonEncode(measurements.take(60).toList()));
    await prefs.setStringList(_favoritesKey, favoriteIds);
    if (activeWorkoutValue is Map) {
      await prefs.setString(
        _activeWorkoutKey,
        jsonEncode(Map<String, dynamic>.from(activeWorkoutValue)),
      );
    } else {
      await prefs.remove(_activeWorkoutKey);
    }
    if (activeProgramValue is Map) {
      await prefs.setString(
        _activeProgramKey,
        jsonEncode(Map<String, dynamic>.from(activeProgramValue)),
      );
    } else {
      await prefs.remove(_activeProgramKey);
    }
    await prefs.setString(
      _programHistoryKey,
      jsonEncode(programHistoryItems.take(20).toList()),
    );
    _notify();
  }

  static Future<Map<String, dynamic>?> latestSetForExercise(
    String exerciseId, {
    int? setNumber,
  }) async {
    final items = await history();
    Map<String, dynamic>? fallback;
    for (final session in items) {
      final sets = _mapList(session['sets']);
      for (final set in sets.reversed) {
        if (set['exerciseId']?.toString() != exerciseId) {
          continue;
        }
        fallback ??= set;
        if (setNumber == null ||
            (set['setNumber'] as num?)?.toInt() == setNumber) {
          return Map<String, dynamic>.from(set);
        }
      }
    }
    return fallback == null ? null : Map<String, dynamic>.from(fallback);
  }

  static Future<Map<String, Map<String, dynamic>>> exerciseRecords() async {
    final items = await history();
    final records = <String, Map<String, dynamic>>{};

    for (final session in items.reversed) {
      final sessionDate = session['date']?.toString();
      for (final set in _mapList(session['sets'])) {
        final exerciseId = set['exerciseId']?.toString() ?? '';
        if (exerciseId.isEmpty) {
          continue;
        }

        final weight = (set['weight'] as num?)?.toDouble() ?? 0;
        final reps = (set['reps'] as num?)?.toInt() ?? 0;
        final volume = (set['volume'] as num?)?.toDouble() ?? weight * reps;
        final current = records[exerciseId];

        if (current == null) {
          records[exerciseId] = <String, dynamic>{
            'exerciseId': exerciseId,
            'exerciseName': set['exerciseName']?.toString() ?? exerciseId,
            'muscle': set['muscle']?.toString() ?? '',
            'bestWeight': weight,
            'repsAtBestWeight': reps,
            'bestSetVolume': volume,
            'bestReps': reps,
            'achievedAt': set['completedAt']?.toString() ?? sessionDate,
          };
          continue;
        }

        final bestWeight = (current['bestWeight'] as num?)?.toDouble() ?? 0;
        final repsAtBest = (current['repsAtBestWeight'] as num?)?.toInt() ?? 0;
        final bestVolume = (current['bestSetVolume'] as num?)?.toDouble() ?? 0;
        final bestReps = (current['bestReps'] as num?)?.toInt() ?? 0;

        if (weight > bestWeight ||
            (weight == bestWeight && reps > repsAtBest)) {
          current['bestWeight'] = weight;
          current['repsAtBestWeight'] = reps;
          current['achievedAt'] = set['completedAt']?.toString() ?? sessionDate;
        }
        if (volume > bestVolume) {
          current['bestSetVolume'] = volume;
        }
        if (reps > bestReps) {
          current['bestReps'] = reps;
        }
      }
    }

    return records;
  }

  static Future<double> totalTrainingVolume() async {
    final items = await history();
    return items.fold<double>(0, (sum, session) {
      final stored = (session['totalVolume'] as num?)?.toDouble();
      if (stored != null) {
        return sum + stored;
      }
      final calculated = _mapList(session['sets']).fold<double>(
        0,
        (setSum, set) => setSum + ((set['volume'] as num?)?.toDouble() ?? 0),
      );
      return sum + calculated;
    });
  }

  static List<Map<String, dynamic>> sessionSets(Map<String, dynamic> session) {
    return _mapList(session['sets']);
  }

  static List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static List<Map<String, dynamic>> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <Map<String, dynamic>>[];
    }
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static List<Map<String, dynamic>> _defaultWeeklyPlan() => [
        {
          'day': 'Monday',
          'title': 'Push Day',
          'isRest': false,
          'durationMinutes': 45,
          'exerciseIds': ['3TZduzM', '3eGE2JC', '5uFK1xr'],
        },
        {
          'day': 'Tuesday',
          'title': 'Pull Day',
          'isRest': false,
          'durationMinutes': 40,
          'exerciseIds': ['7F1DVzn', '7I6LNUG', '4dF3maG'],
        },
        {
          'day': 'Wednesday',
          'title': 'Leg Day',
          'isRest': false,
          'durationMinutes': 35,
          'exerciseIds': ['2Qh2J1e', '5bpPTHv', '2ORFMoR'],
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
          'title': 'Upper Body',
          'isRest': false,
          'durationMinutes': 50,
          'exerciseIds': [
            '5v7KYld',
            '7F1DVzn',
            '6cKQC5E',
            '8oYqOt9',
          ],
        },
        {
          'day': 'Saturday',
          'title': 'Full Body',
          'isRest': false,
          'durationMinutes': 45,
          'exerciseIds': ['2Qh2J1e', '7I6LNUG', '8eqjhOl', '8xUv4J7'],
        },
        {
          'day': 'Sunday',
          'title': 'Rest',
          'isRest': true,
          'durationMinutes': 0,
          'exerciseIds': <String>[],
        },
      ];
}
