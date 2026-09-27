import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
import '../../core/motion/motion_widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/exercise_media.dart';
import '../../data/exercise_catalog.dart';
import '../../data/models/exercise.dart';
import 'exercise_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _bodyPart = 'All';
  String _equipment = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> get _filteredExercises {
    final query = _query.trim().toLowerCase();

    return ExerciseCatalog.instance.exercises.where((exercise) {
      final matchesQuery = query.isEmpty ||
          exercise.searchableTerms.any(
            (value) => value.toLowerCase().contains(query),
          );
      final matchesBody =
          _bodyPart == 'All' || exercise.bodyParts.contains(_bodyPart);
      final matchesEquipment =
          _equipment == 'All' || exercise.equipments.contains(_equipment);
      return matchesQuery && matchesBody && matchesEquipment;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _bodyPart = 'All';
      _equipment = 'All';
      _searchController.clear();
    });
  }

  Future<void> _chooseEquipment() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final values = <String>[
          'All',
          ...ExerciseCatalog.instance.availableEquipments,
        ];

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .72,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
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
                padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filter by equipment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  itemCount: values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, index) {
                    final value = values[index];
                    final selected = value == _equipment;
                    return Material(
                      color:
                          selected ? AppColors.primarySoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        onTap: () => Navigator.pop(sheetContext, value),
                        leading: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            selected
                                ? Icons.check_rounded
                                : Icons.fitness_center_rounded,
                            color: selected ? Colors.white : AppColors.muted,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          _pretty(value),
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w900 : FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _equipment = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    final hasFilters =
        _query.isNotEmpty || _bodyPart != 'All' || _equipment != 'All';

    return SafeArea(
      child: CustomScrollView(
        key: const PageStorageKey('explore-scroll'),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                children: [
                  MotionReveal(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -.7,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Real exercise demonstrations for every session.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        _CatalogBadge(
                          count: ExerciseCatalog.instance.exercises.length,
                          source: ExerciseCatalog.instance.source.value,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  MotionReveal(
                    delay: const Duration(milliseconds: 50),
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Search exercise, muscle, or equipment...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  MotionReveal(
                    delay: const Duration(milliseconds: 90),
                    child: SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _bodyPart == 'All',
                            onTap: () => setState(() => _bodyPart = 'All'),
                          ),
                          ...ExerciseCatalog.instance.availableBodyParts.map(
                            (part) => _FilterChip(
                              label: _pretty(part),
                              selected: _bodyPart == part,
                              onTap: () => setState(() => _bodyPart = part),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  MotionReveal(
                    delay: const Duration(milliseconds: 120),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${exercises.length} movement${exercises.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _chooseEquipment,
                          icon: const Icon(
                            Icons.tune_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _equipment == 'All'
                                ? 'Equipment'
                                : _pretty(_equipment),
                          ),
                        ),
                        if (hasFilters)
                          IconButton(
                            tooltip: 'Clear filters',
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (exercises.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverToBoxAdapter(
                child: _EmptySearch(onClear: _clearFilters),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = exercises[index];
                    final stagger = index > 7 ? 7 : index;

                    return MotionReveal(
                      key: ValueKey(
                        'exercise-${exercise.id}-$_bodyPart-$_equipment',
                      ),
                      delay: Duration(
                        milliseconds: 110 + (stagger * 28),
                      ),
                      offsetY: 10,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExerciseCard(
                          exercise: exercise,
                          onTap: () => Navigator.of(context).push(
                            FitRoutes.route(
                              context,
                              motion: FitRouteMotion.detail,
                              builder: (_) =>
                                  ExerciseDetailScreen(exercise: exercise),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: exercises.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _pretty(String value) {
    if (value == 'All') {
      return value;
    }
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

class _CatalogBadge extends StatelessWidget {
  final int count;
  final ExerciseCatalogSource source;

  const _CatalogBadge({
    required this.count,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (source) {
      ExerciseCatalogSource.live => 'LIVE',
      ExerciseCatalogSource.cached => 'CACHED',
      ExerciseCatalogSource.bundled => 'OFFLINE',
    };
    final icon = switch (source) {
      ExerciseCatalogSource.live => Icons.cloud_done_rounded,
      ExerciseCatalogSource.cached => Icons.cloud_queue_rounded,
      ExerciseCatalogSource.bundled => Icons.offline_bolt_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            '$label • $count',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PressableScale(
        onTap: onTap,
        pressedScale: .96,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: AppMotion.duration(
            context,
            const Duration(milliseconds: 190),
          ),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: AppMotion.duration(
              context,
              const Duration(milliseconds: 160),
            ),
            style: TextStyle(
              color: selected ? Colors.white : AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: .035),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ExerciseMedia(
              exercise: exercise,
              useThumbnail: true,
              useHero: true,
              width: 82,
              height: 82,
              borderRadius: BorderRadius.circular(19),
            ),
            const SizedBox(width: 14),
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
                      fontSize: 15,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exercise.muscle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.bodyPart} • ${exercise.equipment}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final VoidCallback onClear;

  const _EmptySearch({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return MotionReveal(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primarySoft,
              child: Icon(
                Icons.search_off_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No matching exercise',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try another muscle, body part, or equipment filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}
