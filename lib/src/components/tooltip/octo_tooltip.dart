import 'package:flutter/material.dart' show Tooltip, TooltipTriggerMode;
import 'package:flutter/widgets.dart';

/// Hover / long-press text tooltip.
///
/// Thin wrapper over Material's [Tooltip] — the heavy lifting (showing on
/// hover after a delay, on long press for touch, hiding on exit, smart
/// edge-flip, accessibility announcement) is already correct in Material.
/// What we control is the visual: padding, radius, colours, typography —
/// all driven by the `TooltipThemeData` that
/// `OctoThemeData.toMaterialTheme()` installs (ADR-0004).
///
/// ```dart
/// OctoTooltip(
///   message: 'Delete branch',
///   child: OctoIconButton(
///     icon: OctIcons.trash_16,
///     semanticLabel: 'Delete branch',
///     onPressed: _delete,
///   ),
/// )
/// ```
///
/// **Variants** — [triggerMode] follows Flutter's `TooltipTriggerMode`; the
/// default shows on hover for pointers and on long-press for touch.
///
/// **States** — the tooltip fades in after the platform's usual delay and out on
/// exit; it holds still when the platform asks for reduced motion.
///
/// **Accessibility** — a tooltip is a hint for sighted pointer users, not an
/// accessible name. Screen readers may never surface it, so give the child its
/// own label — as in the sample above, where the icon button repeats the text in
/// [OctoIconButton.semanticLabel]. Never put information *only* in a tooltip.
///
/// See also:
///
///  * [OctoPopover], when the content is interactive rather than a hint.
class OctoTooltip extends StatelessWidget {
  /// Plain-text message shown on hover or long press.
  final String message;

  /// Widget the tooltip is anchored to.
  final Widget child;

  /// Forces show/hide programmatically; pass a [TooltipTriggerMode] value.
  /// When `null`, default behaviour applies (`longPress` on touch, `hover`
  /// elsewhere).
  final TooltipTriggerMode? triggerMode;

  /// Forwarded to the inner Material [Tooltip] so callers can hold a
  /// `GlobalKey<TooltipState>` and drive show / dismiss programmatically
  /// (golden tests, controlled tutorials, "first-run" coachmarks).
  final Key? tooltipKey;

  /// Wraps [child] with a themed tooltip showing [message].
  const OctoTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode,
    this.tooltipKey,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: tooltipKey,
      message: message,
      triggerMode: triggerMode,
      child: child,
    );
  }
}
