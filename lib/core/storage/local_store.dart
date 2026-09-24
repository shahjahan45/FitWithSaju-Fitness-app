import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  static const _onboardingKey = 'onboarding_complete';
  static const _goalKey = 'fitness_goal';
  static const _levelKey = 'fitness_level';
  static const _placeKey = 'training_place';
  static const _favoritesKey = 'favorite_exercises';
  static const _historyKey = 'workout_history';

  static Future<bool> onboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> saveProfile({required String goal, required String level, required String place}) async {
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
    if (added) { items.add(id); } else { items.remove(id); }
    await prefs.setStringList(_favoritesKey, items.toList());
    return added;
  }

  static Future<List<Map<String, dynamic>>> history() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];
    final data = jsonDecode(raw) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<void> addWorkoutHistory(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await history();
    current.insert(0, item);
    await prefs.setString(_historyKey, jsonEncode(current.take(100).toList()));
  }
}
