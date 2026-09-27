import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/exercise_media.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/models/exercise.dart';
import 'exercise_progress_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    LocalStore.favorites().then((items) {
      if (mounted) {
        setState(() => favorite = items.contains(widget.exercise.id));
      }
    });
  }

  Future<void> _toggleFavorite() async {
    final added = await LocalStore.toggleFavorite(widget.exercise.id);
    if (mounted) {
      setState(() => favorite = added);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
        actions: [
          IconButton(
            tooltip: favorite ? 'Remove favorite' : 'Add favorite',
            onPressed: _toggleFavorite,
            icon: AnimatedSwitcher(
              duration: AppMotion.duration(
                context,
                const Duration(milliseconds: 220),
              ),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(favorite),
                color: favorite ? AppColors.primary : AppColors.muted,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          MotionReveal(
            child: Stack(
              children: [
                Container(
                  height: 310,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: .045),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ExerciseMedia(
                    exercise: exercise,
                    useHero: true,
                    width: double.infinity,
                    height: 310,
                    borderRadius: BorderRadius.circular(29),
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_fill_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Animated demo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          MotionReveal(
            delay: const Duration(milliseconds: 45),
            child: Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 30,
                height: 1.08,
                fontWeight: FontWeight.w900,
                letterSpacing: -.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          MotionReveal(
            delay: const Duration(milliseconds: 70),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(
                  icon: Icons.bolt_rounded,
                  label: exercise.muscle,
                  highlighted: true,
                ),
                _MetaChip(
                  icon: Icons.accessibility_new_rounded,
                  label: exercise.bodyPart,
                ),
                _MetaChip(
                  icon: Icons.fitness_center_rounded,
                  label: exercise.equipment,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          MotionReveal(
            delay: const Duration(milliseconds: 95),
            child: FitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Workout defaults',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Info(label: 'Sets', value: '${exercise.sets}'),
                      _Info(label: 'Reps', value: exercise.reps),
                      _Info(
                        label: 'Rest',
                        value: '${exercise.restSeconds}s',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (exercise.secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 18),
            MotionReveal(
              delay: const Duration(milliseconds: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Also works',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exercise.secondaryMuscles
                        .map(
                          (muscle) => _SmallChip(
                            label: _pretty(muscle),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          MotionReveal(
            delay: const Duration(milliseconds: 145),
            child: const Text(
              'How to perform',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(exercise.instructionSteps.length, (index) {
            return MotionReveal(
              delay: Duration(
                milliseconds: 165 + ((index > 5 ? 5 : index) * 24),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InstructionStep(
                  number: index + 1,
                  text: _cleanStep(exercise.instructionSteps[index]),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          MotionReveal(
            delay: const Duration(milliseconds: 230),
            child: PressableScale(
              onTap: () => Navigator.of(context).push(
                FitRoutes.route(
                  context,
                  motion: FitRouteMotion.detail,
                  builder: (_) => ExerciseProgressScreen(exercise: exercise),
                ),
              ),
              borderRadius: BorderRadius.circular(24),
              child: const FitCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(
                        Icons.show_chart_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Strength history',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Weight, recent sets, and estimated 1RM trend',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _cleanStep(String value) {
    return value.replaceFirst(RegExp(r'^Step:\d+\s*'), '').trim();
  }

  static String _pretty(String value) {
    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primarySoft : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: highlighted ? AppColors.primary : AppColors.muted,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: highlighted ? AppColors.primary : AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;

  const _SmallChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;

  const _InstructionStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.text,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
