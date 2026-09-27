import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  List<Map<String, dynamic>> _entries = [];

  final fields = const ['Chest', 'Waist', 'Arms', 'Thigh'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await LocalStore.measurementEntries();
    if (mounted) {
      setState(() => _entries = data);
    }
  }

  Future<void> _add() async {
    final controllers = {
      for (final field in fields) field: TextEditingController(),
    };
    final values = await showModalBottomSheet<Map<String, double>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add measurements',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              ...fields.map(
                (field) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: controllers[field],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: field, suffixText: 'CM'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    final result = <String, double>{};
                    for (final field in fields) {
                      final parsed = double.tryParse(controllers[field]!.text.trim());
                      if (parsed != null && parsed > 0) {
                        result[field.toLowerCase()] = parsed;
                      }
                    }
                    if (result.isNotEmpty) {
                      Navigator.of(sheetContext).pop(result);
                    }
                  },
                  child: const Text('Save Measurements'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    for (final controller in controllers.values) {
      controller.dispose();
    }
    if (values == null) {
      return;
    }
    await LocalStore.addMeasurements(values);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Measurements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: _entries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Track chest, waist, arms, and thigh measurements locally on your device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.5),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final item = _entries[index];
                final date = DateTime.tryParse(item['date']?.toString() ?? '');
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date == null
                            ? 'Saved measurements'
                            : '${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: fields.map((field) {
                          final value = item[field.toLowerCase()];
                          if (value == null) {
                            return const SizedBox.shrink();
                          }
                          return Chip(label: Text('$field: $value cm'));
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
