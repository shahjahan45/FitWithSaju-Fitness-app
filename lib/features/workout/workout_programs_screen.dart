import 'package:flutter/material.dart';

import '../../core/motion/motion_widgets.dart';
import '../../core/navigation/settled_dialog.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/fit_card.dart';

class WorkoutProgramsScreen extends StatefulWidget {
  const WorkoutProgramsScreen({super.key});

  @override
  State<WorkoutProgramsScreen> createState() => _WorkoutProgramsScreenState();
}

class _WorkoutProgramsScreenState extends State<WorkoutProgramsScreen> {
  String? _applyingId;

  Future<void> _apply(_WorkoutProgram program) async {
    final confirmed = await showSettledDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Apply ${program.name}?'),
        content: const Text(
          'This replaces your current Monday–Sunday workout plan. Your workout history and personal records are not changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Apply program'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _applyingId = program.id);
    await LocalStore.replaceWeeklyPlan(program.weeklyPlan);
    if (!mounted) {
      return;
    }
    setState(() => _applyingId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${program.name} is now your weekly plan.')),
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
                  'Apply a complete weekly program, then customize any day from the Workout tab.',
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._programs.indexed.map((entry) {
            final index = entry.$1;
            final program = entry.$2;
            return MotionReveal(
              delay: Duration(milliseconds: 60 * index),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ProgramCard(
                  program: program,
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
  final _WorkoutProgram program;
  final bool applying;
  final VoidCallback onApply;

  const _ProgramCard({
    required this.program,
    required this.applying,
    required this.onApply,
  });

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
                child: Icon(program.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${program.level} • ${program.trainingDays} training days/week',
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
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(tag,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ))
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
                  : const Icon(Icons.calendar_month_rounded),
              label: Text(applying ? 'Applying...' : 'Apply weekly program'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutProgram {
  final String id;
  final String name;
  final String level;
  final String description;
  final int trainingDays;
  final IconData icon;
  final List<String> tags;
  final List<Map<String, dynamic>> weeklyPlan;

  const _WorkoutProgram({
    required this.id,
    required this.name,
    required this.level,
    required this.description,
    required this.trainingDays,
    required this.icon,
    required this.tags,
    required this.weeklyPlan,
  });
}

const _programs = <_WorkoutProgram>[
  _WorkoutProgram(
    id: 'foundation_3',
    name: 'Foundation 3-Day',
    level: 'Beginner',
    description:
        'A recovery-friendly full-body structure for building consistency, movement quality, and basic strength.',
    trainingDays: 3,
    icon: Icons.sports_gymnastics_rounded,
    tags: ['Full body', 'Consistency', 'Recovery friendly'],
    weeklyPlan: [
      {
        'day': 'Monday',
        'title': 'Full Body A',
        'isRest': false,
        'durationMinutes': 45,
        'exerciseIds': ['2Qh2J1e', '3TZduzM', '7F1DVzn', '6cKQC5E']
      },
      {
        'day': 'Tuesday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
      {
        'day': 'Wednesday',
        'title': 'Full Body B',
        'isRest': false,
        'durationMinutes': 45,
        'exerciseIds': ['5bpPTHv', '3eGE2JC', '7I6LNUG', '8eqjhOl']
      },
      {
        'day': 'Thursday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
      {
        'day': 'Friday',
        'title': 'Full Body C',
        'isRest': false,
        'durationMinutes': 45,
        'exerciseIds': ['2ORFMoR', '5uFK1xr', '4dF3maG', '8xUv4J7']
      },
      {
        'day': 'Saturday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
      {
        'day': 'Sunday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
    ],
  ),
  _WorkoutProgram(
    id: 'strength_4',
    name: 'Strength 4-Day',
    level: 'Intermediate',
    description:
        'An upper/lower split with four focused training days and recovery between the heavier sessions.',
    trainingDays: 4,
    icon: Icons.fitness_center_rounded,
    tags: ['Upper / lower', 'Strength', '4 days'],
    weeklyPlan: [
      {
        'day': 'Monday',
        'title': 'Upper Strength',
        'isRest': false,
        'durationMinutes': 55,
        'exerciseIds': ['3TZduzM', '7F1DVzn', '5uFK1xr', '6cKQC5E']
      },
      {
        'day': 'Tuesday',
        'title': 'Lower Strength',
        'isRest': false,
        'durationMinutes': 55,
        'exerciseIds': ['2Qh2J1e', '5bpPTHv', '2ORFMoR', '8eqjhOl']
      },
      {
        'day': 'Wednesday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
      {
        'day': 'Thursday',
        'title': 'Upper Volume',
        'isRest': false,
        'durationMinutes': 50,
        'exerciseIds': ['3eGE2JC', '7I6LNUG', '4dF3maG', '8oYqOt9']
      },
      {
        'day': 'Friday',
        'title': 'Lower Volume',
        'isRest': false,
        'durationMinutes': 50,
        'exerciseIds': ['2Qh2J1e', '5bpPTHv', '8xUv4J7', '8eqjhOl']
      },
      {
        'day': 'Saturday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
      {
        'day': 'Sunday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
    ],
  ),
  _WorkoutProgram(
    id: 'hypertrophy_5',
    name: 'Hypertrophy 5-Day',
    level: 'Intermediate / Advanced',
    description:
        'A five-day muscle-building split for users who recover well and prefer more weekly training volume.',
    trainingDays: 5,
    icon: Icons.bolt_rounded,
    tags: ['Muscle gain', 'Higher volume', '5 days'],
    weeklyPlan: [
      {
        'day': 'Monday',
        'title': 'Push',
        'isRest': false,
        'durationMinutes': 60,
        'exerciseIds': ['3TZduzM', '3eGE2JC', '5uFK1xr', '6cKQC5E']
      },
      {
        'day': 'Tuesday',
        'title': 'Pull',
        'isRest': false,
        'durationMinutes': 60,
        'exerciseIds': ['7F1DVzn', '7I6LNUG', '4dF3maG', '8oYqOt9']
      },
      {
        'day': 'Wednesday',
        'title': 'Legs',
        'isRest': false,
        'durationMinutes': 60,
        'exerciseIds': ['2Qh2J1e', '5bpPTHv', '2ORFMoR', '8eqjhOl']
      },
      {
        'day': 'Thursday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
      {
        'day': 'Friday',
        'title': 'Upper',
        'isRest': false,
        'durationMinutes': 60,
        'exerciseIds': ['5v7KYld', '7F1DVzn', '3eGE2JC', '6cKQC5E']
      },
      {
        'day': 'Saturday',
        'title': 'Lower + Core',
        'isRest': false,
        'durationMinutes': 55,
        'exerciseIds': ['2Qh2J1e', '5bpPTHv', '8xUv4J7', '8eqjhOl']
      },
      {
        'day': 'Sunday',
        'title': 'Rest',
        'isRest': true,
        'durationMinutes': 0,
        'exerciseIds': <String>[]
      },
    ],
  ),
];
