import 'package:flutter/widgets.dart';

/// Data describing one row in [OctoSideNav].
///
/// Pure data — the corresponding render object is built by
/// [OctoSideNav] itself.
@immutable
class OctoSideNavItem {
  /// Visible row text.
  final String label;

  /// Optional leading widget (typically an icon).
  final Widget? icon;

  /// Optional trailing widget — counter pills, status indicators.
  final Widget? trailing;

  /// Accessibility label. Defaults to [label] when omitted.
  final String? semanticLabel;

  /// Creates a sidebar nav item.
  const OctoSideNavItem({
    required this.label,
    this.icon,
    this.trailing,
    this.semanticLabel,
  });
}
