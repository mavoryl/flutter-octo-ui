import 'package:flutter/widgets.dart';

/// Thin layout primitive — a [Container] with a stable, opinionated API.
///
/// All theming (colour, radius, shadow) is passed in resolved form by the
/// caller; [OctoBox] itself does NOT read [OctoTheme] to keep the foundation
/// layer free of theme dependencies. Component widgets resolve theme tokens
/// at their level and pass concrete values down.
class OctoBox extends StatelessWidget {
  /// Optional content rendered inside the box.
  final Widget? child;

  /// Inner spacing between the box edge and the [child].
  final EdgeInsetsGeometry? padding;

  /// Outer spacing around the box.
  final EdgeInsetsGeometry? margin;

  /// Positions the [child] within the available space.
  final AlignmentGeometry? alignment;

  /// Background fill.
  final Color? color;

  /// Corner rounding for the background and border.
  final BorderRadiusGeometry? borderRadius;

  /// Optional border. Caller resolves the stroke colour from theme.
  final BoxBorder? border;

  /// Drop shadows. Caller resolves elevation from `theme.shadows`.
  final List<BoxShadow>? shadows;

  /// Fixed width. `null` means hug content.
  final double? width;

  /// Fixed height. `null` means hug content.
  final double? height;

  /// Creates a layout primitive with optional decoration.
  const OctoBox({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.alignment,
    this.color,
    this.borderRadius,
    this.border,
    this.shadows,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final hasDecoration =
        color != null || borderRadius != null || border != null || shadows != null;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: hasDecoration
          ? BoxDecoration(
              color: color,
              borderRadius: borderRadius,
              border: border,
              boxShadow: shadows,
            )
          : null,
      child: child,
    );
  }
}
