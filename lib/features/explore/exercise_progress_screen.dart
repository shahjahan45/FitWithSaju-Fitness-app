import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/app_screen.dart';

import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/pro_empty_state.dart';
import '../../data/models/exercise.dart';

class ExerciseProgressScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseProgressScreen({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${exercise.name} Progress')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: LocalStore.exerciseSetHistory(exercise.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sets = snapshot.data!;
          if (sets.isEmpty) {
            return ProEmptyState(
              icon: Icons.show_chart_rounded,
              title: 'No strength trend yet',
              message:
                  'Complete ${exercise.name} in a workout with saved weight and reps. FitWithSaju will build your estimated 1RM and set history here.',
              primaryLabel: 'Back to exercise',
              onPrimary: () => Navigator.of(context).pop(),
            );
          }

          final calculatedPoints = _dailyBestPoints(sets);
          final maxWeight = sets.fold<double>(0, (best, set) {
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            return math.max(best, weight);
          });
          final bestOneRm = sets.fold<double>(0, (best, set) {
            final weight = (set['weight'] as num?)?.toDouble() ?? 0;
            final reps = (set['reps'] as num?)?.toInt() ?? 0;
            return math.max(
              best,
              LocalStore.estimatedOneRepMax(weight, reps),
            );
          });
          final points = calculatedPoints.isEmpty
              ? <_TrendPoint>[_TrendPoint(DateTime.now(), bestOneRm)]
              : calculatedPoints;

          return ListView(
            padding: fitPagePadding(context, bottom: 28),
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${exercise.muscle} • ${exercise.equipment}',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Best weight',
                      value: '${_number(maxWeight)} KG',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'Est. 1RM',
                      value: '${_number(bestOneRm)} KG',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      label: 'Tracked sets',
                      value: '${sets.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated 1RM trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Epley estimate from your best logged set each day.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 190,
                      child: CustomPaint(
                        painter:
                            _TrendPainter(points.map((e) => e.value).toList()),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _shortDate(points.first.date),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          _shortDate(points.last.date),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Recent sets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...sets.reversed.take(10).map((set) {
                final weight = (set['weight'] as num?)?.toDouble() ?? 0;
                final reps = (set['reps'] as num?)?.toInt() ?? 0;
                final date = DateTime.tryParse(
                  set['completedAt']?.toString() ??
                      set['sessionDate']?.toString() ??
                      '',
                );
                final oneRm = LocalStore.estimatedOneRepMax(weight, reps);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_number(weight)} KG × $reps reps',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              date == null ? 'Saved set' : _fullDate(date),
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '1RM ${_number(oneRm)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  static List<_TrendPoint> _dailyBestPoints(List<Map<String, dynamic>> sets) {
    final daily = <DateTime, double>{};
    for (final set in sets) {
      final rawDate = set['completedAt']?.toString() ??
          set['sessionDate']?.toString() ??
          '';
      final date = DateTime.tryParse(rawDate);
      if (date == null) {
        continue;
      }
      final day = DateTime(date.year, date.month, date.day);
      final weight = (set['weight'] as num?)?.toDouble() ?? 0;
      final reps = (set['reps'] as num?)?.toInt() ?? 0;
      final value = LocalStore.estimatedOneRepMax(weight, reps);
      if (value > (daily[day] ?? 0)) {
        daily[day] = value;
      }
    }
    final entries = daily.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final trimmed =
        entries.length > 12 ? entries.sublist(entries.length - 12) : entries;
    return trimmed.map((entry) => _TrendPoint(entry.key, entry.value)).toList();
  }

  static String _number(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  static String _shortDate(DateTime date) => '${date.day}/${date.month}';

  static String _fullDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _TrendPoint {
  final DateTime date;
  final double value;
  const _TrendPoint(this.date, this.value);
}

class _TrendPainter extends CustomPainter {
  final List<double> values;

  const _TrendPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) {
      return;
    }
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = math.max(1.0, maxValue - minValue);
    final path = Path();
    final pointPaint = Paint()..color = AppColors.primary;
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : (size.width * i / (values.length - 1));
      final normalized = (values[i] - minValue) / range;
      final y = size.height - 18 - (normalized * (size.height - 36));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
    if (values.length > 1) {
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
