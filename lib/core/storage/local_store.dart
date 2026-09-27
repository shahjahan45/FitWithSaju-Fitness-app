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
  }

  static Future<void> skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
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

  static Future<void> copyDayPlan(String fromDay, String toDay) async {
    final plan = await weeklyPlan();
    final source = plan.firstWhere((item) => item['day'] == fromDay);
    final copy = Map<String, dynamic>.from(source)..['day'] = toDay;
    await saveDayPlan(copy);
  }

  static Future<void> setRestDay(String day) async {
    await saveDayPlan(<String, dynamic>{
      'day': day,
      'title': 'Rest',
      'isRest': true,
      'durationMinutes': 0,
      'exerciseIds': <String>[],
    });
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
    await prefs.setString(_weightEntriesKey, jsonEncode(items.take(120).toList()));
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
        if (setNumber == null || (set['setNumber'] as num?)?.toInt() == setNumber) {
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

        if (weight > bestWeight || (weight == bestWeight && reps > repsAtBest)) {
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
        (setSum, set) =>
            setSum + ((set['volume'] as num?)?.toDouble() ?? 0),
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
          'exerciseIds': ['bench_press', 'incline_db_press', 'shoulder_press'],
        },
        {
          'day': 'Tuesday',
          'title': 'Pull Day',
          'isRest': false,
          'durationMinutes': 40,
          'exerciseIds': ['lat_pulldown', 'biceps_curl'],
        },
        {
          'day': 'Wednesday',
          'title': 'Leg Day',
          'isRest': false,
          'durationMinutes': 35,
          'exerciseIds': ['squat'],
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
            'bench_press',
            'lat_pulldown',
            'shoulder_press',
            'biceps_curl',
          ],
        },
        {
          'day': 'Saturday',
          'title': 'Full Body',
          'isRest': false,
          'durationMinutes': 45,
          'exerciseIds': ['squat', 'bench_press', 'lat_pulldown'],
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
