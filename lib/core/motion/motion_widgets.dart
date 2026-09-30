import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_motion.dart';

/// Calm entrance motion for sections/cards.
class MotionReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;
  final double offsetX;
  final Duration duration;

  const MotionReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 14,
    this.offsetX = 0,
    this.duration = AppMotion.sectionReveal,
  });

  @override
  State<MotionReveal> createState() => _MotionRevealState();
}

class _MotionRevealState extends State<MotionReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.value > 0 || _delayTimer != null) {
      return;
    }
    if (!TickerMode.valuesOf(context).enabled) {
      return;
    }
    if (AppMotion.reducedMotion(context)) {
      _controller.value = 1;
      return;
    }
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              widget.offsetX * (1 - value),
              widget.offsetY * (1 - value),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Reusable restrained press feedback for cards and buttons.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.pressedScale = .975,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = AppMotion.reducedMotion(context);
    if (_reduceMotion && _pressed) {
      _pressed = false;
    }
  }

  void _setPressed(bool value) {
    if (!mounted || _pressed == value || _reduceMotion) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? widget.pressedScale : 1,
      duration: AppMotion.micro,
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
          onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
          onTapUp: widget.onTap == null
              ? null
              : (_) {
                  // Only mutate this widget's local pressed state here.
                  // Navigation callbacks run through onTap after the gesture
                  // completes, so inherited state is never read during release.
                  _setPressed(false);
                },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Subtle ambient motion intended for a single hero/primary card.
class BreathingGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final BorderRadius borderRadius;

  const BreathingGlow({
    super.key,
    required this.child,
    this.color = AppColors.primary,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.ambient,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    if (AppMotion.reducedMotion(context) || !tickerEnabled) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reducedMotion(context)) {
      return Material(
        type: MaterialType.transparency,
        child: widget.child,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: .08 + (.06 * t)),
                blurRadius: 20 + (8 * t),
                spreadRadius: .5 + (1.5 * t),
                offset: Offset(0, 9 + (3 * t)),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: child,
          ),
        );
      },
    );
  }
}

/// Count-up text for metrics. Falls back to the final value for reduced motion.
class AnimatedNumberText extends StatelessWidget {
  final double value;
  final String Function(double value) formatter;
  final TextStyle? style;
  final Duration duration;

  const AnimatedNumberText({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reducedMotion(context)) {
      return Text(formatter(value), style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(formatter(animatedValue), style: style);
      },
    );
  }
}

class AnimatedVerticalBar extends StatelessWidget {
  final double height;
  final double width;
  final Decoration decoration;
  final Duration duration;

  const AnimatedVerticalBar({
    super.key,
    required this.height,
    required this.decoration,
    this.width = double.infinity,
    this.duration = AppMotion.chartReveal,
  });

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reducedMotion(context)) {
      return Container(width: width, height: height, decoration: decoration);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: height),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedHeight, _) {
        return Container(
          width: width,
          height: animatedHeight,
          decoration: decoration,
        );
      },
    );
  }
}

class AnimatedCheckBurst extends StatefulWidget {
  final bool active;
  final double size;
  final Color color;

  const AnimatedCheckBurst({
    super.key,
    required this.active,
    this.size = 44,
    this.color = AppColors.primary,
  });

  @override
  State<AnimatedCheckBurst> createState() => _AnimatedCheckBurstState();
}

class _AnimatedCheckBurstState extends State<AnimatedCheckBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      value: widget.active ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedCheckBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      if (widget.active) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reducedMotion(context)) {
      return Icon(
        widget.active ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: widget.color,
        size: widget.size,
      );
    }
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: Icon(
        Icons.check_circle_rounded,
        color: widget.color,
        size: widget.size,
      ),
    );
  }
}

class AnimatedLinearProgress extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double minHeight;
  final BorderRadius borderRadius;
  final Duration duration;

  const AnimatedLinearProgress({
    super.key,
    required this.value,
    required this.color,
    required this.backgroundColor,
    this.minHeight = 8,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.duration = const Duration(milliseconds: 420),
  });

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0).toDouble();
    if (AppMotion.reducedMotion(context)) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: LinearProgressIndicator(
          value: target,
          minHeight: minHeight,
          color: color,
          backgroundColor: backgroundColor,
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: minHeight,
            color: color,
            backgroundColor: backgroundColor,
          ),
        );
      },
    );
  }
}
