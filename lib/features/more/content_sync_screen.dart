import 'package:flutter/material.dart';

import '../../core/motion/motion_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../data/exercise_catalog.dart';

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

  ExerciseCatalog get _catalog => ExerciseCatalog.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _urlController.text = await _catalog.apiBaseUrl();
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
    final result = await _catalog.sync(baseUrl: _urlController.text);
    if (!mounted) {
      return;
    }
    setState(() {
      _syncing = false;
      _message = result.message;
      _success = result.success;
    });
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Use offline catalog?'),
        content: const Text(
          'This removes the downloaded exercise cache and immediately switches back to the bundled FitWithSaju exercise library. Your workout history is not affected.',
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
    await _catalog.resetToBundled();
    if (!mounted) {
      return;
    }
    setState(() {
      _message = 'Using the bundled offline exercise catalog.';
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
              valueListenable: _catalog.source,
              builder: (context, source, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    MotionReveal(
                      child: _StatusCard(
                        source: source,
                        count: _catalog.exercises.length,
                        syncedAt: _catalog.lastSyncedAt,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const MotionReveal(
                      delay: Duration(milliseconds: 55),
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
                      'For a physical phone on local Wi-Fi, use your computer IPv4 address instead of localhost. The app calls /api/exercises and keeps a local cache after a successful sync.',
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
                          _syncing ? 'Syncing…' : 'Test & Sync Exercises',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _syncing ? null : _reset,
                      icon: const Icon(Icons.phone_android_rounded),
                      label: const Text('Use Bundled Offline Catalog'),
                    ),
                    const SizedBox(height: 24),
                    const _SafetyNote(),
                  ],
                );
              },
            ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final ExerciseCatalogSource source;
  final int count;
  final DateTime? syncedAt;

  const _StatusCard({
    required this.source,
    required this.count,
    required this.syncedAt,
  });

  @override
  Widget build(BuildContext context) {
    final (label, detail, icon) = switch (source) {
      ExerciseCatalogSource.live => (
          'Live API catalog',
          'Fresh server content is active.',
          Icons.cloud_done_rounded,
        ),
      ExerciseCatalogSource.cached => (
          'Cached API catalog',
          'Last downloaded content is available offline.',
          Icons.cloud_queue_rounded,
        ),
      ExerciseCatalogSource.bundled => (
          'Bundled offline catalog',
          'The exercise library included with the app is active.',
          Icons.offline_bolt_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F8DC), Colors.white],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count exercises • $detail',
                  style: const TextStyle(
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
                if (syncedAt != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Last sync: ${_date(syncedAt!)}',
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
              'Server sync only manages public exercise content. Your workout history, body measurements, personal records, plans, and unfinished workouts remain local on this device.',
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
