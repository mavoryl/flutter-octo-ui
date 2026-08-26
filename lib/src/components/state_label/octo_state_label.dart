import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Semantic state of a PR / issue (Primer "StateLabel").
///
/// Mapping note: Primer's React kit uses a `done` palette (purple) for
/// the *merged* variant. `octo_ui` 0.5 ships success/attention/danger
/// only, so `merged` reuses the accent (blue) palette — close enough in
/// hue to remain glanceable. When a `done` token family lands the
/// mapping will switch automatically.
enum OctoStateLabelVariant {
  /// Open PR / issue — green pill with `git-pull-request` icon.
  open,

  /// Closed without merging — red pill with `issue-closed` icon.
  closed,

  /// Merged PR — accent (Primer uses purple/"done") with `git-merge`
  /// icon.
  merged,

  /// Draft PR — neutral muted pill with `git-pull-request-draft`.
  draft,

  /// Stale / awaiting attention — yellow pill with `git-pull-request`.
  attention,
}

/// Emphasis tier — controls whether the pill is filled (high emphasis)
/// or subtle-on-surface (low emphasis).
enum OctoStateLabelEmphasis {
  /// Filled pill with `.emphasis` background + onEmphasis foreground.
  /// Use this in the PR / issue header — the canonical Primer look.
  high,

  /// Subtle pill with `.subtle` background + variant foreground. Use
  /// inside dense lists where multiple chips compete for attention.
  low,
}

/// Status pill announcing the lifecycle state of a PR / issue.
///
/// Renders `[icon] [label]` inside a fully-rounded pill. The icon is
/// implied by [variant] but can be overridden via [icon]. The pill
/// honours [emphasis] — `high` filled (PR header), `low` subtle (list
/// items).
class OctoStateLabel extends StatelessWidget {
  /// Visible label text.
  final String label;

  /// Lifecycle state. Drives colours + default icon.
  final OctoStateLabelVariant variant;

  /// Filled vs. subtle. See [OctoStateLabelEmphasis].
  final OctoStateLabelEmphasis emphasis;

  /// Override the auto-picked leading icon.
  final IconData? icon;

  /// Accessibility label. Defaults to `label`.
  final String? semanticLabel;

  /// Creates a state pill.
  const OctoStateLabel({
    super.key,
    required this.label,
    required this.variant,
    this.emphasis = OctoStateLabelEmphasis.high,
    this.icon,
    this.semanticLabel,
  });

  IconData get _icon {
    if (icon != null) return icon!;
    switch (variant) {
      case OctoStateLabelVariant.open:
        return OctIcons.git_pull_request_16;
      case OctoStateLabelVariant.closed:
        return OctIcons.issue_closed_16;
      case OctoStateLabelVariant.merged:
        return OctIcons.git_merge_16;
      case OctoStateLabelVariant.draft:
        return OctIcons.git_pull_request_draft_16;
      case OctoStateLabelVariant.attention:
        return OctIcons.git_pull_request_16;
    }
  }

  ({Color background, Color foreground}) _resolveColors(OctoThemeData theme) {
    switch (emphasis) {
      case OctoStateLabelEmphasis.high:
        switch (variant) {
          case OctoStateLabelVariant.open:
            return (
              background: theme.colors.success.emphasis,
              foreground: theme.colors.fg.onEmphasis,
            );
          case OctoStateLabelVariant.closed:
            return (
              background: theme.colors.danger.emphasis,
              foreground: theme.colors.fg.onEmphasis,
            );
          case OctoStateLabelVariant.merged:
            return (
              background: theme.colors.accent.emphasis,
              foreground: theme.colors.fg.onEmphasis,
            );
          case OctoStateLabelVariant.draft:
            return (
              background: theme.colors.neutral.emphasis,
              foreground: theme.colors.fg.onEmphasis,
            );
          case OctoStateLabelVariant.attention:
            return (
              background: theme.colors.attention.emphasis,
              foreground: theme.colors.fg.onEmphasis,
            );
        }
      case OctoStateLabelEmphasis.low:
        switch (variant) {
          case OctoStateLabelVariant.open:
            return (
              background: theme.colors.success.subtle,
              foreground: theme.colors.success.fg,
            );
          case OctoStateLabelVariant.closed:
            return (
              background: theme.colors.danger.subtle,
              foreground: theme.colors.danger.fg,
            );
          case OctoStateLabelVariant.merged:
            return (
              background: theme.colors.accent.subtle,
              foreground: theme.colors.accent.fg,
            );
          case OctoStateLabelVariant.draft:
            return (
              background: theme.colors.neutral.subtle,
              foreground: theme.colors.fg.muted,
            );
          case OctoStateLabelVariant.attention:
            return (
              background: theme.colors.attention.subtle,
              foreground: theme.colors.attention.fg,
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final colors = _resolveColors(theme);
    final radius = BorderRadius.all(Radius.circular(theme.radii.full));

    return Semantics(
      container: true,
      label: semanticLabel ?? label,
      child: ExcludeSemantics(
        // The visible icon + text both feed into the parent Semantics
        // label via the default ?? label, so we silence their own
        // semantics to avoid screen readers announcing "M Merged".
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.background, borderRadius: radius),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.gap.sm,
              vertical: theme.spacing.scale(1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, size: 14, color: colors.foreground),
                SizedBox(width: theme.spacing.gap.xs),
                // Status pills sit in table cells, where the column decides
                // the width. Flexible lets the text ellipsize instead of
                // painting an overflow stripe over the layout.
                Flexible(
                  child: OctoText(
                    label,
                    kind: OctoTextKind.labelSmall,
                    color: colors.foreground,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
