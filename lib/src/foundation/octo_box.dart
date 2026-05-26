import 'package:flutter/widgets.dart';

/// Thin layout primitive — a [Container] with a stable, opinionated API.
///
/// All theming (colour, radius, shadow) is passed in resolved form by the
/// caller; [OctoBox] itself does NOT read [OctoTheme] to keep the foundation
/// layer free of theme dependencies. Component widgets resolve theme tokens
/// at their level and pass concrete values down.
class OctoBox extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final AlignmentGeometry? alignment;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;

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
