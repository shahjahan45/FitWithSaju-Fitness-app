import 'package:flutter/material.dart';

import '../../core/settings/app_preferences.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _savingProfile = false;
  String _goal = 'Build Muscle';
  String _level = 'Beginner';
  String _place = 'Gym';

  static const _goals = <String>[
    'Build Muscle',
    'Lose Weight',
    'Stay Fit',
    'Increase Strength',
    'Improve Mobility',
    'Home Training',
  ];
  static const _levels = <String>['Beginner', 'Intermediate', 'Advanced'];
  static const _places = <String>['Gym', 'Home', 'Both'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await LocalStore.profile();
    if (!mounted) {
      return;
    }
    setState(() {
      _goal = profile['goal'] ?? _goal;
      _level = profile['level'] ?? _level;
      _place = profile['place'] ?? _place;
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_savingProfile) {
      return;
    }
    setState(() => _savingProfile = true);
    try {
      await LocalStore.saveProfile(goal: _goal, level: _level, place: _place);
      AppPreferences.successFeedback();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Training preferences updated.')),
      );
    } finally {
      if (mounted) {
        setState(() => _savingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<AppPreferenceState>(
              valueListenable: AppPreferences.listenable,
              builder: (context, preferences, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    const _Header(
                      title: 'Training profile',
                      subtitle:
                          'Update the choices used to personalize your workout experience.',
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        children: [
                          _DropdownRow(
                            label: 'Goal',
                            value: _goal,
                            values: _goals,
                            onChanged: (value) => setState(() => _goal = value),
                          ),
                          const Divider(height: 1),
                          _DropdownRow(
                            label: 'Level',
                            value: _level,
                            values: _levels,
                            onChanged: (value) =>
                                setState(() => _level = value),
                          ),
                          const Divider(height: 1),
                          _DropdownRow(
                            label: 'Training place',
                            value: _place,
                            values: _places,
                            onChanged: (value) =>
                                setState(() => _place = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _savingProfile ? null : _saveProfile,
                        icon: _savingProfile
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(
                          _savingProfile ? 'Saving…' : 'Save training profile',
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _Header(
                      title: 'App experience',
                      subtitle:
                          'Control feedback, animation, and automatic content refresh.',
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            value: preferences.hapticsEnabled,
                            onChanged: AppPreferences.setHapticsEnabled,
                            secondary: const Icon(
                              Icons.vibration_rounded,
                              color: AppColors.primary,
                            ),
                            title: const Text(
                              'Haptic feedback',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: const Text(
                              'Feel light feedback for navigation and workout actions.',
                            ),
                          ),
                          const Divider(height: 1, indent: 54),
                          SwitchListTile.adaptive(
                            value: preferences.soundsEnabled,
                            onChanged: AppPreferences.setSoundsEnabled,
                            secondary: const Icon(
                              Icons.volume_up_outlined,
                              color: AppColors.primary,
                            ),
                            title: const Text(
                              'Interface sounds',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: const Text(
                              'Play a subtle system click for important actions.',
                            ),
                          ),
                          const Divider(height: 1, indent: 54),
                          SwitchListTile.adaptive(
                            value: preferences.reduceMotion,
                            onChanged: AppPreferences.setReduceMotion,
                            secondary: const Icon(
                              Icons.motion_photos_off_outlined,
                              color: AppColors.primary,
                            ),
                            title: const Text(
                              'Reduce motion',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: const Text(
                              'Use brief fades and minimize movement throughout the app.',
                            ),
                          ),
                          const Divider(height: 1, indent: 54),
                          SwitchListTile.adaptive(
                            value: preferences.autoSyncContent,
                            onChanged: AppPreferences.setAutoSyncContent,
                            secondary: const Icon(
                              Icons.sync_rounded,
                              color: AppColors.primary,
                            ),
                            title: const Text(
                              'Auto-sync content',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: const Text(
                              'Refresh exercises and recipes at launch when an API URL is configured.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _Header(
                      title: 'Storage & privacy',
                      subtitle:
                          'Personal workouts, progress, body data, and nutrition logs stay on this device unless you export a backup.',
                    ),
                    const SizedBox(height: 14),
                    const _Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          'Local-first personal data',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          'The optional Laravel server manages public exercise and recipe content; it does not receive your personal logs in this version.',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.muted, height: 1.45),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: values.contains(value) ? value : values.first,
              borderRadius: BorderRadius.circular(16),
              items: values
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (next) {
                if (next != null) {
                  onChanged(next);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
