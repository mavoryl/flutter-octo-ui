import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Pill-shaped on/off toggle (Primer "ToggleSwitch").
///
/// Controlled — pass [value] + react to [onChanged]. `onChanged: null`
/// renders the switch disabled and ignores pointer / keyboard input.
/// Keyboard: Tab focuses, `Space` toggles. An [OctoFocusRing] surrounds
/// the track under keyboard focus.
class OctoSwitch extends StatefulWidget {
  /// Current on/off state.
  final bool value;

  /// Called with the new value when the user toggles the switch. `null`
  /// disables the control.
  final ValueChanged<bool>? onChanged;

  /// Accessibility label. Required for icon-only switches; recommended in
  /// general (Flutter falls back to "switch" otherwise).
  final String? semanticLabel;

  /// Focus node forwarded to the inner [FocusableActionDetector].
  final FocusNode? focusNode;

  /// Whether the switch should request focus when first mounted.
  final bool autofocus;

  /// Creates a toggle switch.
  const OctoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<OctoSwitch> createState() => _OctoSwitchState();
}

class _OctoSwitchState extends State<OctoSwitch> {
  late final WidgetStatesController _states;

  static const double _trackWidth = 32;
  static const double _trackHeight = 20;
  static const double _thumbSize = 16;
  static const double _thumbInset = 2;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (widget.onChanged == null) WidgetState.disabled,
      if (widget.value) WidgetState.selected,
    });
  }

  @override
  void didUpdateWidget(OctoSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, widget.onChanged == null);
    _states.update(WidgetState.selected, widget.value);
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onChanged != null;

  void _toggle() {
    if (!_enabled) return;
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    Color trackColor;
    if (!_enabled) {
      trackColor = theme.colors.neutral.subtle;
    } else if (widget.value) {
      trackColor = theme.colors.accent.emphasis;
    } else {
      trackColor = theme.colors.neutral.emphasis;
    }
    final radius = BorderRadius.all(Radius.circular(theme.radii.full));

    return Semantics(
      toggled: widget.value,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: _enabled ? (_) => _states.update(WidgetState.hovered, true) : null,
        onExit: _enabled ? (_) => _states.update(WidgetState.hovered, false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _toggle : null,
          child: FocusableActionDetector(
            enabled: _enabled,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            onFocusChange: (f) => _states.update(WidgetState.focused, f),
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _toggle();
                  return null;
                },
              ),
            },
            child: OctoFocusRing(
              borderRadius: radius,
              child: AnimatedContainer(
                duration: theme.animation.fast,
                curve: theme.animation.standardCurve,
                width: _trackWidth,
                height: _trackHeight,
                padding: const EdgeInsets.all(_thumbInset),
                decoration: BoxDecoration(color: trackColor, borderRadius: radius),
                child: AnimatedAlign(
                  duration: theme.animation.fast,
                  curve: theme.animation.standardCurve,
                  alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      color: theme.colors.fg.onEmphasis,
                      borderRadius: BorderRadius.all(Radius.circular(theme.radii.full)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
