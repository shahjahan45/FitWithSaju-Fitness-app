import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../more/more_screen.dart';
import '../progress/progress_screen.dart';
import '../workout/workout_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    WorkoutScreen(),
    ExploreScreen(),
    ProgressScreen(),
    MoreScreen(),
  ];

  final destinations = const [
    (Icons.home_rounded, 'Home'),
    (Icons.fitness_center_rounded, 'Workout'),
    (Icons.explore_rounded, 'Explore'),
    (Icons.insights_rounded, 'Progress'),
    (Icons.grid_view_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(index),
          child: pages[index],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: .08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List.generate(destinations.length, (i) {
              final selected = i == index;
              final item = destinations[i];
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => index = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: [Color(0xFFFFF1E4), Color(0xFFEAF6FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.12 : 1,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            item.$1,
                            color: selected ? AppColors.primary : AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected ? AppColors.text : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
