import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_overlay_controller.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Where an [OctoPopover] sits relative to its trigger.
///
/// `start` / `end` describe the edge the surface is aligned to, resolved
/// against the ambient [Directionality] — `bottomEnd` opens to the left in
/// LTR and to the right in RTL.
enum OctoPopoverPlacement {
  /// Below the trigger, aligned to its leading edge. The default.
  bottomStart,

  /// Below the trigger, aligned to its trailing edge.
  bottomEnd,

  /// Above the trigger, aligned to its leading edge.
  topStart,

  /// Above the trigger, aligned to its trailing edge.
  topEnd,
}

/// Anchored surface holding arbitrary content (Primer "Popover") — a filter
/// form, a details card, a mini profile.
///
/// The overlay machinery matches [OctoMenu]: `OverlayPortal` + `LayerLink`
/// for positioning, `TapRegion` for outside-tap dismissal, `Escape` mapped
/// to [DismissIntent]. The difference is the payload — [content] is any
/// widget, so tapping inside does NOT dismiss the surface. Callers that
/// want select-and-close behaviour want [OctoMenu] instead.
///
/// Wire the [controller] to the trigger's tap handler and pass the trigger
/// as [child]:
///
/// ```dart
/// OctoPopover(
///   controller: _controller,
///   content: const OctoText('Filter by author'),
///   child: OctoButton.label('Author', onPressed: _controller.toggle),
/// )
/// ```
class OctoPopover extends StatefulWidget {
  /// Trigger widget. Must wire its tap to [controller.toggle] (or `open`).
  final Widget child;

  /// Surface content. Any widget — forms, text, lists.
  final Widget content;

  /// Open / closed state driver.
  final OctoOverlayController controller;

  /// Which side of the trigger the surface opens on, and which edge it
  /// aligns to. See [OctoPopoverPlacement].
  final OctoPopoverPlacement placement;

  /// Gap in logical pixels between the trigger and the surface.
  final double gap;

  /// Upper bound on the surface width. Content narrower than this keeps its
  /// intrinsic width; wider content wraps.
  final double maxWidth;

  /// Accessibility label for the surface. Announced when the popover opens.
  final String? semanticLabel;

  /// Creates a popover anchored to [child].
  const OctoPopover({
    super.key,
    required this.child,
    required this.content,
    required this.controller,
    this.placement = OctoPopoverPlacement.bottomStart,
    this.gap = 8,
    this.maxWidth = 320,
    this.semanticLabel,
  });

  @override
  State<OctoPopover> createState() => _OctoPopoverState();
}

class _OctoPopoverState extends State<OctoPopover> {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();

  /// Shared by the trigger's and the surface's [TapRegion]s so a tap on the
  /// trigger is not "outside". Without it, tapping an open popover's trigger
  /// closes it via `onTapOutside` and the trigger's own `toggle` immediately
  /// reopens it.
  final Object _tapGroup = Object();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void didUpdateWidget(OctoPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
      // The incoming controller may disagree with what is on screen.
      _syncPortal();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (!mounted) return;
    _syncPortal();
  }

  void _syncPortal() {
    final shouldShow = widget.controller.isOpen;
    if (shouldShow && !_portal.isShowing) _portal.show();
    if (!shouldShow && _portal.isShowing) _portal.hide();
  }

  /// Anchor on the trigger, and the matching corner of the surface that is
  /// pinned to it.
  ({Alignment target, Alignment follower}) _anchors() => switch (widget.placement) {
        OctoPopoverPlacement.bottomStart => (
            target: AlignmentDirectional.bottomStart.resolve(Directionality.of(context)),
            follower: AlignmentDirectional.topStart.resolve(Directionality.of(context)),
          ),
        OctoPopoverPlacement.bottomEnd => (
            target: AlignmentDirectional.bottomEnd.resolve(Directionality.of(context)),
            follower: AlignmentDirectional.topEnd.resolve(Directionality.of(context)),
          ),
        OctoPopoverPlacement.topStart => (
            target: AlignmentDirectional.topStart.resolve(Directionality.of(context)),
            follower: AlignmentDirectional.bottomStart.resolve(Directionality.of(context)),
          ),
        OctoPopoverPlacement.topEnd => (
            target: AlignmentDirectional.topEnd.resolve(Directionality.of(context)),
            follower: AlignmentDirectional.bottomEnd.resolve(Directionality.of(context)),
          ),
      };

  bool get _opensDownwards =>
      widget.placement == OctoPopoverPlacement.bottomStart ||
      widget.placement == OctoPopoverPlacement.bottomEnd;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: TapRegion(groupId: _tapGroup, child: widget.child),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));
    final anchors = _anchors();

    final surface = TapRegion(
      groupId: _tapGroup,
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
          // The surface itself takes focus so Escape has a target even when
          // the content holds nothing focusable.
          child: Focus(
            autofocus: true,
            child: Semantics(
              container: true,
              label: widget.semanticLabel,
              child: IntrinsicWidth(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.maxWidth),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.canvas.overlay,
                      border: Border.all(color: theme.colors.border.defaultColor),
                      borderRadius: radius,
                      boxShadow: theme.shadows.medium,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(theme.spacing.inset.md),
                      child: widget.content,
                    ),
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
        targetAnchor: anchors.target,
        followerAnchor: anchors.follower,
        offset: Offset(0, _opensDownwards ? widget.gap : -widget.gap),
        child: surface,
      ),
    );
  }
}
