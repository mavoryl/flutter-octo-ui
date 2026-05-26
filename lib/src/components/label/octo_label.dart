import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Semantic colour of an [OctoLabel] pill.
///
/// `standard` is the neutral, low-emphasis variant. Other entries pull from
/// the matching status colour family (`accent`, `success`, ...) and use
/// `*.fg` for both the text and the border to match Primer Labels.
enum OctoLabelVariant { standard, accent, success, attention, danger }

/// Compact pill-shaped tag (Primer "Label"). Communicates classification —
/// e.g. PR status, issue area, severity — at a glance.
///
/// Reads colours from the enclosing [OctoTheme] based on [variant]. The pill
/// is outlined (border only, no fill) to match Primer's default Label style;
/// the subtle filled variant is deferred to a later milestone.
class OctoLabel extends StatelessWidget {
  final String text;
  final OctoLabelVariant variant;

  const OctoLabel(this.text, {super.key, this.variant = OctoLabelVariant.standard});

  ({Color border, Color fg}) _resolveColors(OctoThemeData theme) {
    switch (variant) {
      case OctoLabelVariant.standard:
        return (border: theme.colors.border.defaultColor, fg: theme.colors.fg.muted);
      case OctoLabelVariant.accent:
        return (border: theme.colors.accent.muted, fg: theme.colors.accent.fg);
      case OctoLabelVariant.success:
        return (border: theme.colors.success.muted, fg: theme.colors.success.fg);
      case OctoLabelVariant.attention:
        return (border: theme.colors.attention.muted, fg: theme.colors.attention.fg);
      case OctoLabelVariant.danger:
        return (border: theme.colors.danger.muted, fg: theme.colors.danger.fg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final colors = _resolveColors(theme);
    // Screen readers should announce the pill as a single unit, not nested
    // Container + Text nodes. MergeSemantics flattens descendant semantics
    // (the Text's auto-derived label) into one node.
    return MergeSemantics(
      child: _buildPill(theme, colors),
    );
  }

  Widget _buildPill(OctoThemeData theme, ({Color border, Color fg}) colors) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.gap.sm,
        vertical: theme.spacing.scale(1),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.all(Radius.circular(theme.radii.full)),
      ),
      child: OctoText(text, kind: OctoTextKind.labelSmall, color: colors.fg),
    );
  }
}
