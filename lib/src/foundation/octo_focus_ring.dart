import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';

/// Keyboard-focus ring drawn as an outline stroke around [child] (ADR-0006).
///
/// Visibility rules:
///   * [enabled] is `true`,
///   * the nearest enclosing [Focus] reports `hasPrimaryFocus`,
///   * AND `FocusManager.instance.highlightMode` is
///     [FocusHighlightMode.traditional] — i.e. the user navigated by
///     keyboard, not mouse click.
///
/// The ring is painted via a [CustomPaint] in a non-clipping [Stack], so it
/// extends [offset] logical pixels outside the child bounds. If an ancestor
/// clips (`ClipRect`, `ListView` items), the ring will be cropped — for those
/// cases switch to `OctoFocusRing.overlay` (lands in 0.2; see ADR-0006).
class OctoFocusRing extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final BorderRadius? borderRadius;
  final Color? color;
  final double thickness;
  final double offset;

  const OctoFocusRing({
    super.key,
    required this.child,
    this.enabled = true,
    this.borderRadius,
    this.color,
    this.thickness = 2,
    this.offset = 2,
  });

  @override
  State<OctoFocusRing> createState() => _OctoFocusRingState();
}

class _OctoFocusRingState extends State<OctoFocusRing> {
  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusManagerChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusManagerChange);
    super.dispose();
  }

  void _onFocusManagerChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final focus = Focus.maybeOf(context);
    final hasFocus = focus?.hasPrimaryFocus ?? false;
    final mode = FocusManager.instance.highlightMode;
    final visible = widget.enabled && hasFocus && mode == FocusHighlightMode.traditional;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (visible)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _RingPainter(
                  borderRadius: widget.borderRadius ?? BorderRadius.zero,
                  color: widget.color ?? OctoTheme.of(context).colors.accent.fg,
                  thickness: widget.thickness,
                  offset: widget.offset,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color color;
  final double thickness;
  final double offset;

  _RingPainter({
    required this.borderRadius,
    required this.color,
    required this.thickness,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(-offset, -offset, size.width + offset * 2, size.height + offset * 2);
    final adjusted = BorderRadius.only(
      topLeft: Radius.elliptical(
        borderRadius.topLeft.x + offset,
        borderRadius.topLeft.y + offset,
      ),
      topRight: Radius.elliptical(
        borderRadius.topRight.x + offset,
        borderRadius.topRight.y + offset,
      ),
      bottomLeft: Radius.elliptical(
        borderRadius.bottomLeft.x + offset,
        borderRadius.bottomLeft.y + offset,
      ),
      bottomRight: Radius.elliptical(
        borderRadius.bottomRight.x + offset,
        borderRadius.bottomRight.y + offset,
      ),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawRRect(adjusted.toRRect(rect), paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.thickness != thickness ||
      oldDelegate.offset != offset ||
      oldDelegate.borderRadius != borderRadius;
}
