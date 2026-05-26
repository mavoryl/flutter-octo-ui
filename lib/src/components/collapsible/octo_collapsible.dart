import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Disclosure section that hides / reveals [child] in place (Primer-style
/// "Accordion item"). The header is always visible; tapping (or pressing
/// Space / Enter while focused) toggles the body.
///
/// **Modes.**
/// - *Uncontrolled* — pass [initiallyExpanded]; the widget tracks its own
///   open / closed state.
/// - *Controlled* — pass [expanded] (non-null) together with
///   [onExpansionChanged]; the parent owns the state and the widget
///   simply animates whenever [expanded] flips.
///
/// **Motion.** Both the body height and the chevron rotation animate
/// over [animationDuration]. When
/// `MediaQuery.maybeDisableAnimationsOf(context) == true` (ADR-0008) the
/// effective duration drops to zero so the transition snaps.
class OctoCollapsible extends StatefulWidget {
  /// Header label.
  final String title;

  /// Optional leading widget inside the header (typically an icon).
  final Widget? leading;

  /// Optional trailing widget between the title and the chevron.
  final Widget? trailing;

  /// Body content shown while expanded.
  final Widget child;

  /// Initial expansion state when the widget is *uncontrolled*. Ignored
  /// when [expanded] is non-null.
  final bool initiallyExpanded;

  /// Controlled expansion state. When non-null, the widget mirrors this
  /// value and never updates its own internal flag — the parent must
  /// react to [onExpansionChanged] and rebuild with the new value.
  final bool? expanded;

  /// Fires with the *requested* next expansion state whenever the user
  /// activates the header. Always fires (controlled or uncontrolled).
  final ValueChanged<bool>? onExpansionChanged;

  /// Duration of the height + chevron animation.
  final Duration animationDuration;

  /// Optional focus node forwarded to the header.
  final FocusNode? focusNode;

  /// Creates a collapsible section.
  const OctoCollapsible({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.trailing,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpansionChanged,
    this.animationDuration = const Duration(milliseconds: 200),
    this.focusNode,
  });

  @override
  State<OctoCollapsible> createState() => _OctoCollapsibleState();
}

class _OctoCollapsibleState extends State<OctoCollapsible> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final WidgetStatesController _states;
  FocusNode? _ownedFocusNode;

  late bool _internalExpanded;

  bool get _isExpanded => widget.expanded ?? _internalExpanded;

  FocusNode get _focusNode => widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: _isExpanded ? 1 : 0,
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _states = WidgetStatesController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnims = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _controller.duration = disableAnims ? Duration.zero : widget.animationDuration;
  }

  @override
  void didUpdateWidget(OctoCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      final disableAnims = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      _controller.duration = disableAnims ? Duration.zero : widget.animationDuration;
    }
    if (widget.expanded != null && widget.expanded != oldWidget.expanded) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _states.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _toggle() {
    final next = !_isExpanded;
    if (widget.expanded == null) {
      setState(() => _internalExpanded = next);
      _syncAnimation();
    }
    widget.onExpansionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));

    final header = Semantics(
      button: true,
      enabled: true,
      expanded: _isExpanded,
      label: widget.title,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        mouseCursor: SystemMouseCursors.click,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _toggle();
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
          onTap: _toggle,
          onTapDown: (_) => _states.update(WidgetState.pressed, true),
          onTapUp: (_) => _states.update(WidgetState.pressed, false),
          onTapCancel: () => _states.update(WidgetState.pressed, false),
          child: ListenableBuilder(
            listenable: _states,
            builder: (_, __) {
              final focused = _states.value.contains(WidgetState.focused);
              return OctoFocusRing(
                enabled: focused,
                borderRadius: radius,
                child: OctoStateLayer(
                  states: _states.value,
                  borderRadius: radius,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: theme.spacing.scale(2),
                      horizontal: theme.spacing.gap.sm,
                    ),
                    child: Row(
                      children: [
                        if (widget.leading != null) ...[
                          IconTheme(
                            data: IconThemeData(
                              color: theme.colors.fg.muted,
                              size: 16,
                            ),
                            child: widget.leading!,
                          ),
                          SizedBox(width: theme.spacing.gap.sm),
                        ],
                        Expanded(
                          child: OctoText(
                            widget.title,
                            kind: OctoTextKind.bodyEmphasis,
                            color: theme.colors.fg.defaultColor,
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          widget.trailing!,
                          SizedBox(width: theme.spacing.gap.sm),
                        ],
                        AnimatedBuilder(
                          animation: _curve,
                          builder: (_, __) => Transform.rotate(
                            angle: _curve.value * (math.pi / 2),
                            child: Icon(
                              OctIcons.chevron_right_16,
                              size: 16,
                              color: theme.colors.fg.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    final body = AnimatedBuilder(
      animation: _curve,
      builder: (_, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: _curve.value,
          child: child,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          theme.spacing.gap.sm,
          theme.spacing.scale(1),
          theme.spacing.gap.sm,
          theme.spacing.gap.sm,
        ),
        child: widget.child,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [header, body],
    );
  }
}
