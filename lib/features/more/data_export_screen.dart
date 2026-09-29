import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/motion/app_motion.dart';
import '../../core/settings/app_preferences.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../nutrition/data/nutrition_store.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  late Future<String> _exportFuture;

  @override
  void initState() {
    super.initState();
    _exportFuture = _buildExport();
  }

  Future<String> _buildExport() async {
    final data = await LocalStore.exportData();
    data['nutrition'] = await NutritionStore.exportData();
    data['settings'] = AppPreferences.exportData();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void _refresh() {
    setState(() => _exportFuture = _buildExport());
  }

  Future<void> _openImport() async {
    final restored = await Navigator.of(context).push<bool>(
      FitRoutes.route(
        context,
        motion: FitRouteMotion.detail,
        builder: (_) => const DataImportScreen(),
      ),
    );
    if (restored == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: FutureBuilder<String>(
        future: _exportFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final json = snapshot.data!;
          final screenHeight = MediaQuery.sizeOf(context).height;
          final jsonHeight =
              (screenHeight * .42).clamp(260.0, 480.0).toDouble();

          return FitScrollableScreen(
            listKey: const Key('backup-restore-scroll'),
            bottomSpacing: 24,
            children: [
              const Text(
                'Your local FitWithSaju data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Copy this JSON backup somewhere safe. You can restore it on this device or another FitWithSaju installation.',
                style: TextStyle(color: AppColors.muted, height: 1.45),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: jsonHeight,
                child: Container(
                  key: const Key('backup-json-card'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      primary: false,
                      padding: const EdgeInsets.only(right: 4),
                      child: SelectableText(
                        json,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stackButtons = constraints.maxWidth < 350;
                  final importButton = SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      key: const Key('import-backup-button'),
                      onPressed: _openImport,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text(
                        'Import Backup',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  );
                  final copyButton = SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      key: const Key('copy-backup-button'),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: json));
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Backup copied to clipboard.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text(
                        'Copy Backup',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  );

                  if (stackButtons) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        importButton,
                        const SizedBox(height: 12),
                        copyButton,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: importButton),
                      const SizedBox(width: 12),
                      Expanded(child: copyButton),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class DataImportScreen extends StatefulWidget {
  const DataImportScreen({super.key});

  @override
  State<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends State<DataImportScreen> {
  final _controller = TextEditingController();
  bool _importing = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    final clipboardText = data?.text;
    if (!mounted || clipboardText == null) {
      return;
    }
    setState(() {
      _controller.text = clipboardText;
      _error = null;
    });
  }

  Future<void> _import() async {
    if (_importing) {
      return;
    }
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'Paste a FitWithSaju JSON backup first.');
      return;
    }

    Map<String, dynamic> decoded;
    try {
      final value = jsonDecode(raw);
      if (value is! Map) {
        throw const FormatException('Backup root must be an object.');
      }
      decoded = Map<String, dynamic>.from(value);
      if (decoded['app']?.toString() != 'FitWithSaju') {
        throw const FormatException('This is not a FitWithSaju backup.');
      }
    } catch (error) {
      setState(() => _error = 'Invalid backup: $error');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore this backup?'),
        content: const Text(
          'Saved workout data, body metrics, and Diet & Meal Plan data on this device will be replaced by the backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _importing = true;
      _error = null;
    });

    try {
      await LocalStore.importData(decoded);
      await NutritionStore.importData(decoded['nutrition']);
      await AppPreferences.importData(decoded['settings']);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FitWithSaju backup restored.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _importing = false;
        _error = 'Could not restore backup: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Backup')),
      body: FitSafeBody(
        bottomSpacing: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your JSON backup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'The backup is validated before anything is restored.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TextField(
                controller: _controller,
                expands: true,
                minLines: null,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: const InputDecoration(
                  hintText: '{\n  "app": "FitWithSaju",\n  ...\n}',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ],
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final stackButtons = constraints.maxWidth < 350;
                final pasteButton = SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: _importing ? null : _paste,
                    icon: const Icon(Icons.content_paste_rounded),
                    label: const Text('Paste'),
                  ),
                );
                final restoreButton = SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _importing ? null : _import,
                    icon: _importing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.restore_rounded),
                    label: const Text(
                      'Restore',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                );
                if (stackButtons) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      pasteButton,
                      const SizedBox(height: 12),
                      restoreButton,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: pasteButton),
                    const SizedBox(width: 12),
                    Expanded(child: restoreButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
