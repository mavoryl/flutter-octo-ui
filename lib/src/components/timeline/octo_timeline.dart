import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/timeline/octo_timeline_item.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Vertical activity feed (Primer "Timeline"). Each entry pairs a
/// circular marker on the leading edge with title / subtitle / body
/// content; a thin vertical rail connects consecutive markers so the
/// feed reads top-to-bottom.
///
/// Used for PR / issue activity, audit logs, deploy history — any
/// sequence of dated events where the chronology itself is part of
/// the information.
class OctoTimeline extends StatelessWidget {
  static const double _markerSize = 24;
  static const double _railWidth = 2;
  static const double _gap = 12;

  /// Entries in chronological order (top → bottom).
  final List<OctoTimelineItem> items;

  /// Creates a timeline.
  const OctoTimeline({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Semantics(
      container: true,
      label: 'Timeline',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            _TimelineRow(
              item: items[i],
              first: i == 0,
              last: i == items.length - 1,
              theme: theme,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final OctoTimelineItem item;
  final bool first;
  final bool last;
  final OctoThemeData theme;

  const _TimelineRow({
    required this.item,
    required this.first,
    required this.last,
    required this.theme,
  });

  Color _markerColor() {
    switch (item.variant) {
      case OctoTimelineVariant.standard:
        return theme.colors.neutral.emphasis;
      case OctoTimelineVariant.accent:
        return theme.colors.accent.emphasis;
      case OctoTimelineVariant.success:
        return theme.colors.success.emphasis;
      case OctoTimelineVariant.attention:
        return theme.colors.attention.emphasis;
      case OctoTimelineVariant.danger:
        return theme.colors.danger.emphasis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final markerColor = _markerColor();
    final railColor = theme.colors.border.muted;
    final bottomPadding = last ? 0.0 : theme.spacing.gap.md;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Semantics(
        container: true,
        label: item.semanticLabel ?? item.title,
        child: IntrinsicHeight(
          child: Row(
            // Stretch instead of start — start gives the marker column
            // loose height, so the inner Stack would shrink to the
            // marker disc (24 px) and the rail would only cover the
            // per-row bottom padding instead of the full row height.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: OctoTimeline._markerSize,
                child: Stack(
                  alignment: Alignment.topCenter,
                  // Allow the vertical rail to extend through the row's
                  // bottom padding into the next entry — otherwise the
                  // default Clip.hardEdge eats the negative `bottom`
                  // offset and the rail disappears between markers.
                  clipBehavior: Clip.none,
                  children: [
                    // Vertical rail behind the marker.
                    Positioned(
                      top: first ? OctoTimeline._markerSize / 2 : 0,
                      bottom: last
                          ? null
                          // Extend the rail below the marker through the
                          // bottom padding so it reaches the next entry.
                          : -bottomPadding,
                      height: last ? OctoTimeline._markerSize / 2 : null,
                      child: SizedBox(
                        width: OctoTimeline._railWidth,
                        child: ColoredBox(color: railColor),
                      ),
                    ),
                    // Marker disc.
                    Container(
                      width: OctoTimeline._markerSize,
                      height: OctoTimeline._markerSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        size: 12,
                        color: theme.colors.fg.onEmphasis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: OctoTimeline._gap),
              Expanded(
                child: Padding(
                  // Nudge the text down so it sits on the marker's
                  // optical baseline.
                  padding: EdgeInsets.only(top: theme.spacing.scale(1)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OctoText(
                        item.title,
                        kind: OctoTextKind.bodyEmphasis,
                        color: theme.colors.fg.defaultColor,
                      ),
                      if (item.subtitle != null) ...[
                        SizedBox(height: theme.spacing.scale(1)),
                        OctoText(
                          item.subtitle!,
                          kind: OctoTextKind.bodySmall,
                          color: theme.colors.fg.muted,
                        ),
                      ],
                      if (item.body != null) ...[
                        SizedBox(height: theme.spacing.gap.sm),
                        item.body!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
