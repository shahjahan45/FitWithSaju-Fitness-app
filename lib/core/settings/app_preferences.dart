import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AppPreferenceState {
  final bool hapticsEnabled;
  final bool soundsEnabled;
  final bool reduceMotion;
  final bool autoSyncContent;

  const AppPreferenceState({
    this.hapticsEnabled = true,
    this.soundsEnabled = false,
    this.reduceMotion = false,
    this.autoSyncContent = true,
  });

  AppPreferenceState copyWith({
    bool? hapticsEnabled,
    bool? soundsEnabled,
    bool? reduceMotion,
    bool? autoSyncContent,
  }) {
    return AppPreferenceState(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      autoSyncContent: autoSyncContent ?? this.autoSyncContent,
    );
  }
}

class AppPreferences {
  AppPreferences._();

  static const _hapticsKey = 'settings_haptics_v1';
  static const _soundsKey = 'settings_sounds_v1';
  static const _reduceMotionKey = 'settings_reduce_motion_v1';
  static const _autoSyncKey = 'settings_auto_sync_v1';

  static final ValueNotifier<AppPreferenceState> listenable =
      ValueNotifier<AppPreferenceState>(const AppPreferenceState());

  static AppPreferenceState get current => listenable.value;

  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      listenable.value = AppPreferenceState(
        hapticsEnabled: prefs.getBool(_hapticsKey) ?? true,
        soundsEnabled: prefs.getBool(_soundsKey) ?? false,
        reduceMotion: prefs.getBool(_reduceMotionKey) ?? false,
        autoSyncContent: prefs.getBool(_autoSyncKey) ?? true,
      );
    } catch (_) {
      // Defaults keep the app usable even if preferences cannot be read.
    }
  }

  static Future<void> setHapticsEnabled(bool value) async {
    await _setBool(_hapticsKey, value);
    listenable.value = current.copyWith(hapticsEnabled: value);
  }

  static Future<void> setSoundsEnabled(bool value) async {
    await _setBool(_soundsKey, value);
    listenable.value = current.copyWith(soundsEnabled: value);
  }

  static Future<void> setReduceMotion(bool value) async {
    await _setBool(_reduceMotionKey, value);
    listenable.value = current.copyWith(reduceMotion: value);
  }

  static Future<void> setAutoSyncContent(bool value) async {
    await _setBool(_autoSyncKey, value);
    listenable.value = current.copyWith(autoSyncContent: value);
  }

  static Future<void> _setBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      // Keep the in-memory setting usable for this session.
    }
  }

  static Map<String, dynamic> exportData() {
    return <String, dynamic>{
      'hapticsEnabled': current.hapticsEnabled,
      'soundsEnabled': current.soundsEnabled,
      'reduceMotion': current.reduceMotion,
      'autoSyncContent': current.autoSyncContent,
    };
  }

  static Future<void> importData(dynamic value) async {
    if (value is! Map) {
      return;
    }
    final data = Map<String, dynamic>.from(value);
    final next = AppPreferenceState(
      hapticsEnabled: data['hapticsEnabled'] as bool? ?? true,
      soundsEnabled: data['soundsEnabled'] as bool? ?? false,
      reduceMotion: data['reduceMotion'] as bool? ?? false,
      autoSyncContent: data['autoSyncContent'] as bool? ?? true,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hapticsKey, next.hapticsEnabled);
      await prefs.setBool(_soundsKey, next.soundsEnabled);
      await prefs.setBool(_reduceMotionKey, next.reduceMotion);
      await prefs.setBool(_autoSyncKey, next.autoSyncContent);
    } catch (_) {
      // The restored values still apply to the current session.
    }
    listenable.value = next;
  }

  static void selectionFeedback() {
    if (current.hapticsEnabled) {
      unawaited(_ignorePlatformFailure(HapticFeedback.selectionClick()));
    }
    if (current.soundsEnabled) {
      unawaited(
        _ignorePlatformFailure(SystemSound.play(SystemSoundType.click)),
      );
    }
  }

  static void successFeedback() {
    if (current.hapticsEnabled) {
      unawaited(_ignorePlatformFailure(HapticFeedback.mediumImpact()));
    }
    if (current.soundsEnabled) {
      unawaited(
        _ignorePlatformFailure(SystemSound.play(SystemSoundType.click)),
      );
    }
  }

  static Future<void> _ignorePlatformFailure(Future<void> action) async {
    try {
      await action;
    } catch (_) {
      // Haptics/sound are optional enhancements and must never break a flow.
    }
  }
}
