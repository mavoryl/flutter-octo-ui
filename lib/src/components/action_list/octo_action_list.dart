import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/action_list/octo_action_list_item.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Vertical list of [OctoActionListItem]s — used standalone (e.g. inside a
/// drawer) or as the body of an overlay menu / popover (`OctoMenu`,
/// `OctoCommandPalette`).
///
/// Two construction modes:
///
///   * Default — accepts an in-memory `List<OctoActionListItem>`. Suitable
///     for short, fixed-size menus.
///   * [OctoActionList.builder] — lazy variant for long, scrollable lists
///     (filter dropdowns, command palettes, contact pickers). Mirrors
///     `ListView.builder` semantics.
///
/// Each row is its own focusable interactive surface with hover / pressed /
/// focused / selected / disabled state via [OctoStateLayer]. Keyboard
/// navigation: `ArrowDown` / `ArrowUp` move focus through the rows
/// (wrapped in a [FocusTraversalGroup] with a reading-order policy);
/// `Enter` / `Space` activate the focused row. When [autofocus] is `true`
/// the first row requests focus on mount — convenient for overlay menus.
class OctoActionList extends StatelessWidget {
  /// Eager list of items. Mutually exclusive with [itemCount] / [itemBuilder].
  final List<OctoActionListItem>? items;

  /// Item count for the lazy [OctoActionList.builder] variant.
  final int? itemCount;

  /// Item builder for the lazy [OctoActionList.builder] variant.
  final OctoActionListItem Function(BuildContext context, int index)? itemBuilder;

  /// Constrains the list to its intrinsic height. When `true` (default),
  /// the list does NOT scroll — useful inside a menu or a `Column`. Set to
  /// `false` to make the list scroll within its parent's constraints (e.g.
  /// inside a fixed-height popover).
  final bool shrinkWrap;

  /// When `true`, the first row requests focus on mount. Use inside an
  /// overlay menu so arrow-key navigation works immediately without a tap.
  final bool autofocus;

  /// Creates an action list backed by an eager [items] list.
  const OctoActionList({
    super.key,
    required List<OctoActionListItem> this.items,
    this.shrinkWrap = true,
    this.autofocus = false,
  })  : itemCount = null,
        itemBuilder = null;

  /// Lazy variant — items are built on demand. Use for long lists where
  /// rendering every row upfront would be wasteful.
  const OctoActionList.builder({
    super.key,
    required int this.itemCount,
    required OctoActionListItem Function(BuildContext context, int index) this.itemBuilder,
    this.shrinkWrap = true,
    this.autofocus = false,
  }) : items = null;

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final Widget body;
    if (items != null) {
      body = Column(
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items!.length; i++)
            _ActionRow(
              item: items![i],
              theme: theme,
              autofocus: autofocus && i == 0,
            ),
        ],
      );
    } else {
      body = ListView.builder(
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        itemBuilder: (ctx, index) => _ActionRow(
          item: itemBuilder!(ctx, index),
          theme: theme,
          autofocus: autofocus && index == 0,
        ),
      );
    }
    // Arrow-key traversal across rows. Each row owns its own `Focus`; the
    // outer Shortcuts intercepts arrows and the Actions wired below move
    // focus by reading order. These Actions are duplicated here so the
    // list works without a `WidgetsApp` (which would normally install the
    // defaults).
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          NextFocusIntent: NextFocusAction(),
          PreviousFocusIntent: PreviousFocusAction(),
        },
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: body,
        ),
      ),
    );
  }
}

class _ActionRow extends StatefulWidget {
  final OctoActionListItem item;
  final OctoThemeData theme;
  final bool autofocus;

  const _ActionRow({required this.item, required this.theme, this.autofocus = false});

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  late final WidgetStatesController _states;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (widget.item.onPressed == null) WidgetState.disabled,
      if (widget.item.selected) WidgetState.selected,
    });
    _focusNode = FocusNode(debugLabel: 'OctoActionListItem(${widget.item.label})');
  }

  @override
  void didUpdateWidget(_ActionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, widget.item.onPressed == null);
    _states.update(WidgetState.selected, widget.item.selected);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _states.dispose();
    super.dispose();
  }

  bool get _enabled => widget.item.onPressed != null;

  void _handleFocusChange(bool focused) {
    _states.update(WidgetState.focused, focused);
  }

  void _activate() {
    if (!_enabled) return;
    widget.item.onPressed!();
  }

  Color _foreground(OctoThemeData theme, Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return theme.colors.fg.muted;
    if (widget.item.variant == OctoActionListItemVariant.danger) {
      return theme.colors.danger.fg;
    }
    return theme.colors.fg.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    // Shortcuts must be an *ancestor* of Focus — key events bubble UP from
    // the focused node, so handlers placed inside the Focus subtree are
    // unreachable.
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          canRequestFocus: _enabled,
          onFocusChange: _handleFocusChange,
          child: Semantics(
            button: true,
            enabled: _enabled,
            selected: widget.item.selected,
            label: widget.item.semanticLabel ?? widget.item.label,
            child: MouseRegion(
              cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
              onEnter: _enabled ? (_) => _states.update(WidgetState.hovered, true) : null,
              onExit: _enabled ? (_) => _states.update(WidgetState.hovered, false) : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: _enabled ? (_) => _states.update(WidgetState.pressed, true) : null,
                onTapUp: _enabled ? (_) => _states.update(WidgetState.pressed, false) : null,
                onTapCancel: _enabled ? () => _states.update(WidgetState.pressed, false) : null,
                onTap: _enabled
                    ? () {
                        _focusNode.requestFocus();
                        widget.item.onPressed!();
                      }
                    : null,
                child: ListenableBuilder(
                  listenable: _states,
                  builder: (context, _) {
                    final states = _states.value;
                    final fg = _foreground(theme, states);
                    return OctoStateLayer(
                      states: states,
                      borderRadius: BorderRadius.all(Radius.circular(theme.radii.small)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacing.gap.md,
                          vertical: theme.spacing.gap.sm,
                        ),
                        child: Row(
                          children: [
                            if (widget.item.leading != null) ...[
                              IconTheme(
                                data: IconThemeData(color: fg, size: 16),
                                child: widget.item.leading!,
                              ),
                              SizedBox(width: theme.spacing.gap.md),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OctoText(widget.item.label, color: fg),
                                  if (widget.item.description != null)
                                    OctoText(
                                      widget.item.description!,
                                      kind: OctoTextKind.bodySmall,
                                      color: theme.colors.fg.muted,
                                    ),
                                ],
                              ),
                            ),
                            if (widget.item.trailing != null) ...[
                              SizedBox(width: theme.spacing.gap.md),
                              IconTheme(
                                data: IconThemeData(color: fg, size: 16),
                                child: widget.item.trailing!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
