import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';

/// Block-shaped loading placeholder (Primer "Skeleton").
///
/// Renders a `neutral.muted` box that gently fades to `neutral.subtle`
/// and back, telegraphing that real content is on its way. The animation
/// is automatically suppressed when
/// `MediaQuery.maybeDisableAnimationsOf(context) == true` (ADR-0008).
///
/// Three common shapes ship as helpers:
///   * [OctoSkeletonText] — N text lines, last one shortened.
///   * [OctoSkeletonAvatar] — circular avatar placeholder.
///   * [OctoSkeleton] — generic block; pass [width] / [height] /
///     [borderRadius] explicitly.
class OctoSkeleton extends StatefulWidget {
  /// Block width. `null` means hug the parent.
  final double? width;

  /// Block height in logical pixels.
  final double height;

  /// Corner rounding. Defaults to `theme.radii.small`.
  final BorderRadius? borderRadius;

  /// Pulse duration. One full fade-out-then-back cycle takes
  /// `2 × duration`.
  final Duration duration;

  /// Creates a generic skeleton block.
  const OctoSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<OctoSkeleton> createState() => _OctoSkeletonState();
}

class _OctoSkeletonState extends State<OctoSkeleton> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(OctoSkeleton oldWidget) {
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
    final theme = OctoTheme.of(context);
    final radius = widget.borderRadius ?? BorderRadius.all(Radius.circular(theme.radii.small));
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final baseColor = theme.colors.neutral.muted;
    final lightColor = theme.colors.neutral.subtle;

    final box = SizedBox(width: widget.width, height: widget.height);

    if (disableAnimations) {
      return ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(color: baseColor, borderRadius: radius),
          child: box,
        ),
      );
    }
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final color = Color.lerp(baseColor, lightColor, _controller.value)!;
          return DecoratedBox(
            decoration: BoxDecoration(color: color, borderRadius: radius),
            child: box,
          );
        },
      ),
    );
  }
}

/// Multi-line text placeholder built on top of [OctoSkeleton]. The last
/// line is shortened to look more like real prose.
class OctoSkeletonText extends StatelessWidget {
  /// Number of lines to render.
  final int lines;

  /// Optional explicit width for each line.
  final double? width;

  /// Creates a text-shaped skeleton.
  const OctoSkeletonText({super.key, this.lines = 3, this.width})
      : assert(lines > 0, 'lines must be positive');

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final body = theme.typography.body;
    final fontSize = body.fontSize ?? 14;
    final height = body.height ?? 1.4;
    final lineHeight = fontSize * height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lines; i++) ...[
          if (i > 0) SizedBox(height: theme.spacing.gap.sm),
          OctoSkeleton(
            width: i == lines - 1 && width != null ? width! * 0.6 : width,
            height: fontSize,
          ),
          // Padding under each line to approximate body line-height
          // without inflating the skeleton itself.
          if (i < lines - 1) SizedBox(height: lineHeight - fontSize),
        ],
      ],
    );
  }
}

/// Circular avatar placeholder.
class OctoSkeletonAvatar extends StatelessWidget {
  /// Square diameter.
  final double size;

  /// Creates a circular avatar skeleton with the given [size].
  const OctoSkeletonAvatar({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return OctoSkeleton(
      width: size,
      height: size,
      borderRadius: BorderRadius.all(Radius.circular(size)),
    );
  }
}
