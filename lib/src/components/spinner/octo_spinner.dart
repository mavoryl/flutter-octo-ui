import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';

/// Size preset for an [OctoSpinner].
enum OctoSpinnerSize {
  /// 16 logical pixels — inline with body text.
  small,

  /// 24 logical pixels — default; pairs with button rows.
  medium,

  /// 40 logical pixels — full-screen loading placeholder.
  large,
}

/// Circular indeterminate loading indicator (Primer "Spinner").
///
/// Draws a 270° arc that rotates continuously. The bar uses
/// [theme.colors.fg.muted] by default; the remaining 90° gap reveals
/// the surface underneath. When
/// `MediaQuery.maybeDisableAnimationsOf(context) == true` the spinner
/// freezes at a deterministic angle so motion-reduce users still see
/// the loading indication without continuous motion (ADR-0008).
class OctoSpinner extends StatefulWidget {
  /// Diameter preset. See [OctoSpinnerSize].
  final OctoSpinnerSize size;

  /// Override the bar colour. Falls back to `theme.colors.fg.muted`.
  final Color? color;

  /// Override the bar thickness. Defaults to `size / 8`.
  final double? strokeWidth;

  /// Duration of one full rotation.
  final Duration duration;

  /// Accessibility label. Defaults to `'Loading'`.
  final String semanticLabel;

  /// Creates a spinner.
  const OctoSpinner({
    super.key,
    this.size = OctoSpinnerSize.medium,
    this.color,
    this.strokeWidth,
    this.duration = const Duration(milliseconds: 900),
    this.semanticLabel = 'Loading',
  });

  @override
  State<OctoSpinner> createState() => _OctoSpinnerState();
}

class _OctoSpinnerState extends State<OctoSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(OctoSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    _syncAnimation();
  }

  void _syncAnimation() {
    final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disable) {
      _controller.stop();
      // Park at a recognisable angle (a quarter turn) so the static
      // shape still reads as a spinner, not a broken ring.
      _controller.value = 0.25;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _diameter => switch (widget.size) {
        OctoSpinnerSize.small => 16,
        OctoSpinnerSize.medium => 24,
        OctoSpinnerSize.large => 40,
      };

  double get _strokeWidth => widget.strokeWidth ?? _diameter / 8;

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final color = widget.color ?? theme.colors.fg.muted;

    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: SizedBox.square(
        dimension: _diameter,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: _SpinnerPainter(
              progress: _controller.value,
              color: color,
              strokeWidth: _strokeWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  static const double _sweep = 3 * math.pi / 2; // 270°

  final double progress;
  final Color color;
  final double strokeWidth;

  _SpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);
    final startAngle = progress * 2 * math.pi - math.pi / 2;
    canvas.drawArc(arcRect, startAngle, _sweep, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.progress != progress || old.color != color || old.strokeWidth != strokeWidth;
}
