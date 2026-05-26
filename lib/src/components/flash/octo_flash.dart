import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_icon.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Inline status banner (Primer "Flash"). Announces a transient result or
/// system state — successful save, validation error, info note.
///
/// `liveRegion: true` (ADR-0008) marks the banner so screen readers
/// announce it when it appears.
enum OctoFlashVariant { info, success, attention, danger }

/// 0.1.0 ships Flash WITHOUT a dismiss button. The close glyph would
/// require Material's `Icons.close`, which the design system explicitly
/// forbids (see ADR review, plan §24). Dismiss lands in 0.2 once
/// `octo_icons` provides a native close glyph.
class OctoFlash extends StatelessWidget {
  final String message;
  final OctoFlashVariant variant;
  final IconData? icon;

  const OctoFlash({
    super.key,
    required this.message,
    this.variant = OctoFlashVariant.info,
    this.icon,
  });

  ({Color background, Color border, Color foreground}) _resolveColors(OctoThemeData theme) {
    switch (variant) {
      case OctoFlashVariant.info:
        return (
          background: theme.colors.accent.subtle,
          border: theme.colors.accent.muted,
          foreground: theme.colors.accent.fg,
        );
      case OctoFlashVariant.success:
        return (
          background: theme.colors.success.subtle,
          border: theme.colors.success.muted,
          foreground: theme.colors.success.fg,
        );
      case OctoFlashVariant.attention:
        return (
          background: theme.colors.attention.subtle,
          border: theme.colors.attention.muted,
          foreground: theme.colors.attention.fg,
        );
      case OctoFlashVariant.danger:
        return (
          background: theme.colors.danger.subtle,
          border: theme.colors.danger.muted,
          foreground: theme.colors.danger.fg,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final colors = _resolveColors(theme);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.gap.lg,
          vertical: theme.spacing.gap.md,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(color: colors.border),
          borderRadius: radius,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              ExcludeSemantics(child: OctoIcon(icon!, color: colors.foreground)),
              SizedBox(width: theme.spacing.gap.md),
            ],
            Expanded(
              child: OctoText(
                message,
                kind: OctoTextKind.bodyEmphasis,
                color: colors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
