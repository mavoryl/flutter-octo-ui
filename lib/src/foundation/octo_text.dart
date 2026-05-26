import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Semantic text-style picker. Each entry maps to a field on
/// [OctoTypography] (e.g. `OctoTextKind.title` -> `theme.typography.title`).
enum OctoTextKind {
  /// 14/regular — default reading text.
  body,

  /// 12/regular — secondary copy and helper text.
  bodySmall,

  /// 14/semibold — emphasised body, button labels.
  bodyEmphasis,

  /// 12/medium — form labels, metadata.
  label,

  /// 10/medium — counters, pills, micro-labels.
  labelSmall,

  /// 16/semibold — section titles.
  title,

  /// 20/semibold — page-level headings.
  heading,

  /// Monospaced — inline code and code blocks.
  code,
}

/// Themed text widget. Reads the [OctoTypography] from the enclosing
/// [OctoTheme] and applies it according to [kind].
///
/// For ad-hoc styles use [OctoText.styled] with a raw [TextStyle].
class OctoText extends StatelessWidget {
  /// Text to render.
  final String data;

  /// Semantic style key. See [OctoTextKind].
  final OctoTextKind kind;

  /// Explicit style — bypasses [kind] resolution. Set via [OctoText.styled].
  final TextStyle? styleOverride;

  /// Foreground override. Defaults to `theme.colors.fg.defaultColor`.
  final Color? color;

  /// Horizontal alignment inside the line box.
  final TextAlign? textAlign;

  /// Maximum visible line count before [overflow] applies.
  final int? maxLines;

  /// Overflow behaviour when content exceeds [maxLines].
  final TextOverflow? overflow;

  /// Override of the text used for accessibility.
  final String? semanticsLabel;

  /// Creates a themed text widget with a semantic [kind].
  const OctoText(
    this.data, {
    super.key,
    this.kind = OctoTextKind.body,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : styleOverride = null;

  /// Creates a text widget with a raw [TextStyle] — escape hatch.
  const OctoText.styled(
    this.data, {
    super.key,
    required TextStyle style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  })  : kind = OctoTextKind.body,
        styleOverride = style;

  TextStyle _resolve(OctoThemeData theme) {
    if (styleOverride != null) return styleOverride!;
    return switch (kind) {
      OctoTextKind.body => theme.typography.body,
      OctoTextKind.bodySmall => theme.typography.bodySmall,
      OctoTextKind.bodyEmphasis => theme.typography.bodyEmphasis,
      OctoTextKind.label => theme.typography.label,
      OctoTextKind.labelSmall => theme.typography.labelSmall,
      OctoTextKind.title => theme.typography.title,
      OctoTextKind.heading => theme.typography.heading,
      OctoTextKind.code => theme.typography.code,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final base = _resolve(theme);
    final effectiveColor = color ?? theme.colors.fg.defaultColor;
    return Text(
      data,
      style: base.copyWith(color: effectiveColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
    );
  }
}
