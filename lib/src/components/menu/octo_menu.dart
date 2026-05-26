import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/action_list/octo_action_list.dart';
import 'package:octo_ui/src/components/action_list/octo_action_list_item.dart';
import 'package:octo_ui/src/components/menu/octo_menu_controller.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Popover-style menu anchored to a trigger widget.
///
/// Composition over [OctoActionList]: the menu owns the [OverlayPortal] +
/// `LayerLink` machinery, dismiss behaviour (outside-tap, Escape), and
/// the surface chrome (background, border, shadow). The list rendering
/// itself is delegated to [OctoActionList].
///
/// Wire the [controller] to your trigger's tap handler — typically
/// `OctoButton.label('More', onPressed: controller.toggle)` — and pass the
/// trigger as [child]. The menu listens to the controller and shows /
/// hides its overlay.
class OctoMenu extends StatefulWidget {
  /// Trigger widget. Must wire its tap to [controller.toggle] (or `open`).
  final Widget child;

  /// Rows displayed inside the popover.
  final List<OctoActionListItem> items;

  /// Open / closed state driver.
  final OctoMenuController controller;

  /// Vertical gap between the trigger and the popover.
  final double gap;

  /// Minimum popover width. Defaults to the trigger's measured width when
  /// `null`.
  final double? minWidth;

  /// When `true` (default) — tapping an action row dismisses the menu
  /// before invoking the item's `onPressed`. Set to `false` for sticky
  /// menus that stay open across multiple selections (e.g. multi-select
  /// filters).
  final bool closeOnSelect;

  /// Creates a menu anchored to [child].
  const OctoMenu({
    super.key,
    required this.child,
    required this.items,
    required this.controller,
    this.gap = 4,
    this.minWidth,
    this.closeOnSelect = true,
  });

  @override
  State<OctoMenu> createState() => _OctoMenuState();
}

class _OctoMenuState extends State<OctoMenu> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _anchorKey = GlobalKey();
  Size _anchorSize = Size.zero;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void didUpdateWidget(OctoMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (!mounted) return;
    final shouldShow = widget.controller.isOpen;
    if (shouldShow && !_portal.isShowing) {
      _captureAnchorSize();
      _portal.show();
    }
    if (!shouldShow && _portal.isShowing) {
      _portal.hide();
    }
  }

  void _captureAnchorSize() {
    final rb = _anchorKey.currentContext?.findRenderObject();
    if (rb is RenderBox && rb.hasSize) {
      _anchorSize = rb.size;
    }
  }

  List<OctoActionListItem> _wrapItems() {
    if (!widget.closeOnSelect) return widget.items;
    return [
      for (final item in widget.items)
        OctoActionListItem(
          label: item.label,
          description: item.description,
          leading: item.leading,
          trailing: item.trailing,
          selected: item.selected,
          variant: item.variant,
          semanticLabel: item.semanticLabel,
          onPressed: item.onPressed == null
              ? null
              : () {
                  widget.controller.close();
                  item.onPressed!();
                },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: KeyedSubtree(
        key: _anchorKey,
        child: NotificationListener<SizeChangedLayoutNotification>(
          onNotification: (_) {
            _captureAnchorSize();
            return false;
          },
          child: SizeChangedLayoutNotifier(
            child: OverlayPortal(
              controller: _portal,
              overlayChildBuilder: _buildOverlay,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));
    final minWidth = widget.minWidth ?? _anchorSize.width;

    final menu = TapRegion(
      onTapOutside: (_) => widget.controller.close(),
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                widget.controller.close();
                return null;
              },
            ),
          },
          // No autofocus here — the inner ActionList autofocuses its first
          // row, which sits inside this Shortcuts subtree, so Escape still
          // bubbles up to DismissIntent above.
          child: Focus(
            // Overlay parent (Stack) doesn't constrain width, so we ask
            // IntrinsicWidth to size the popover to its content, then bump
            // up to `minWidth` (typically the anchor width) via the inner
            // ConstrainedBox.
            child: IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: minWidth),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.canvas.overlay,
                    border: Border.all(color: theme.colors.border.defaultColor),
                    borderRadius: radius,
                    boxShadow: theme.shadows.medium,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacing.scale(1)),
                    // autofocus → first row receives focus on open, so
                    // ArrowDown / ArrowUp / Enter work without a mouse tap.
                    child: OctoActionList(items: _wrapItems(), autofocus: true),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        offset: Offset(0, widget.gap),
        child: menu,
      ),
    );
  }
}
