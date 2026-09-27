import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});

  Future<String> _buildExport() async {
    final data = <String, dynamic>{
      'app': 'FitWithSaju',
      'exportedAt': DateTime.now().toIso8601String(),
      'weeklyPlan': await LocalStore.weeklyPlan(),
      'customWorkouts': await LocalStore.customWorkouts(),
      'favorites': (await LocalStore.favorites()).toList(),
      'workoutHistory': await LocalStore.history(),
      'weightEntries': await LocalStore.weightEntries(),
      'measurements': await LocalStore.measurementEntries(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export My Data')),
      body: FutureBuilder<String>(
        future: _buildExport(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final json = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your local FitWithSaju data',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Copy this JSON backup and keep it somewhere safe. Import support will be added in a later sprint.',
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
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
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: json));
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup copied to clipboard.')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text(
                      'Copy Backup',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
