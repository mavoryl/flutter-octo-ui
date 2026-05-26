import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/side_nav/octo_side_nav_item.dart';
import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Vertical sidebar navigation (Primer "SideNav").
///
/// Renders [items] as a column of tappable rows. The selected row is
/// highlighted with `neutral.subtle` background and a 2 px accent bar
/// flush against its leading edge. Tapping fires [onChanged] with the
/// requested index; tapping the already-selected row is a no-op.
///
/// Keyboard:
/// - `Up` / `Down` move focus between rows.
/// - `Space` / `Enter` activates the focused row (same as a tap).
class OctoSideNav extends StatelessWidget {
  /// Rows to render, top to bottom.
  final List<OctoSideNavItem> items;

  /// Currently selected index (0-based). Pass `-1` for no selection.
  final int selectedIndex;

  /// Fires with the requested next index. Not invoked for the row
  /// that's already selected.
  final ValueChanged<int>? onChanged;

  /// Creates a vertical sidebar nav.
  const OctoSideNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Semantics(
      container: true,
      label: 'Sidebar navigation',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: theme.colors.border.muted),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++)
              _SideNavRow(
                item: items[i],
                selected: i == selectedIndex,
                onPressed: i == selectedIndex ? null : () => onChanged?.call(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _SideNavRow extends StatefulWidget {
  final OctoSideNavItem item;
  final bool selected;
  final VoidCallback? onPressed;

  const _SideNavRow({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  @override
  State<_SideNavRow> createState() => _SideNavRowState();
}

class _SideNavRowState extends State<_SideNavRow> {
  late final WidgetStatesController _states;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _states = WidgetStatesController(<WidgetState>{
      if (widget.selected) WidgetState.selected,
      if (widget.onPressed == null && !widget.selected) WidgetState.disabled,
    });
  }

  @override
  void didUpdateWidget(_SideNavRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.selected, widget.selected);
    _states.update(
      WidgetState.disabled,
      widget.onPressed == null && !widget.selected,
    );
  }

  @override
  void dispose() {
    _states.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final fg = widget.selected ? theme.colors.fg.defaultColor : theme.colors.fg.muted;
    final bgSelected = theme.colors.neutral.subtle;

    final row = Stack(
      children: [
        if (widget.selected)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 2,
            child: ColoredBox(color: theme.colors.accent.emphasis),
          ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.gap.md,
            vertical: theme.spacing.gap.sm,
          ),
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg, size: 16),
                  child: widget.item.icon!,
                ),
                SizedBox(width: theme.spacing.gap.sm),
              ],
              Expanded(
                child: OctoText(
                  widget.item.label,
                  kind: widget.selected ? OctoTextKind.bodyEmphasis : OctoTextKind.body,
                  color: fg,
                ),
              ),
              if (widget.item.trailing != null) ...[
                SizedBox(width: theme.spacing.gap.sm),
                widget.item.trailing!,
              ],
            ],
          ),
        ),
      ],
    );

    final tappable = widget.onPressed != null;

    return Semantics(
      container: true,
      button: true,
      selected: widget.selected,
      enabled: tappable || widget.selected,
      label: widget.item.semanticLabel ?? widget.item.label,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        mouseCursor: tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        enabled: tappable,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        onShowHoverHighlight: (h) => _states.update(WidgetState.hovered, h),
        onShowFocusHighlight: (f) => _states.update(WidgetState.focused, f),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onTapDown: tappable ? (_) => _states.update(WidgetState.pressed, true) : null,
          onTapUp: tappable ? (_) => _states.update(WidgetState.pressed, false) : null,
          onTapCancel: tappable ? () => _states.update(WidgetState.pressed, false) : null,
          child: ListenableBuilder(
            listenable: _states,
            builder: (_, __) {
              final focused = _states.value.contains(WidgetState.focused);
              // Strip the persistent `selected` flag before feeding the
              // state-layer so the hover / pressed overlays still pulse
              // on the already-highlighted row.
              final overlayStates = _states.value.where((s) => s != WidgetState.selected).toSet();
              return OctoFocusRing(
                enabled: focused,
                borderRadius: BorderRadius.zero,
                child: ColoredBox(
                  color: widget.selected ? bgSelected : const Color(0x00000000),
                  child: OctoStateLayer(
                    states: overlayStates,
                    borderRadius: BorderRadius.zero,
                    child: row,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
