import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/nutrition_catalog.dart';
import 'data/nutrition_store.dart';
import 'nutrition_widgets.dart';

class ShoppingListScreen extends StatefulWidget {
  final DateTime startDate;

  const ShoppingListScreen({super.key, required this.startDate});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  int _days = 7;
  int _people = 1;
  late Future<_ShoppingData> _future;

  @override
  void initState() {
    super.initState();
    _future = _buildData();
  }

  void _refresh() => setState(() => _future = _buildData());

  Future<_ShoppingData> _buildData() async {
    final amounts = <String, _ShoppingItem>{};
    for (var day = 0; day < _days; day++) {
      final date = widget.startDate.add(Duration(days: day));
      final plan = await NutritionStore.planForDate(date);
      for (final meal in plan) {
        final recipe = NutritionCatalog.byId(meal.recipeId);
        if (recipe == null) {
          continue;
        }
        final scale = (meal.servings / recipe.yieldServings) * _people;
        for (final ingredient in recipe.ingredients) {
          final id =
              '${ingredient.category}|${ingredient.name}|${ingredient.unit}'
                  .toLowerCase();
          final existing = amounts[id];
          if (existing == null) {
            amounts[id] = _ShoppingItem(
              id: id,
              name: ingredient.name,
              category: ingredient.category,
              quantity: ingredient.quantity * scale,
              unit: ingredient.unit,
            );
          } else {
            amounts[id] = existing.copyWith(
              quantity: existing.quantity + (ingredient.quantity * scale),
            );
          }
        }
      }
    }
    final checked = await NutritionStore.shoppingChecked();
    final manual = await NutritionStore.manualShoppingItems();
    final items = amounts.values.toList()
      ..sort((a, b) {
        final group = a.category.compareTo(b.category);
        return group == 0 ? a.name.compareTo(b.name) : group;
      });
    return _ShoppingData(items: items, checked: checked, manual: manual);
  }

  Future<void> _addManual() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add shopping item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Sparkling water'),
          onSubmitted: (text) => Navigator.of(context).pop(text),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Add')),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty) {
      return;
    }
    await NutritionStore.addManualShoppingItem(value);
    if (!mounted) {
      return;
    }
    _refresh();
  }

  Future<void> _editManual(Map<String, dynamic> item) async {
    final controller = TextEditingController(
      text: item['name']?.toString() ?? '',
    );
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit shopping item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Item name'),
          onSubmitted: (text) => Navigator.of(context).pop(text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || value.trim().isEmpty) {
      return;
    }
    await NutritionStore.updateManualShoppingItem(
      item['id']?.toString() ?? '',
      value,
    );
    if (!mounted) {
      return;
    }
    _refresh();
  }

  Future<void> _share(_ShoppingData data) async {
    final buffer = StringBuffer('FitWithSaju shopping list\n');
    String? category;
    for (final item in data.items) {
      if (category != item.category) {
        category = item.category;
        buffer.writeln('\n$category');
      }
      buffer.writeln(
          '• ${formatAmount(item.quantity)} ${item.unit} ${item.name}');
    }
    if (data.manual.isNotEmpty) {
      buffer.writeln('\nOther');
      for (final item in data.manual) {
        buffer.writeln('• ${item['name']}');
      }
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shopping list copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutritionPalette.canvas,
      appBar: AppBar(
        title: const Text('Shopping list'),
        actions: [
          IconButton(
            tooltip: 'Add manual item',
            onPressed: _addManual,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<_ShoppingData>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                const Text(
                  'Plan the shop',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ingredients are combined only when their units are compatible. Checked items stay checked when possible.',
                  style: TextStyle(color: NutritionPalette.muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _days,
                        decoration:
                            const InputDecoration(labelText: 'Date range'),
                        items: const [3, 5, 7]
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text('$value days')))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _days = value;
                            _future = _buildData();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _people,
                        decoration: const InputDecoration(labelText: 'People'),
                        items: const [1, 2, 3, 4, 5, 6]
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text('$value')))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _people = value;
                            _future = _buildData();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (data.items.isEmpty && data.manual.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text(
                        'Your shopping list is empty.',
                        style: TextStyle(color: NutritionPalette.muted),
                      ),
                    ),
                  )
                else ...[
                  ..._buildGrouped(data),
                  if (data.manual.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const NutritionSectionTitle(title: 'Other'),
                    const SizedBox(height: 6),
                    ...data.manual.map((item) {
                      final id = item['id']?.toString() ?? '';
                      final checked = data.checked[id] == true;
                      return _CheckRow(
                        checked: checked,
                        label: item['name']?.toString() ?? 'Item',
                        onChanged: (value) async {
                          await NutritionStore.setShoppingChecked(id, value);
                          if (!mounted) {
                            return;
                          }
                          _refresh();
                        },
                        onEdit: () => _editManual(item),
                        onDelete: () async {
                          await NutritionStore.deleteManualShoppingItem(id);
                          if (!mounted) {
                            return;
                          }
                          _refresh();
                        },
                      );
                    }),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _share(data),
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Copy shopping list',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildGrouped(_ShoppingData data) {
    final widgets = <Widget>[];
    String? category;
    for (final item in data.items) {
      if (category != item.category) {
        if (category != null) {
          widgets.add(const SizedBox(height: 12));
        }
        category = item.category;
        widgets.add(NutritionSectionTitle(title: category));
        widgets.add(const SizedBox(height: 6));
      }
      final checked = data.checked[item.id] == true;
      widgets.add(
        _CheckRow(
          checked: checked,
          label: '${formatAmount(item.quantity)} ${item.unit}  ${item.name}',
          onChanged: (value) async {
            await NutritionStore.setShoppingChecked(item.id, value);
            if (!mounted) {
              return;
            }
            _refresh();
          },
        ),
      );
    }
    return widgets;
  }
}

class _CheckRow extends StatelessWidget {
  final bool checked;
  final String label;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CheckRow({
    required this.checked,
    required this.label,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: CheckboxListTile(
        value: checked,
        activeColor: NutritionPalette.brand,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(
          label,
          style: TextStyle(
            decoration: checked ? TextDecoration.lineThrough : null,
            color: checked ? NutritionPalette.muted : NutritionPalette.ink,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        secondary: onEdit == null && onDelete == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      tooltip: 'Edit item',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Delete item',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                ],
              ),
        onChanged: (value) => onChanged(value ?? false),
      ),
    );
  }
}

class _ShoppingData {
  final List<_ShoppingItem> items;
  final Map<String, bool> checked;
  final List<Map<String, dynamic>> manual;

  const _ShoppingData(
      {required this.items, required this.checked, required this.manual});
}

class _ShoppingItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit;

  const _ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
  });

  _ShoppingItem copyWith({double? quantity}) => _ShoppingItem(
        id: id,
        name: name,
        category: category,
        quantity: quantity ?? this.quantity,
        unit: unit,
      );
}
