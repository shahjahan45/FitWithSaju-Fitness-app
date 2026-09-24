import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/local_store.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/models/exercise.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    LocalStore.favorites().then((items) { if (mounted) setState(() => favorite = items.contains(widget.exercise.id)); });
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;

    return Scaffold(
      appBar: AppBar(title: Text(e.name), actions: [IconButton(onPressed: () async { final added = await LocalStore.toggleFavorite(e.id); if (mounted) setState(() => favorite = added); }, icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? AppColors.primary : AppColors.muted))]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              final dy = -5 * controller.value;
              return Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF202A14), AppColors.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 96,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          Text(
            e.name,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '${e.muscle} • ${e.equipment} • ${e.difficulty}',
            style: const TextStyle(
              color: AppColors.primarySoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          FitCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Info(label: 'Sets', value: '${e.sets}'),
                _Info(label: 'Reps', value: e.reps),
                _Info(label: 'Rest', value: '${e.restSeconds}s'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'How to perform',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            e.instructions,
            style: const TextStyle(
              color: AppColors.muted,
              height: 1.6,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 22),
          FitCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Exercise GIF/WebP/video media will be connected from the Laravel admin media library in the next backend integration sprint.',
                    style: TextStyle(color: AppColors.muted, height: 1.45),
                  ),
                ),
              ],
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
  const _Info({required this.label, required this.value});

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
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ],
    );
  }
}
