import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/components/button/octo_button.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Single segment in an [OctoBreadcrumbs] trail.
@immutable
class OctoBreadcrumbItem {
  /// Visible segment text.
  final String label;

  /// Tap handler. `null` renders the segment as the non-interactive
  /// "current" crumb (typical for the last one).
  final VoidCallback? onPressed;

  /// Accessibility label. Defaults to [label].
  final String? semanticLabel;

  /// Creates a breadcrumb segment.
  const OctoBreadcrumbItem({
    required this.label,
    this.onPressed,
    this.semanticLabel,
  });
}

/// Horizontal navigation trail (Primer "Breadcrumbs").
///
/// Renders [items] left to right with a thin chevron between each pair.
/// The last item is conventionally non-interactive (the current page) —
/// pass `onPressed: null` to keep it as plain text without a button
/// affordance. Earlier items are clickable `OctoButton`s (`invisible`
/// variant) so they pick up hover / focus / pressed feedback for free.
class OctoBreadcrumbs extends StatelessWidget {
  /// Segments rendered left → right.
  final List<OctoBreadcrumbItem> items;

  /// Creates a breadcrumbs trail.
  const OctoBreadcrumbs({super.key, required this.items})
      : assert(items.length > 0, 'at least one item is required');

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing.gap.xs),
            child: ExcludeSemantics(
              child: Icon(
                OctIcons.chevron_right_16,
                size: 12,
                color: theme.colors.fg.muted,
              ),
            ),
          ),
        );
      }
      final item = items[i];
      final isCurrent = item.onPressed == null;
      if (isCurrent) {
        children.add(
          Semantics(
            label: item.semanticLabel ?? item.label,
            child: OctoText(item.label, color: theme.colors.fg.defaultColor),
          ),
        );
      } else {
        children.add(
          OctoButton.label(
            item.label,
            onPressed: item.onPressed,
            variant: OctoButtonVariant.invisible,
          ),
        );
      }
    }
    return Semantics(
      container: true,
      label: 'Breadcrumb',
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
