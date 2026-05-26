import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Semantic colour family for an [OctoProgressBar] fill.
enum OctoProgressBarVariant {
  /// Generic progress — accent palette (Primer's default).
  accent,

  /// Positive-state progress — green palette (e.g. successful upload).
  success,

  /// Warning-state progress — yellow palette.
  attention,

  /// Destructive-state progress — red palette (e.g. quota exhausted).
  danger,
}

/// Bar thickness preset.
enum OctoProgressBarSize {
  /// 4 px hairline — fits next to dense list items / metadata rows.
  small,

  /// 8 px default bar — primary call-out usage.
  medium,
}

/// Linear progress indicator (Primer "ProgressBar").
///
/// Determinate when [value] is in `[0, 1]`. Pass `value: null` to render
/// an indeterminate sliding stripe — used for "we know it's working, we
/// don't know how long it'll take" states.
///
/// The indeterminate animation is suppressed automatically when
/// `MediaQuery.maybeDisableAnimationsOf(context) == true` (ADR-0008);
/// in that case the bar falls back to a static 50%-filled track to keep
/// the visual hint that something is in progress without burning frames.
class OctoProgressBar extends StatefulWidget {
  /// Progress in the closed interval `[0, 1]`. `null` → indeterminate.
  final double? value;

  /// Colour family for the fill. Track always uses `neutral.muted`.
  final OctoProgressBarVariant variant;

  /// Bar thickness. See [OctoProgressBarSize].
  final OctoProgressBarSize size;

  /// Optional accessibility label (e.g. `'Uploading attachments'`).
  final String? semanticLabel;

  /// Duration of one full indeterminate sweep.
  final Duration indeterminateDuration;

  /// Creates a linear progress bar.
  const OctoProgressBar({
    super.key,
    this.value,
    this.variant = OctoProgressBarVariant.accent,
    this.size = OctoProgressBarSize.medium,
    this.semanticLabel,
    this.indeterminateDuration = const Duration(milliseconds: 1400),
  }) : assert(
          value == null || (value >= 0 && value <= 1),
          'value must be null or within [0, 1]',
        );

  @override
  State<OctoProgressBar> createState() => _OctoProgressBarState();
}

class _OctoProgressBarState extends State<OctoProgressBar> with SingleTickerProviderStateMixin {
  static const double _indeterminateFraction = 0.35;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.indeterminateDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(OctoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.indeterminateDuration != widget.indeterminateDuration) {
      _controller.duration = widget.indeterminateDuration;
    }
    _syncAnimation();
  }

  void _syncAnimation() {
    final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final wantsAnimation = widget.value == null && !disable;
    if (wantsAnimation) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _height => switch (widget.size) {
        OctoProgressBarSize.small => 4,
        OctoProgressBarSize.medium => 8,
      };

  Color _resolveFillColor(OctoThemeData theme) {
    switch (widget.variant) {
      case OctoProgressBarVariant.accent:
        return theme.colors.accent.emphasis;
      case OctoProgressBarVariant.success:
        return theme.colors.success.emphasis;
      case OctoProgressBarVariant.attention:
        return theme.colors.attention.emphasis;
      case OctoProgressBarVariant.danger:
        return theme.colors.danger.emphasis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.full));
    final track = theme.colors.neutral.muted;
    final fill = _resolveFillColor(theme);
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final isDeterminate = widget.value != null;

    final semanticsValue = isDeterminate ? '${(widget.value! * 100).round()}%' : null;

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      value: semanticsValue,
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: _height,
          width: double.infinity,
          child: ColoredBox(
            color: track,
            child: isDeterminate
                ? _DeterminateFill(value: widget.value!, color: fill)
                : (disableAnimations
                    // Motion-reduce: bar still hints "in progress" with a
                    // static half-filled track instead of a sliding stripe.
                    ? _DeterminateFill(value: 0.5, color: fill)
                    : _IndeterminateFill(
                        controller: _controller,
                        color: fill,
                        fraction: _indeterminateFraction,
                      )),
          ),
        ),
      ),
    );
  }
}

class _DeterminateFill extends StatelessWidget {
  final double value;
  final Color color;

  const _DeterminateFill({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0, 1),
        heightFactor: 1,
        child: ColoredBox(color: color),
      ),
    );
  }
}

class _IndeterminateFill extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double fraction;

  const _IndeterminateFill({
    required this.controller,
    required this.color,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final segmentWidth = width * fraction;
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            // Sweep the segment from fully off-screen left to fully
            // off-screen right so the head / tail edges fade out at the
            // ends of the track instead of snapping.
            final t = controller.value;
            final position = -segmentWidth + (width + segmentWidth) * t;
            return Stack(
              children: [
                Positioned.fromRect(
                  rect: Rect.fromLTWH(position, 0, segmentWidth, constraints.maxHeight),
                  child: ColoredBox(color: color),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
