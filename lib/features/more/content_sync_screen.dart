import 'package:flutter/material.dart';

import '../../core/motion/motion_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../data/exercise_catalog.dart';
import '../nutrition/data/nutrition_catalog.dart';

class ContentSyncScreen extends StatefulWidget {
  const ContentSyncScreen({super.key});

  @override
  State<ContentSyncScreen> createState() => _ContentSyncScreenState();
}

class _ContentSyncScreenState extends State<ContentSyncScreen> {
  final _urlController = TextEditingController();
  bool _loading = true;
  bool _syncing = false;
  String? _message;
  bool _success = false;

  ExerciseCatalog get _exerciseCatalog => ExerciseCatalog.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _urlController.text = await _exerciseCatalog.apiBaseUrl();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _sync() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _syncing = true;
      _message = null;
    });

    final exerciseResult = await _exerciseCatalog.sync(
      baseUrl: _urlController.text,
    );
    final nutritionResult = await NutritionCatalog.sync(
      baseUrl: _urlController.text,
    );
    if (!mounted) {
      return;
    }

    final bothSucceeded = exerciseResult.success && nutritionResult.success;
    final oneSucceeded = exerciseResult.success || nutritionResult.success;
    setState(() {
      _syncing = false;
      _success = oneSucceeded;
      _message = bothSucceeded
          ? '${exerciseResult.message}\n${nutritionResult.message}'
          : 'Exercises: ${exerciseResult.message}\nRecipes: ${nutritionResult.message}';
    });
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Use offline content?'),
        content: const Text(
          'This removes downloaded exercise and recipe caches and switches back to the content bundled with FitWithSaju. Your workout history, nutrition logs, hydration, measurements, and plans are not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Use Offline'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await Future.wait([
      _exerciseCatalog.resetToBundled(),
      NutritionCatalog.resetToBundled(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _message = 'Using the bundled offline exercise and meal catalogs.';
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Content Sync')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<ExerciseCatalogSource>(
              valueListenable: _exerciseCatalog.source,
              builder: (context, exerciseSource, _) {
                return ValueListenableBuilder<NutritionCatalogSource>(
                  valueListenable: NutritionCatalog.source,
                  builder: (context, nutritionSource, _) {
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        MotionReveal(
                          child: _StatusCard(
                            title: 'Exercise catalog',
                            sourceLabel: _exerciseSourceLabel(exerciseSource),
                            countLabel:
                                '${_exerciseCatalog.exercises.length} exercises',
                            syncedAt: _exerciseCatalog.lastSyncedAt,
                            icon: Icons.fitness_center_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MotionReveal(
                          delay: const Duration(milliseconds: 35),
                          child: _StatusCard(
                            title: 'Meal catalog',
                            sourceLabel: _nutritionSourceLabel(nutritionSource),
                            countLabel:
                                '${NutritionCatalog.recipes.length} published recipes',
                            syncedAt: NutritionCatalog.lastSyncedAt,
                            icon: Icons.restaurant_menu_rounded,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const MotionReveal(
                          delay: Duration(milliseconds: 60),
                          child: Text(
                            'FITWITHSAJU API',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        MotionReveal(
                          delay: const Duration(milliseconds: 85),
                          child: TextField(
                            controller: _urlController,
                            keyboardType: TextInputType.url,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              labelText: 'API base URL',
                              hintText: 'http://192.168.1.10:8000',
                              prefixIcon: Icon(Icons.cloud_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'For a physical phone on local Wi-Fi, use your computer IPv4 address instead of localhost. FitWithSaju calls /api/exercises and /api/recipes and keeps successful downloads cached for offline use.',
                          style: TextStyle(
                            color: AppColors.muted,
                            height: 1.45,
                            fontSize: 12,
                          ),
                        ),
                        if (_message != null) ...[
                          const SizedBox(height: 16),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _success
                                  ? AppColors.primarySoft
                                  : const Color(0xFFFFECEC),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _success
                                      ? Icons.check_circle_rounded
                                      : Icons.error_outline_rounded,
                                  color: _success
                                      ? AppColors.primary
                                      : AppColors.danger,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _message!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 58,
                          child: FilledButton.icon(
                            onPressed: _syncing ? null : _sync,
                            icon: _syncing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.sync_rounded),
                            label: Text(
                              _syncing ? 'Syncing…' : 'Test & Sync Content',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _syncing ? null : _reset,
                          icon: const Icon(Icons.phone_android_rounded),
                          label: const Text('Use Bundled Offline Content'),
                        ),
                        const SizedBox(height: 24),
                        const _SafetyNote(),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  static String _exerciseSourceLabel(ExerciseCatalogSource source) =>
      switch (source) {
        ExerciseCatalogSource.live => 'Live API',
        ExerciseCatalogSource.cached => 'Cached API',
        ExerciseCatalogSource.bundled => 'Bundled offline',
      };

  static String _nutritionSourceLabel(NutritionCatalogSource source) =>
      switch (source) {
        NutritionCatalogSource.live => 'Live API',
        NutritionCatalogSource.cached => 'Cached API',
        NutritionCatalogSource.bundled => 'Bundled offline',
      };
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String sourceLabel;
  final String countLabel;
  final DateTime? syncedAt;
  final IconData icon;

  const _StatusCard({
    required this.title,
    required this.sourceLabel,
    required this.countLabel,
    required this.syncedAt,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F8DC), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$sourceLabel • $countLabel',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                if (syncedAt != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Last synced ${_date(syncedAt!)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _date(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Content sync downloads public exercise and recipe content only. Workout history, meal logs, hydration, nutrition preferences, measurements, plans, and other personal data remain local on this device.',
              style: TextStyle(
                color: AppColors.muted,
                height: 1.45,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
