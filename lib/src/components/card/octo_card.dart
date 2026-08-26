import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Surface treatment of an [OctoCard].
enum OctoCardVariant {
  /// Hairline border, no shadow. The dense-UI default — stacks of outlined
  /// cards stay readable where stacks of shadows turn to mud.
  outlined,

  /// Drop shadow (`theme.shadows.small`), no border. Use when the card
  /// floats above content rather than sitting in a grid.
  elevated,
}

/// Content surface (Primer "Box") — the container for a repository row, a
/// settings group, a dashboard tile.
///
/// Two modes, chosen by [onPressed]:
///
///   * `onPressed == null` — presentational. No pointer listeners, no
///     `Semantics.button`; screen readers walk straight through to the
///     content.
///   * `onPressed != null` — interactive. Hover / focus / pressed states
///     are tracked through a [WidgetStatesController] driven by a
///     [FocusableActionDetector], drawn by [OctoStateLayer], and the card
///     announces itself as a button. Enter / Space activate it.
///
/// [selected] works in both modes so a list of presentational cards can
/// still show which row is current.
class OctoCard extends StatefulWidget {
  /// Card content.
  final Widget child;

  /// Inner padding. Defaults to `EdgeInsets.all(theme.spacing.inset.lg)`.
  final EdgeInsetsGeometry? padding;

  /// Surface treatment. See [OctoCardVariant].
  final OctoCardVariant variant;

  /// Tap handler. When `null` the card is presentational — see the class
  /// doc for what that changes.
  final VoidCallback? onPressed;

  /// Marks the card as the current selection. Renders the accent-tinted
  /// state overlay; independent of [onPressed].
  final bool selected;

  /// Accessibility label for the interactive mode. Ignored when
  /// [onPressed] is `null` — a presentational card has no semantics of its
  /// own to label.
  final String? semanticLabel;

  /// Focus node forwarded to the inner [FocusableActionDetector].
  final FocusNode? focusNode;

  /// Whether an interactive card should request focus when first mounted.
  final bool autofocus;

  /// Test-only override that forces the visual state set, bypassing the
  /// internal [WidgetStatesController]. Used by golden tests to capture
  /// hover / pressed appearances without driving real pointer events.
  /// Never set in production code.
  @visibleForTesting
  final Set<WidgetState>? debugStates;

  /// Creates a card.
  const OctoCard({
    super.key,
    required this.child,
    this.padding,
    this.variant = OctoCardVariant.outlined,
    this.onPressed,
    this.selected = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.debugStates,
  });

  @override
  State<OctoCard> createState() => _OctoCardState();
}

class _OctoCardState extends State<OctoCard> {
  late final WidgetStatesController _states;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController();
    _syncSelected();
  }

  @override
  void didUpdateWidget(OctoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSelected();
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  bool get _interactive => widget.onPressed != null;

  void _syncSelected() => _states.update(WidgetState.selected, widget.selected);

  void _handleTapDown(TapDownDetails _) => _states.update(WidgetState.pressed, true);

  void _handleTapUp(TapUpDetails _) => _states.update(WidgetState.pressed, false);

  void _handleTapCancel() => _states.update(WidgetState.pressed, false);

  void _handleHover(bool hovered) => _states.update(WidgetState.hovered, hovered);

  void _handleFocusChange(bool focused) => _states.update(WidgetState.focused, focused);

  BoxDecoration _decoration(OctoThemeData theme, BorderRadius radius) => BoxDecoration(
        color: theme.colors.canvas.defaultColor,
        borderRadius: radius,
        border: widget.variant == OctoCardVariant.outlined
            ? Border.all(color: theme.colors.border.defaultColor)
            : null,
        boxShadow: widget.variant == OctoCardVariant.elevated ? theme.shadows.small : null,
      );

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));
    final padding = widget.padding ?? EdgeInsets.all(theme.spacing.inset.lg);

    final surface = ListenableBuilder(
      listenable: _states,
      builder: (context, _) {
        final states = widget.debugStates ?? _states.value;
        return DecoratedBox(
          decoration: _decoration(theme, radius),
          child: OctoStateLayer(
            states: states,
            borderRadius: radius,
            child: Padding(padding: padding, child: widget.child),
          ),
        );
      },
    );

    if (!_interactive) return surface;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onPressed,
          child: FocusableActionDetector(
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            onFocusChange: _handleFocusChange,
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onPressed!();
                  return null;
                },
              ),
            },
            child: OctoFocusRing(borderRadius: radius, child: surface),
          ),
        ),
      ),
    );
  }
}
