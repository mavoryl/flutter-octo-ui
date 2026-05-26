import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';

/// Three canonical icon sizes — Octicons ship in 12 / 16 / 24.
enum OctoIconSize {
  /// 12 px — dense inline glyphs.
  small,

  /// 16 px — default for buttons, labels, list rows.
  medium,

  /// 24 px — headline / hero icons.
  large,
}

/// Themed icon. Defaults to size 16 (`OctoIconSize.medium`) and to
/// `theme.colors.fg.defaultColor` when no explicit colour is given.
///
/// Decorative icons should pass `semanticLabel: null` AND be wrapped in
/// [ExcludeSemantics] at the call site. Required [semanticLabel] is enforced
/// by [OctoIconButton] (see ADR-0008) — bare [OctoIcon] is the lower-level
/// primitive without a11y assertions.
class OctoIcon extends StatelessWidget {
  /// Glyph to render.
  final IconData icon;

  /// Canonical size bucket. See [OctoIconSize].
  final OctoIconSize size;

  /// Overrides [size] with an explicit pixel value (set via [OctoIcon.sized]).
  final double? customSize;

  /// Stroke colour. Defaults to `theme.colors.fg.defaultColor`.
  final Color? color;

  /// Accessibility label. `null` marks the icon as decorative.
  final String? semanticLabel;

  /// Creates a themed icon sized by [OctoIconSize].
  const OctoIcon(
    this.icon, {
    super.key,
    this.size = OctoIconSize.medium,
    this.color,
    this.semanticLabel,
  }) : customSize = null;

  /// Creates a themed icon with an explicit pixel size.
  const OctoIcon.sized(
    this.icon, {
    super.key,
    required double size,
    this.color,
    this.semanticLabel,
  })  : size = OctoIconSize.medium,
        customSize = size;

  double get _sizeValue =>
      customSize ??
      switch (size) {
        OctoIconSize.small => 12,
        OctoIconSize.medium => 16,
        OctoIconSize.large => 24,
      };

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Icon(
      icon,
      size: _sizeValue,
      color: color ?? theme.colors.fg.defaultColor,
      semanticLabel: semanticLabel,
    );
  }
}
