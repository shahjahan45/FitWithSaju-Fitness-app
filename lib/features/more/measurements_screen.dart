import 'package:flutter/material.dart';

import '../../core/navigation/settled_dialog.dart';
import '../../core/widgets/app_screen.dart';
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
    final values = await showSettledModalBottomSheet<Map<String, double>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        final keyboardInset = media.viewInsets.bottom;
        final availableHeight = media.size.height - keyboardInset;
        final desiredHeight = availableHeight * .88;
        final sheetHeight = desiredHeight > 720 ? 720.0 : desiredHeight;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final canSave = controllers.values.any(
              (controller) {
                final value = double.tryParse(controller.text.trim());
                return value != null && value > 0;
              },
            );

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: sheetHeight,
                  child: Material(
                    color: AppColors.surface,
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    child: SafeArea(
                      top: false,
                      maintainBottomViewPadding: true,
                      minimum: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add measurements',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Record any measurements you want to track today.',
                                        style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.straighten_rounded,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                              children: [
                                ...fields.map(
                                  (field) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: TextField(
                                      controller: controllers[field],
                                      keyboardType: const TextInputType
                                          .numberWithOptions(decimal: true),
                                      textInputAction: field == fields.last
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                      onChanged: (_) => setSheetState(() {}),
                                      decoration: InputDecoration(
                                        labelText: field,
                                        suffixText: 'cm',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton(
                                onPressed: canSave
                                    ? () {
                                        final result = <String, double>{};
                                        for (final field in fields) {
                                          final parsed = double.tryParse(
                                            controllers[field]!.text.trim(),
                                          );
                                          if (parsed != null && parsed > 0) {
                                            result[field.toLowerCase()] = parsed;
                                          }
                                        }
                                        Navigator.of(sheetContext).pop(result);
                                      }
                                    : null,
                                child: const Text('Save Measurements'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
              padding: fitPagePadding(context, bottom: 100),
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
                              style: const TextStyle(fontWeight: FontWeight.w900),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
