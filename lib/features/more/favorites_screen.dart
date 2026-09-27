import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/exercise_media.dart';
import '../../data/exercise_catalog.dart';
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
      (ids) => ExerciseCatalog.instance.exercises
          .where((exercise) => ids.contains(exercise.id))
          .toList(),
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
                  style: TextStyle(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final exercise = items[index];
              final stagger = index > 6 ? 6 : index;

              return MotionReveal(
                delay: Duration(milliseconds: stagger * 35),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PressableScale(
                    onTap: () async {
                      await Navigator.of(context).push(
                        FitRoutes.route(
                          context,
                          motion: FitRouteMotion.detail,
                          builder: (_) =>
                              ExerciseDetailScreen(exercise: exercise),
                        ),
                      );
                      if (!mounted) {
                        return;
                      }
                      setState(_reload);
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ExerciseMedia(
                            exercise: exercise,
                            useThumbnail: true,
                            useHero: true,
                            width: 68,
                            height: 68,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${exercise.muscle} • ${exercise.equipment}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
