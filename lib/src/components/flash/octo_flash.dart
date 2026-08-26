import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/components/button/octo_button.dart';
import 'package:octo_ui/src/components/icon_button/octo_icon_button.dart';
import 'package:octo_ui/src/foundation/octo_icon.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Inline status banner (Primer "Flash"). Announces a transient result or
/// system state — successful save, validation error, info note.
///
/// `liveRegion: true` (ADR-0008) marks the banner so screen readers
/// announce it when it appears.
enum OctoFlashVariant {
  /// Neutral informational message; uses the accent palette.
  info,

  /// Positive outcome — save succeeded, action confirmed.
  success,

  /// Non-blocking warning that needs the user's attention.
  attention,

  /// Error or destructive consequence.
  danger,
}

/// Themed status banner.
///
/// When [onDismiss] is set, a trailing close button (Octicons `x_16`) is
/// rendered after the message; tapping it invokes the callback. The host
/// is expected to remove the banner from the tree in response.
///
/// ```dart
/// OctoFlash(
///   message: 'Deploy finished in 42s.',
///   variant: OctoFlashVariant.success,
///   onDismiss: _hide,
/// )
/// ```
///
/// **Variants** — [OctoFlashVariant]: `info` · `success` · `attention` ·
/// `danger`. Each supplies its own default [icon].
///
/// **States** — [onDismiss] adds a close button that tracks hover and focus.
/// The banner itself is inert.
///
/// **Accessibility** — the banner is a live region, so a screen reader announces
/// the message when it appears without the user having to go looking for it. That
/// also means it should carry a *change* in state, not static page text — inline
/// prose in a live region gets re-announced on every rebuild.
///
/// See also:
///
///  * [OctoToast], for a transient notification that dismisses itself.
class OctoFlash extends StatelessWidget {
  /// Body text shown in the banner.
  final String message;

  /// Status colour family. See [OctoFlashVariant].
  final OctoFlashVariant variant;

  /// Optional leading glyph. Decorative — its semantics are excluded.
  final IconData? icon;

  /// Tap handler for the dismiss button. When `null`, no dismiss is shown.
  final VoidCallback? onDismiss;

  /// Accessibility label for the dismiss button. Defaults to `'Dismiss'`.
  final String dismissSemanticLabel;

  /// Creates a status banner.
  const OctoFlash({
    super.key,
    required this.message,
    this.variant = OctoFlashVariant.info,
    this.icon,
    this.onDismiss,
    this.dismissSemanticLabel = 'Dismiss',
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
            if (onDismiss != null) ...[
              SizedBox(width: theme.spacing.gap.sm),
              OctoIconButton(
                icon: OctIcons.x_16,
                onPressed: onDismiss,
                variant: OctoButtonVariant.invisible,
                size: OctoButtonSize.small,
                semanticLabel: dismissSemanticLabel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
