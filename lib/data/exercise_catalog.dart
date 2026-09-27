import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_repository.dart';
import 'models/exercise.dart';

enum ExerciseCatalogSource { bundled, cached, live }

class ExerciseCatalogSyncResult {
  final bool success;
  final int count;
  final String message;

  const ExerciseCatalogSyncResult({
    required this.success,
    required this.count,
    required this.message,
  });
}

class ExerciseCatalog {
  ExerciseCatalog._();

  static final ExerciseCatalog instance = ExerciseCatalog._();

  static const _cacheKey = 'exercise_catalog_cache_v1';
  static const _apiBaseUrlKey = 'exercise_api_base_url_v1';
  static const _syncedAtKey = 'exercise_catalog_synced_at_v1';

  final ValueNotifier<List<Exercise>> listenable =
      ValueNotifier<List<Exercise>>(DemoRepository.exercises);
  final ValueNotifier<ExerciseCatalogSource> source =
      ValueNotifier<ExerciseCatalogSource>(ExerciseCatalogSource.bundled);

  String? lastError;
  DateTime? lastSyncedAt;

  List<Exercise> get exercises => listenable.value;

  List<String> get availableBodyParts => _uniqueSorted(
        exercises.expand((exercise) => exercise.bodyParts),
      );

  List<String> get availableEquipments => _uniqueSorted(
        exercises.expand((exercise) => exercise.equipments),
      );

  Exercise? findById(String id) {
    for (final exercise in exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }
    return DemoRepository.findExerciseById(id);
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    final syncedAt = prefs.getString(_syncedAtKey);
    if (syncedAt != null) {
      lastSyncedAt = DateTime.tryParse(syncedAt);
    }
    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }
      final remote = decoded
          .whereType<Map>()
          .map((item) => Exercise.fromApi(Map<String, dynamic>.from(item)))
          .where((exercise) => exercise.id.isNotEmpty)
          .toList(growable: false);
      if (remote.isNotEmpty) {
        listenable.value = _mergeRemoteWithBundled(remote);
        source.value = ExerciseCatalogSource.cached;
      }
    } catch (_) {
      // Corrupt cache must never stop the app from using bundled exercises.
    }
  }

  Future<String> apiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiBaseUrlKey) ?? '';
  }

  Future<void> saveApiBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeBaseUrl(value);
    if (normalized.isEmpty) {
      await prefs.remove(_apiBaseUrlKey);
    } else {
      await prefs.setString(_apiBaseUrlKey, normalized);
    }
  }

  Future<ExerciseCatalogSyncResult> sync({String? baseUrl}) async {
    final configured = baseUrl ?? await apiBaseUrl();
    final normalized = _normalizeBaseUrl(configured);
    if (normalized.isEmpty) {
      return const ExerciseCatalogSyncResult(
        success: false,
        count: 0,
        message: 'Enter your FitWithSaju API URL first.',
      );
    }

    await saveApiBaseUrl(normalized);
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final uri = Uri.parse('$normalized/api/exercises?per_page=200');
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response =
          await request.close().timeout(const Duration(seconds: 12));
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError = 'Server returned HTTP ${response.statusCode}.';
        return ExerciseCatalogSyncResult(
          success: false,
          count: exercises.length,
          message: lastError!,
        );
      }

      final decoded = jsonDecode(body);
      final list = decoded is Map ? decoded['data'] : decoded;
      if (list is! List) {
        throw const FormatException('Exercise API did not return a data list.');
      }
      final remote = list
          .whereType<Map>()
          .map((item) => Exercise.fromApi(Map<String, dynamic>.from(item)))
          .where((exercise) => exercise.id.isNotEmpty)
          .toList(growable: false);
      if (remote.isEmpty) {
        throw const FormatException(
            'Exercise API returned no active exercises.');
      }

      final merged = _mergeRemoteWithBundled(remote);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(remote.map((exercise) => exercise.toCacheJson()).toList()),
      );
      final now = DateTime.now();
      await prefs.setString(_syncedAtKey, now.toIso8601String());
      lastSyncedAt = now;
      lastError = null;
      listenable.value = merged;
      source.value = ExerciseCatalogSource.live;

      return ExerciseCatalogSyncResult(
        success: true,
        count: remote.length,
        message: 'Synced ${remote.length} exercises from the server.',
      );
    } on TimeoutException {
      lastError = 'The server took too long to respond.';
    } on SocketException {
      lastError = 'Could not connect to the server.';
    } on FormatException catch (error) {
      lastError = error.message;
    } catch (_) {
      lastError =
          'Exercise sync failed. Your offline catalog is still available.';
    } finally {
      client.close(force: true);
    }

    return ExerciseCatalogSyncResult(
      success: false,
      count: exercises.length,
      message: lastError ?? 'Exercise sync failed.',
    );
  }

  Future<void> resetToBundled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_syncedAtKey);
    lastSyncedAt = null;
    lastError = null;
    listenable.value = DemoRepository.exercises;
    source.value = ExerciseCatalogSource.bundled;
  }

  List<Exercise> _mergeRemoteWithBundled(List<Exercise> remote) {
    final bundledById = <String, Exercise>{
      for (final exercise in DemoRepository.exercises) exercise.id: exercise,
    };
    return remote.map((exercise) {
      final bundled = bundledById[exercise.id];
      if (bundled == null) {
        return exercise;
      }
      return Exercise(
        id: exercise.id,
        name: exercise.name,
        targetMuscles: exercise.targetMuscles,
        bodyParts: exercise.bodyParts,
        equipments: exercise.equipments,
        secondaryMuscles: exercise.secondaryMuscles,
        instructionSteps: exercise.instructionSteps,
        thumbnailAsset: bundled.thumbnailAsset,
        mediaAsset: bundled.mediaAsset,
        thumbnailUrl: exercise.thumbnailUrl,
        mediaUrl: exercise.mediaUrl,
        sets: exercise.sets,
        reps: exercise.reps,
        restSeconds: exercise.restSeconds,
      );
    }).toList(growable: false);
  }

  static List<String> _uniqueSorted(Iterable<String> values) {
    final result = values
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return result;
  }

  static String _normalizeBaseUrl(String input) {
    var value = input.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }
}
