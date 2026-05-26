import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Semantic text-style picker. Each entry maps to a field on
/// [OctoTypography] (e.g. `OctoTextKind.title` -> `theme.typography.title`).
enum OctoTextKind { body, bodySmall, bodyEmphasis, label, labelSmall, title, heading, code }

/// Themed text widget. Reads the [OctoTypography] from the enclosing
/// [OctoTheme] and applies it according to [kind].
///
/// For ad-hoc styles use [OctoText.styled] with a raw [TextStyle].
class OctoText extends StatelessWidget {
  final String data;
  final OctoTextKind kind;
  final TextStyle? styleOverride;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

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

  const OctoText.styled(
    this.data, {
    super.key,
    required TextStyle style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : kind = OctoTextKind.body,
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
