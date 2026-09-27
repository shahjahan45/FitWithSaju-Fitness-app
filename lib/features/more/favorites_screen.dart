import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../data/demo_repository.dart';
import '../../data/models/exercise.dart';
import '../explore/exercise_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Exercise>> _favorites;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _favorites = LocalStore.favorites().then(
      (ids) => DemoRepository.exercises.where((e) => ids.contains(e.id)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: FutureBuilder<List<Exercise>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No favorite exercises yet. Tap the heart on an exercise to save it here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.5),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final exercise = items[index];
              return ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                leading: Hero(
                  tag: 'exercise-art-${exercise.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text('${exercise.muscle} • ${exercise.equipment}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await Navigator.of(context).push(
                    FitRoutes.route(
                      context,
                      motion: FitRouteMotion.detail,
                      builder: (_) => ExerciseDetailScreen(exercise: exercise),
                    ),
                  );
                  if (!mounted) {
                    return;
                  }
                  setState(_reload);
                },
              );
            },
          );
        },
      ),
    );
  }
}
