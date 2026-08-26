import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Orientation of an [OctoDivider].
enum OctoDividerAxis {
  /// Horizontal hairline — separates stacked rows / sections.
  horizontal,

  /// Vertical hairline — separates inline items (toolbars, button groups).
  vertical,
}

/// Visual emphasis of an [OctoDivider]. Maps onto the
/// `theme.colors.border.{subtle,muted,defaultColor}` palette.
enum OctoDividerEmphasis {
  /// Faintest line — inset / well separators.
  subtle,

  /// Default quiet separator (Primer's preferred divider colour).
  muted,

  /// Stronger separator — section breaks between dense content blocks.
  strong,
}

/// Thin separator line between layout regions (Primer-style hairline).
///
/// Horizontal dividers fill their parent's main-axis space, vertical
/// dividers fill their parent's cross-axis space. Use [indent] /
/// [endIndent] to inset the line from its container's edges (matches
/// Material's `Divider` API).
///
/// ```dart
/// Column(
///   children: [
///     header,
///     const OctoDivider(),
///     body,
///   ],
/// )
/// ```
///
/// **Variants** — [OctoDividerEmphasis] picks the border tier:
/// `subtle` · `muted` · `strong`. [color] overrides it outright.
///
/// **States** — none; the divider is inert and never interactive.
///
/// **Accessibility** — a decorative line carries no semantics, so nothing is
/// exposed to screen readers. Use a labelled heading for structure a
/// screen-reader user needs to perceive; a divider alone does not convey it.
///
/// See also:
///
///  * [OctoDivider.vertical], for the cross-axis form.
class OctoDivider extends StatelessWidget {
  /// Layout direction. See [OctoDividerAxis].
  final OctoDividerAxis axis;

  /// Line thickness in logical pixels. Defaults to a 1 px hairline.
  final double thickness;

  /// Emphasis tier — selects the `theme.colors.border` shade.
  final OctoDividerEmphasis emphasis;

  /// Override the resolved colour. When non-null, [emphasis] is ignored.
  final Color? color;

  /// Inset from the leading edge (top for vertical, left/start for
  /// horizontal).
  final double indent;

  /// Inset from the trailing edge.
  final double endIndent;

  /// Creates a horizontal hairline divider.
  const OctoDivider({
    super.key,
    this.thickness = 1,
    this.emphasis = OctoDividerEmphasis.muted,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  }) : axis = OctoDividerAxis.horizontal;

  /// Creates a vertical hairline divider.
  const OctoDivider.vertical({
    super.key,
    this.thickness = 1,
    this.emphasis = OctoDividerEmphasis.muted,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  }) : axis = OctoDividerAxis.vertical;

  Color _resolveColor(OctoThemeData theme) {
    if (color != null) return color!;
    switch (emphasis) {
      case OctoDividerEmphasis.subtle:
        return theme.colors.border.subtle;
      case OctoDividerEmphasis.muted:
        return theme.colors.border.muted;
      case OctoDividerEmphasis.strong:
        return theme.colors.border.defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final resolved = _resolveColor(theme);

    // `Container` is the simplest way to anchor the line to both its
    // thickness and the available cross-axis space: `double.infinity` on
    // the cross axis is clamped to the parent's max, and the [margin]
    // contributes back to the outer size so the OctoDivider widget itself
    // still occupies the full cross-axis extent (callers can size against
    // the widget without worrying about indent).
    return ExcludeSemantics(
      child: switch (axis) {
        OctoDividerAxis.horizontal => Container(
            width: double.infinity,
            height: thickness,
            margin: EdgeInsetsDirectional.only(start: indent, end: endIndent),
            color: resolved,
          ),
        OctoDividerAxis.vertical => Container(
            width: thickness,
            height: double.infinity,
            margin: EdgeInsets.only(top: indent, bottom: endIndent),
            color: resolved,
          ),
      },
    );
  }
}
