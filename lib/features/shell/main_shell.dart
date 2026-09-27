import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/motion/app_motion.dart';
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

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _contentController;
  int index = 0;
  int _direction = 1;

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
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: AppMotion.mainNavigation,
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contentController.duration = AppMotion.duration(
      context,
      AppMotion.mainNavigation,
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _go(int value) {
    if (value == index) {
      return;
    }

    _contentController.stop();
    _direction = value > index ? 1 : -1;
    setState(() => index = value);
    _contentController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reducedMotion(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _contentController,
        builder: (context, _) {
          final t = AppMotion.enterCurve.transform(_contentController.value);
          final rtlMultiplier =
              Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
          final dx = reduceMotion
              ? 0.0
              : (1 - t) *
                  _direction *
                  rtlMultiplier *
                  AppMotion.mainNavigationSlide;
          final opacity = reduceMotion ? 1.0 : .90 + (.10 * t);

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: IndexedStack(
                index: index,
                sizing: StackFit.expand,
                children: List.generate(
                  pages.length,
                  (pageIndex) {
                    final active = pageIndex == index;
                    return KeyedSubtree(
                      key: ValueKey('main-page-$pageIndex'),
                      child: TickerMode(
                        enabled: active,
                        child: ExcludeSemantics(
                          excluding: !active,
                          child: ExcludeFocus(
                            excluding: !active,
                            child: IgnorePointer(
                              ignoring: !active,
                              child: pages[pageIndex],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
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
    final reduceMotion = AppMotion.reducedMotion(context);
    final animationDuration = reduceMotion
        ? Duration.zero
        : AppMotion.mainNavigation;

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
                  AnimatedPositionedDirectional(
                    duration: animationDuration,
                    curve: AppMotion.indicatorCurve,
                    start: (selectedIndex * itemWidth) + 2,
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
                            color: AppColors.primary.withValues(alpha: .24),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
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
                          key: ValueKey('nav-${items[itemIndex].label.toLowerCase()}'),
                          data: items[itemIndex],
                          selected: selectedIndex == itemIndex,
                          animationDuration: animationDuration,
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
  final Duration animationDuration;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.data,
    required this.selected,
    required this.animationDuration,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reducedMotion(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: reduceMotion ? 1 : (pressed ? .96 : 1),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: reduceMotion ? 1 : (widget.selected ? 1.06 : 1),
                duration: widget.animationDuration,
                curve: AppMotion.indicatorCurve,
                child: Icon(
                  widget.data.icon,
                  size: widget.selected ? 25 : 23,
                  color: widget.selected ? Colors.white : AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: widget.animationDuration,
                curve: AppMotion.indicatorCurve,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1,
                  fontWeight:
                      widget.selected ? FontWeight.w800 : FontWeight.w600,
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
