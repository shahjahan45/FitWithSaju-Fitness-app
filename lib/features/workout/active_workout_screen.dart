import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/workout.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final Workout workout;
  const ActiveWorkoutScreen({super.key, required this.workout});
  @override State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int exerciseIndex = 0, setIndex = 1, rest = 0, completedSets = 0;
  Timer? timer;
  late DateTime startedAt;
  final weightController = TextEditingController(text: '60');
  final repsController = TextEditingController(text: '10');

  @override void initState() { super.initState(); startedAt = DateTime.now(); }

  Future<void> _completeSet() async {
    setState(() => completedSets++);
    final exercise = widget.workout.exercises[exerciseIndex];
    if (setIndex < exercise.sets) {
      setState(() { rest = exercise.restSeconds; setIndex++; });
      _startRest(); return;
    }
    if (exerciseIndex < widget.workout.exercises.length - 1) {
      setState(() { exerciseIndex++; setIndex = 1; rest = 0; repsController.text = '10'; });
    } else { await _finishWorkout(); }
  }

  void _startRest() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (rest <= 1) { t.cancel(); setState(() => rest = 0); }
      else { setState(() => rest--); }
    });
  }

  Future<void> _finishWorkout() async {
    final duration = DateTime.now().difference(startedAt).inMinutes.clamp(1, 999);
    await LocalStore.addWorkoutHistory({
      'title': widget.workout.title,
      'date': DateTime.now().toIso8601String(),
      'durationMinutes': duration,
      'completedSets': completedSets,
      'exerciseCount': widget.workout.exercises.length,
    });
    if (!mounted) return;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppColors.surface,
      builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(24, 28, 24, 36), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 86, height: 86, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary])), child: const Icon(Icons.check_rounded, color: Colors.white, size: 46)),
        const SizedBox(height: 18), const Text('Workout complete!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8), Text('$completedSets sets completed • $duration min', style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900))))
      ])));
  }

  @override void dispose() { timer?.cancel(); weightController.dispose(); repsController.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final e = widget.workout.exercises[exerciseIndex];
    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title), actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Text('${exerciseIndex+1}/${widget.workout.exercises.length}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (exerciseIndex+1)/widget.workout.exercises.length, minHeight: 8, color: AppColors.primary, backgroundColor: AppColors.surfaceAlt)),
        const SizedBox(height: 24),
        Container(height: 260, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF24160C), Color(0xFF071B2A)]), borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.border)), child: Center(child: Image.asset('assets/images/fitwithsaju_logo.png', width: 190))),
        const SizedBox(height: 22), Text(e.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text('${e.muscle} • ${e.equipment}', style: const TextStyle(color: AppColors.muted)), const SizedBox(height: 22),
        if (rest > 0) _RestCard(rest: rest, onSkip: () { timer?.cancel(); setState(() => rest = 0); }, onAdd: () => setState(() => rest += 15)) else ...[
          Row(children: [Expanded(child: _EditableMetric(label: 'WEIGHT', controller: weightController, suffix: 'KG')), const SizedBox(width: 12), Expanded(child: _EditableMetric(label: 'REPS', controller: repsController, suffix: ''))]),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)), child: Row(children: [Text('Set $setIndex of ${e.sets}', style: const TextStyle(fontWeight: FontWeight.w900)), const Spacer(), Text('${e.reps} target', style: const TextStyle(color: AppColors.muted))])),
          const SizedBox(height: 18),
          SizedBox(height: 58, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), onPressed: _completeSet, icon: const Icon(Icons.check_rounded), label: const Text('Complete Set', style: TextStyle(fontWeight: FontWeight.w900))))
        ]
      ]),
    );
  }
}

class _EditableMetric extends StatelessWidget {
  final String label, suffix; final TextEditingController controller;
  const _EditableMetric({required this.label, required this.controller, required this.suffix});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 5),
    Row(children: [Expanded(child: TextField(controller: controller, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900), decoration: const InputDecoration(isDense: true, filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, contentPadding: EdgeInsets.zero))), if (suffix.isNotEmpty) Text(suffix, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800))])
  ]));
}

class _RestCard extends StatelessWidget {
  final int rest; final VoidCallback onSkip, onAdd;
  const _RestCard({required this.rest, required this.onSkip, required this.onAdd});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha:.12), AppColors.secondary.withValues(alpha:.10)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary)), child: Column(children: [
    const Text('REST', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, letterSpacing: 2)), const SizedBox(height: 6), Text('${rest~/60}:${(rest%60).toString().padLeft(2,'0')}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [TextButton(onPressed: onAdd, child: const Text('+15 sec')), const SizedBox(width: 14), TextButton(onPressed: onSkip, child: const Text('Skip rest'))])
  ]));
}
