import 'package:flutter/widgets.dart';

/// Semantic colour family of a single [OctoTimelineItem] marker.
enum OctoTimelineVariant {
  /// Neutral grey marker — generic activity.
  standard,

  /// Accent blue marker — informational milestone (mention, review).
  accent,

  /// Green marker — positive completion (merged, deployed).
  success,

  /// Yellow marker — caution / warning state.
  attention,

  /// Red marker — destructive event (closed without merge, failed).
  danger,
}

/// Data describing one entry in [OctoTimeline].
///
/// Pure data — the corresponding render object is built by
/// [OctoTimeline] itself.
@immutable
class OctoTimelineItem {
  /// Leading glyph rendered inside the marker disc.
  final IconData icon;

  /// Primary one-line title text. Usually the verb + subject (e.g.
  /// `'Created branch feature/foo'`).
  final String title;

  /// Optional secondary text — timestamp, attribution, snippet.
  final String? subtitle;

  /// Optional rich content rendered below [title] / [subtitle]. Use to
  /// embed quoted text, diffs, or any non-text widget.
  final Widget? body;

  /// Marker colour family. See [OctoTimelineVariant].
  final OctoTimelineVariant variant;

  /// Accessibility label. Defaults to [title].
  final String? semanticLabel;

  /// Creates a timeline entry.
  const OctoTimelineItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.body,
    this.variant = OctoTimelineVariant.standard,
    this.semanticLabel,
  });
}
