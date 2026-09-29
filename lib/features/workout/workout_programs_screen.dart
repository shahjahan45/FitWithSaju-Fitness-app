import 'package:flutter/material.dart';

import '../../core/motion/motion_widgets.dart';
import '../../core/navigation/settled_dialog.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';
import '../../data/workout_program_catalog.dart';

class WorkoutProgramsScreen extends StatefulWidget {
  const WorkoutProgramsScreen({super.key});

  @override
  State<WorkoutProgramsScreen> createState() => _WorkoutProgramsScreenState();
}

class _WorkoutProgramsScreenState extends State<WorkoutProgramsScreen> {
  String? _applyingId;
  String? _activeProgramId;

  @override
  void initState() {
    super.initState();
    _loadActive();
  }

  Future<void> _loadActive() async {
    final active = await LocalStore.activeProgram();
    if (!mounted) {
      return;
    }
    setState(() => _activeProgramId = active?['programId']?.toString());
  }

  Future<void> _apply(WorkoutProgramDefinition program) async {
    final existing = await LocalStore.activeProgram();
    if (!mounted) {
      return;
    }
    final switching =
        existing != null && existing['programId']?.toString() != program.id;
    final sameProgram = existing?['programId']?.toString() == program.id;

    final confirmed = await showSettledDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(sameProgram
            ? 'Restart ${program.name}?'
            : 'Apply ${program.name}?'),
        content: Text(
          sameProgram
              ? 'This restarts the program from week 1 and refreshes your Monday–Sunday plan. Existing workout history and personal records stay intact.'
              : switching
                  ? 'This switches from your current active program to ${program.name}. Previous program progress is archived and your workout history is not deleted.'
                  : 'This starts a ${program.durationWeeks}-week program and replaces your current Monday–Sunday workout plan. Workout history and personal records are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(switching
                ? 'Switch program'
                : sameProgram
                    ? 'Restart'
                    : 'Start program'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _applyingId = program.id);
    await LocalStore.startWorkoutProgram(
      programId: program.id,
      name: program.name,
      level: program.level,
      durationWeeks: program.durationWeeks,
      trainingDays: program.trainingDays,
      weeklyPlan: program.planWithProgramMetadata(),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _applyingId = null;
      _activeProgramId = program.id;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${program.name} is now active. Week 1 starts today.')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Workout Programs')),
      body: FitScrollableScreen(
        horizontalPadding: 20,
        topPadding: 16,
        bottomSpacing: 24,
        children: [
          const MotionReveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your training structure',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6),
                Text(
                  'Start a guided multi-week program, track completed sessions, and still customize any day from the Workout tab.',
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...WorkoutProgramCatalog.programs.indexed.map((entry) {
            final index = entry.$1;
            final program = entry.$2;
            return MotionReveal(
              delay: Duration(milliseconds: 60 * index),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ProgramCard(
                  program: program,
                  active: _activeProgramId == program.id,
                  applying: _applyingId == program.id,
                  onApply: () => _apply(program),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tune_rounded, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Programs are starting structures, not rigid prescriptions. Edit exercise selection, duration, rest days, or volume to match your ability and recovery.',
                    style: TextStyle(height: 1.45),
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

class _ProgramCard extends StatelessWidget {
  final WorkoutProgramDefinition program;
  final bool active;
  final bool applying;
  final VoidCallback onApply;

  const _ProgramCard({
    required this.program,
    required this.active,
    required this.applying,
    required this.onApply,
  });

  IconData get _icon {
    switch (program.id) {
      case 'strength_4':
        return Icons.fitness_center_rounded;
      case 'hypertrophy_5':
        return Icons.bolt_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FitCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            program.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${program.level} • ${program.trainingDays} days/week • ${program.durationWeeks} weeks',
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(program.description, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: program.tags
                .map(
                  (tag) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          ...program.weeklyPlan.map((day) {
            final rest = day['isRest'] == true;
            final count =
                ((day['exerciseIds'] as Iterable?) ?? const []).length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    child: Text(
                      day['day'].toString().substring(0, 3),
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rest ? 'Recovery' : '${day['title']} • $count exercises',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: rest ? AppColors.muted : AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: applying ? null : onApply,
              icon: applying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(active
                      ? Icons.restart_alt_rounded
                      : Icons.play_arrow_rounded),
              label: Text(
                applying
                    ? 'Applying...'
                    : active
                        ? 'Restart program'
                        : 'Start ${program.durationWeeks}-week program',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
