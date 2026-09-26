import 'dart:ui';

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
  final PageController _pageController = PageController();
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _go(int value) {
    if (value == index) return;

    _pageController.animateToPage(
      value,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        physics: const PageScrollPhysics(),
        onPageChanged: (value) {
          if (value == index) return;
          setState(() => index = value);
        },
        itemBuilder: (context, pageIndex) {
          return _AnimatedPage(
            index: pageIndex,
            currentIndex: index,
            child: pages[pageIndex],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: _GlassBottomBar(
          selectedIndex: index,
          items: items,
          onTap: _go,
        ),
      ),
    );
  }
}

class _AnimatedPage extends StatelessWidget {
  final int index;
  final int currentIndex;
  final Widget child;

  const _AnimatedPage({
    required this.index,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final distance = (index - currentIndex).abs();
    final isCurrent = distance == 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .92, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: isCurrent ? value : .92,
          child: Transform.scale(
            scale: isCurrent ? .985 + (.015 * value) : .985,
            child: child,
          ),
        );
      },
    );
  }
}

class _GlassBottomBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItemData> items;
  final ValueChanged<int> onTap;

  const _GlassBottomBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 78,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: .96),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B1420).withValues(alpha: .10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 430),
                    curve: Curves.easeOutBack,
                    left: (selectedIndex * itemWidth) + 2,
                    top: 1,
                    width: itemWidth - 4,
                    height: 66,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF9DDA31),
                            Color(0xFF76B900),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      items.length,
                      (itemIndex) => Expanded(
                        child: _NavButton(
                          data: items[itemIndex],
                          selected: selectedIndex == itemIndex,
                          onTap: () => onTap(itemIndex),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: pressed ? .91 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: widget.selected ? 1.08 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Icon(
                  widget.data.icon,
                  size: widget.selected ? 25 : 23,
                  color: widget.selected ? Colors.white : AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1,
                  fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w600,
                  color: widget.selected ? Colors.white : AppColors.muted,
                ),
                child: Text(
                  widget.data.label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}
