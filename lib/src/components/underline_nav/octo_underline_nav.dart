import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/underline_nav/octo_underline_nav_item.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Horizontal tab strip with an underline indicator under the selected
/// tab (Primer "UnderlineNav"). Used for top-of-page section navigation —
/// `Code` / `Issues` / `Pull requests` / `Actions` style.
///
/// The whole strip carries a 1 px bottom border in `border.defaultColor`;
/// the selected tab paints a 2 px accent underline on top of it, flush
/// with the bottom. Tabs are independently focusable buttons —
/// `Tab` / `Shift+Tab` move keyboard focus between them; pointer hover
/// surfaces the same `neutral.subtle` overlay as [OctoActionList] rows
/// via [OctoStateLayer].
///
/// State is controlled — pass [selectedIndex] and react to [onChanged].
/// `onChanged: null` renders an inert nav (read-only or "loading").
///
/// ```dart
/// OctoUnderlineNav(
///   selectedIndex: _tab,
///   onChanged: (i) => setState(() => _tab = i),
///   items: const [
///     OctoUnderlineNavItem(label: 'Overview'),
///     OctoUnderlineNavItem(label: 'Services', icon: OctoIcon(OctIcons.server_16)),
///     OctoUnderlineNavItem(label: 'Incidents'),
///   ],
/// )
/// ```
///
/// **Variants** — each [OctoUnderlineNavItem] may carry an
/// [OctoUnderlineNavItem.icon] and an [OctoUnderlineNavItem.trailing]
/// widget, which is where a count pill such as [OctoCounterLabel]
/// belongs.
///
/// **States** — items track hover and focus; the item at [selectedIndex] carries
/// the underline. `disabled` follows `onChanged == null` and applies to the whole
/// bar. Selection is external — the nav renders what it is told.
///
/// **Accessibility** — every item is a button carrying `Semantics(selected: …)`,
/// so a screen reader announces which section is current. Enter and Space
/// activate the focused item.
///
/// See also:
///
///  * [OctoTabs], which pairs this bar with a body and switches it for you.
///  * [OctoSideNav], for vertical navigation.
class OctoUnderlineNav extends StatelessWidget {
  /// Tab descriptors rendered left to right.
  final List<OctoUnderlineNavItem> items;

  /// Currently selected tab index. Clamped to `0..items.length-1`.
  final int selectedIndex;

  /// Called with the index of a tapped tab. `null` makes the nav inert.
  final ValueChanged<int>? onChanged;

  /// Creates a horizontal tab strip.
  const OctoUnderlineNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colors.border.defaultColor),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < items.length; i++)
            _NavTab(
              item: items[i],
              selected: i == selectedIndex,
              onPressed: onChanged == null ? null : () => onChanged!(i),
            ),
        ],
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  final OctoUnderlineNavItem item;
  final bool selected;
  final VoidCallback? onPressed;

  const _NavTab({required this.item, required this.selected, required this.onPressed});

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  late final WidgetStatesController _states;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (widget.onPressed == null) WidgetState.disabled,
      if (widget.selected) WidgetState.selected,
    });
    _focusNode = FocusNode(debugLabel: 'OctoUnderlineNavTab(${widget.item.label})');
  }

  @override
  void didUpdateWidget(_NavTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, widget.onPressed == null);
    _states.update(WidgetState.selected, widget.selected);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _states.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null;

  void _handleFocusChange(bool focused) {
    _states.update(WidgetState.focused, focused);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final fg = widget.selected
        ? theme.colors.fg.defaultColor
        : (_enabled ? theme.colors.fg.muted : theme.colors.fg.subtle);
    return Focus(
      focusNode: _focusNode,
      canRequestFocus: _enabled,
      onFocusChange: _handleFocusChange,
      child: Semantics(
        button: true,
        enabled: _enabled,
        selected: widget.selected,
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
                    widget.onPressed!();
                  }
                : null,
            child: ListenableBuilder(
              listenable: _states,
              builder: (context, _) {
                // The selected-state overlay would compete with our
                // underline indicator, so strip WidgetState.selected before
                // handing the state set to OctoStateLayer.
                final overlayStates = _states.value.where((s) => s != WidgetState.selected).toSet();
                return Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    OctoStateLayer(
                      states: overlayStates,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(theme.radii.small),
                        topRight: Radius.circular(theme.radii.small),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacing.gap.md,
                          vertical: theme.spacing.gap.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.item.icon != null) ...[
                              IconTheme(
                                data: IconThemeData(color: fg, size: 16),
                                child: widget.item.icon!,
                              ),
                              SizedBox(width: theme.spacing.gap.sm),
                            ],
                            OctoText(
                              widget.item.label,
                              kind: widget.selected ? OctoTextKind.bodyEmphasis : OctoTextKind.body,
                              color: fg,
                            ),
                            if (widget.item.trailing != null) ...[
                              SizedBox(width: theme.spacing.gap.sm),
                              widget.item.trailing!,
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (widget.selected)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -1,
                        child: Container(
                          height: 2,
                          color: theme.colors.accent.emphasis,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
