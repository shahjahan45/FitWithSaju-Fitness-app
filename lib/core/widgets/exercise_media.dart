import 'package:flutter/material.dart';

import '../../data/models/exercise.dart';
import '../theme/app_colors.dart';

class ExerciseMedia extends StatelessWidget {
  final Exercise exercise;
  final bool useThumbnail;
  final bool useHero;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;

  const ExerciseMedia({
    super.key,
    required this.exercise,
    this.useThumbnail = false,
    this.useHero = false,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final asset = useThumbnail ? exercise.thumbnailAsset : exercise.mediaAsset;
    final content = RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: asset.isEmpty
              ? const _Fallback()
              : Image.asset(
                  asset,
                  fit: fit,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => const _Fallback(),
                ),
        ),
      ),
    );

    if (!useHero) {
      return content;
    }

    return Hero(
      tag: 'exercise-art-${exercise.id}',
      child: Material(
        color: Colors.transparent,
        child: content,
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySoft,
            Color(0xFFF7FAF3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.primary,
          size: 36,
        ),
      ),
    );
  }
}
