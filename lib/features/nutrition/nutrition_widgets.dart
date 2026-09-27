import 'package:flutter/material.dart';

import '../../core/motion/motion_widgets.dart';
import 'data/nutrition_models.dart';

class NutritionPalette {
  NutritionPalette._();

  static const canvas = Color(0xFFF6F8F4);
  static const surface = Colors.white;
  static const tint = Color(0xFFEAF3DF);
  static const brand = Color(0xFF2E651F);
  static const hero = Color(0xFF193D2B);
  static const accent = Color(0xFFA5D83F);
  static const ink = Color(0xFF16261E);
  static const muted = Color(0xFF607066);
  static const line = Color(0xFFDCE4D8);
  static const warning = Color(0xFFB8741A);
}

String nutritionDayLabel(DateTime date) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[date.weekday - 1];
}

String nutritionLongDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${nutritionDayLabel(date)}, ${months[date.month - 1]} ${date.day}';
}

String formatAmount(double value) {
  if ((value - value.round()).abs() < .01) {
    return value.round().toString();
  }
  return value.toStringAsFixed(1);
}

class NutritionPageBackground extends StatelessWidget {
  final Widget child;

  const NutritionPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: NutritionPalette.canvas, child: child);
  }
}

class NutritionArtwork extends StatelessWidget {
  final String artwork;
  final String? assetPath;
  final double size;
  final BorderRadius borderRadius;

  const NutritionArtwork({
    super.key,
    required this.artwork,
    this.assetPath,
    this.size = 104,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: NutritionPalette.tint,
        borderRadius: borderRadius,
      ),
      child: assetPath == null
          ? Text(
              artwork,
              semanticsLabel: 'Meal illustration',
              style: TextStyle(fontSize: size * .43),
            )
          : ClipRRect(
              borderRadius: borderRadius,
              child: Image.asset(
                assetPath!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                semanticLabel: 'Meal illustration',
              ),
            ),
    );
  }
}

class NutritionSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const NutritionSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: NutritionPalette.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class NutritionSoftButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const NutritionSoftButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: PressableScale(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: NutritionPalette.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: NutritionPalette.brand, size: 18),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: NutritionPalette.brand,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NutritionMacroLine extends StatelessWidget {
  final NutritionMacros macros;
  final double servings;

  const NutritionMacroLine({
    super.key,
    required this.macros,
    this.servings = 1,
  });

  @override
  Widget build(BuildContext context) {
    final value = macros.scale(servings);
    return Wrap(
      spacing: 8,
      runSpacing: 5,
      children: [
        Text(
          '${value.calories.round()} kcal',
          style: const TextStyle(
            color: NutritionPalette.ink,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Text(
          'P ${value.protein.round()}g',
          style: const TextStyle(color: NutritionPalette.muted, fontSize: 12),
        ),
        Text(
          'C ${value.carbs.round()}g',
          style: const TextStyle(color: NutritionPalette.muted, fontSize: 12),
        ),
        Text(
          'F ${value.fat.round()}g',
          style: const TextStyle(color: NutritionPalette.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class NutritionInfoPill extends StatelessWidget {
  final String text;
  final IconData? icon;

  const NutritionInfoPill({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: NutritionPalette.tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: NutritionPalette.brand),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: const TextStyle(
              color: NutritionPalette.brand,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
