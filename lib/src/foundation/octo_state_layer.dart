import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Translucent overlay reflecting interactive state.
///
/// Uses Flutter's built-in [WidgetState] (ADR-0001) — does NOT introduce a
/// parallel enum. Caller is responsible for tracking and passing the set of
/// active states; [OctoStateLayer] only handles the visual feedback.
///
/// Layering rules (Primer-style, no ripple):
///   * [WidgetState.disabled]    → no overlay (caller dims the child).
///   * [WidgetState.pressed]     → strongest overlay.
///   * [WidgetState.hovered]     → subtle overlay.
///   * [WidgetState.selected]    → tinted overlay using accent muted.
///   * otherwise                 → transparent.
class OctoStateLayer extends StatelessWidget {
  /// Widget beneath the overlay.
  final Widget child;

  /// Active widget states that drive overlay selection.
  final Set<WidgetState> states;

  /// Corner rounding matching the [child]'s decoration.
  final BorderRadius? borderRadius;

  /// Optional explicit overlay color. When null, the colour is resolved from
  /// the enclosing [OctoTheme]: neutral.muted for hover/press, accent.muted
  /// for selected.
  final Color? overlayColor;

  /// Creates a state overlay around [child].
  const OctoStateLayer({
    super.key,
    required this.child,
    required this.states,
    this.borderRadius,
    this.overlayColor,
  });

  Color? _resolveColor(OctoThemeData theme) {
    if (states.contains(WidgetState.disabled)) return null;
    if (states.contains(WidgetState.pressed)) {
      return overlayColor ?? theme.colors.neutral.muted;
    }
    if (states.contains(WidgetState.hovered)) {
      return overlayColor ?? theme.colors.neutral.subtle;
    }
    if (states.contains(WidgetState.selected)) {
      return overlayColor ?? theme.colors.accent.muted;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final color = _resolveColor(theme);
    if (color == null) return child;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, borderRadius: borderRadius),
            ),
          ),
        ),
      ],
    );
  }
}
