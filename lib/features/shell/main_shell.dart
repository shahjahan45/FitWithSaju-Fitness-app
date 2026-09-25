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

  final items = const [
    _NavItemData(Icons.home_rounded, 'Home'),
    _NavItemData(Icons.fitness_center_rounded, 'Workout'),
    _NavItemData(Icons.explore_rounded, 'Explore'),
    _NavItemData(Icons.auto_graph_rounded, 'Progress'),
    _NavItemData(Icons.grid_view_rounded, 'More'),
  ];

  void _go(int value) {
    if (value == index) return;
    setState(() => index = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(.018, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(index),
          child: pages[index],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: _SimpleBottomBar(
          selectedIndex: index,
          items: items,
          onTap: _go,
        ),
      ),
    );
  }
}

class _SimpleBottomBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItemData> items;
  final ValueChanged<int> onTap;

  const _SimpleBottomBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFE7EDF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1420).withOpacity(.08),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = selectedIndex == i;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(21),
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                height: 64,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primarySoft.withOpacity(.82)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      scale: selected ? 1.10 : 1,
                      child: Icon(
                        items[i].icon,
                        size: 23,
                        color: selected ? AppColors.primary : AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: 10,
                        height: 1,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected ? AppColors.text : AppColors.muted,
                      ),
                      child: Text(
                        items[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}
