import 'package:flutter/material.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await LocalStore.weightEntries();
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final controller = TextEditingController();
    final value = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add body weight',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  suffixText: 'KG',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    final parsed = double.tryParse(controller.text.trim());
                    if (parsed != null && parsed > 0) {
                      Navigator.of(sheetContext).pop(parsed);
                    }
                  },
                  child: const Text(
                    'Save Weight',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (value == null) {
      return;
    }
    await LocalStore.addWeight(value);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body Weight')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Weight'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                if (_entries.isNotEmpty) _Summary(entries: _entries),
                if (_entries.isNotEmpty) const SizedBox(height: 20),
                if (_entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Text(
                      'Add your first body-weight entry to start tracking progress.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, height: 1.5),
                    ),
                  ),
                ...List.generate(_entries.length, (index) {
                  final entry = _entries[index];
                  final date = DateTime.tryParse(entry['date']?.toString() ?? '');
                  return Dismissible(
                    key: ValueKey('${entry['date']}-$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 22),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      await LocalStore.deleteWeightAt(index);
                      await _load();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: AppColors.surface,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primarySoft,
                          child: Icon(Icons.monitor_weight_rounded, color: AppColors.primary),
                        ),
                        title: Text(
                          '${(entry['value'] as num).toStringAsFixed(1)} KG',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          date == null
                              ? 'Saved entry'
                              : '${date.day}/${date.month}/${date.year}',
                        ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _Summary extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  const _Summary({required this.entries});

  @override
  Widget build(BuildContext context) {
    final latest = (entries.first['value'] as num).toDouble();
    final oldest = (entries.last['value'] as num).toDouble();
    final delta = latest - oldest;
    final recent = entries.take(7).toList().reversed.toList();
    final values = recent.map((e) => (e['value'] as num).toDouble()).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs() < .1 ? 1.0 : maxValue - minValue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Latest', style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            '${latest.toStringAsFixed(1)} KG',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} KG since first entry',
            style: TextStyle(
              color: delta <= 0 ? AppColors.success : AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.map((value) {
                final normalized = .25 + ((value - minValue) / range) * .75;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      height: 80 * normalized,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .72),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
