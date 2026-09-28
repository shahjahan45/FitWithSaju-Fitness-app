import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/pro_empty_state.dart';

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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        InputDecoration(labelText: field, suffixText: 'CM'),
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
                      final parsed =
                          double.tryParse(controllers[field]!.text.trim());
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

  Future<void> _delete(int index) async {
    await LocalStore.deleteMeasurementAt(index);
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
          ? ProEmptyState(
              icon: Icons.straighten_rounded,
              title: 'Create your first measurement snapshot',
              message:
                  'Track chest, waist, arms and thigh measurements over time. Entries stay local on this device.',
              primaryLabel: 'Add measurements',
              onPrimary: _add,
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _MeasurementSummary(entries: _entries),
                  );
                }
                final entryIndex = index - 1;
                final item = _entries[entryIndex];
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              date == null
                                  ? 'Saved measurements'
                                  : '${date.day}/${date.month}/${date.year}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Measurement actions',
                            onSelected: (value) {
                              if (value == 'delete') {
                                _delete(entryIndex);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded),
                                    SizedBox(width: 8),
                                    Text('Delete entry'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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

class _MeasurementSummary extends StatelessWidget {
  final List<Map<String, dynamic>> entries;

  const _MeasurementSummary({required this.entries});

  @override
  Widget build(BuildContext context) {
    final latest = entries.first;
    final previous = entries.length > 1 ? entries[1] : null;
    const fields = ['chest', 'waist', 'arms', 'thigh'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Latest snapshot',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fields.map((field) {
              final value = (latest[field] as num?)?.toDouble();
              if (value == null) return const SizedBox.shrink();
              final old = (previous?[field] as num?)?.toDouble();
              final delta = old == null ? null : value - old;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${value.toStringAsFixed(1)} cm',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      delta == null
                          ? field.toUpperCase()
                          : '${field.toUpperCase()}  ${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
