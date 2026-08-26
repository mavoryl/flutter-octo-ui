import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/button/octo_button.dart';
import 'package:octo_ui/src/foundation/octo_icon.dart';

/// Square icon-only button. Composition over [OctoButton]: same state
/// machine, focus, keyboard activation, theming — but with square geometry
/// and a single icon child.
///
/// `semanticLabel` is required (ADR-0008): a bare icon is meaningless to
/// screen-readers without an explicit description.
///
/// ```dart
/// OctoIconButton(
///   icon: OctIcons.trash_16,
///   semanticLabel: 'Delete branch',
///   variant: OctoButtonVariant.danger,
///   onPressed: _delete,
/// )
/// ```
///
/// **Variants / sizes** — shares [OctoButtonVariant] and [OctoButtonSize] with
/// [OctoButton], so an icon button sits flush in a row of text buttons. The
/// `small` / `medium` / `large` tiers are square: 28 · 32 · 40 px.
///
/// **States** — hovered, focused and pressed via [OctoStateLayer]; `disabled`
/// follows `onPressed == null`; [loading] replaces the icon with a spinner.
///
/// **Accessibility** — [semanticLabel] is **required**: an icon alone tells a
/// screen-reader user nothing. Enter, Space and NumpadEnter activate it. Wrap in
/// [OctoTooltip] when sighted users also need the name.
///
/// See also:
///
///  * [OctoButton], when the action has a visible text label.
class OctoIconButton extends StatelessWidget {
  /// Glyph rendered as the button's content.
  final IconData icon;

  /// Tap handler. `null` renders the button disabled.
  final VoidCallback? onPressed;

  /// Visual emphasis tier. See [OctoButtonVariant].
  final OctoButtonVariant variant;

  /// Sizing tier — also picks the matching [OctoIconSize].
  final OctoButtonSize size;

  /// When true, shows a spinner in place of the icon.
  final bool loading;

  /// Accessibility label — required (ADR-0008).
  final String semanticLabel;

  /// Focus node forwarded to the underlying [OctoButton].
  final FocusNode? focusNode;

  /// Whether the button should request focus when first mounted.
  final bool autofocus;

  /// Test-only override forwarded to the underlying [OctoButton]. See
  /// [OctoButton.debugStates].
  @visibleForTesting
  final Set<WidgetState>? debugStates;

  /// Creates an icon-only button.
  const OctoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.variant = OctoButtonVariant.standard,
    this.size = OctoButtonSize.medium,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
    this.debugStates,
  });

  OctoIconSize get _iconSize => switch (size) {
        OctoButtonSize.small => OctoIconSize.small,
        OctoButtonSize.medium => OctoIconSize.medium,
        OctoButtonSize.large => OctoIconSize.large,
      };

  @override
  Widget build(BuildContext context) {
    return OctoButton(
      onPressed: onPressed,
      variant: variant,
      size: size,
      loading: loading,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      debugStates: debugStates,
      // The icon needs no inner semantic label — the outer Semantics(button)
      // from OctoButton carries `semanticLabel`. Excluding the icon's
      // semantics avoids a doubled announcement.
      child: ExcludeSemantics(
        child: OctoIcon(icon, size: _iconSize),
      ),
    );
  }
}
