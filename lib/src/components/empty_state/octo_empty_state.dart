import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_icon.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Placeholder for a surface with nothing to show yet (Primer
/// "Blankslate") — an empty issue list, a table with no matching rows, a
/// dashboard before its first data point.
///
/// Centred column: optional [icon], [title], optional [description], then
/// [actions]. The title is announced as a header so screen-reader users
/// land on it when they enter the region; the icon is decorative and kept
/// out of the semantics tree.
///
/// Pass ready-made widgets in [actions] — typically one or two
/// `OctoButton`s. Their order is the reading order.
class OctoEmptyState extends StatelessWidget {
  /// Headline explaining what is missing. Announced as a header.
  final String title;

  /// Optional second line — what the surface is for, or how to fill it.
  final String? description;

  /// Optional decorative glyph above the title.
  final IconData? icon;

  /// Calls to action rendered below the text. Wrapped, so a narrow
  /// viewport pushes the second action onto its own line.
  final List<Widget> actions;

  /// Creates an empty-state placeholder.
  const OctoEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);

    return Semantics(
      container: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            ExcludeSemantics(
              child: OctoIcon(
                icon!,
                size: OctoIconSize.large,
                color: theme.colors.fg.muted,
              ),
            ),
            SizedBox(height: theme.spacing.gap.lg),
          ],
          Semantics(
            header: true,
            child: OctoText(title, kind: OctoTextKind.title, textAlign: TextAlign.center),
          ),
          if (description != null) ...[
            SizedBox(height: theme.spacing.gap.sm),
            OctoText(
              description!,
              color: theme.colors.fg.muted,
              textAlign: TextAlign.center,
            ),
          ],
          if (actions.isNotEmpty) ...[
            SizedBox(height: theme.spacing.gap.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: theme.spacing.gap.md,
              runSpacing: theme.spacing.gap.sm,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}
