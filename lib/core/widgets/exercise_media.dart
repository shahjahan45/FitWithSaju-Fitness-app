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
    final remote = useThumbnail ? exercise.thumbnailUrl : exercise.mediaUrl;

    final content = RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: width,
          height: height,
          child: remote.isNotEmpty
              ? Image.network(
                  remote,
                  fit: fit,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  frameBuilder: (context, child, frame, syncLoaded) {
                    if (syncLoaded || frame != null) {
                      return child;
                    }
                    return const _Loading();
                  },
                  errorBuilder: (_, __, ___) => _assetOrFallback(asset),
                )
              : _assetOrFallback(asset),
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

  Widget _assetOrFallback(String asset) {
    if (asset.isEmpty) {
      return const _Fallback();
    }
    return Image.asset(
      asset,
      fit: fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => const _Fallback(),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceAlt,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.3,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceAlt,
      child: Center(
        child: Icon(
          Icons.fitness_center_rounded,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }
}
