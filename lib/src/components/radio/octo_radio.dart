import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Mutually-exclusive radio button — one selection per group (Primer
/// "Radio").
///
/// Use [groupValue] as the shared "currently selected" value and assign a
/// unique [value] to each [OctoRadio] in the group. When the user picks
/// this radio, [onChanged] fires with [value]. Set `onChanged: null` to
/// render the radio disabled.
///
/// Arrow-key traversal across siblings is left to the enclosing layout;
/// inside an [OctoActionList] or a [FocusTraversalGroup] arrow keys move
/// focus by reading order. `Space` activates the focused radio.
class OctoRadio<T> extends StatefulWidget {
  /// Value that this radio represents inside the group.
  final T value;

  /// Currently selected value in the enclosing group.
  final T? groupValue;

  /// Called with [value] when the user picks this radio.
  final ValueChanged<T?>? onChanged;

  /// Accessibility label.
  final String? semanticLabel;

  /// Focus node forwarded to the inner [FocusableActionDetector].
  final FocusNode? focusNode;

  /// Whether the radio should request focus when first mounted.
  final bool autofocus;

  /// Creates a radio button bound to [value].
  const OctoRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<OctoRadio<T>> createState() => _OctoRadioState<T>();
}

class _OctoRadioState<T> extends State<OctoRadio<T>> {
  late final WidgetStatesController _states;

  static const double _size = 16;
  static const double _dotSize = 6;

  bool get _selected => widget.value == widget.groupValue;
  bool get _enabled => widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (!_enabled) WidgetState.disabled,
      if (_selected) WidgetState.selected,
    });
  }

  @override
  void didUpdateWidget(OctoRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, !_enabled);
    _states.update(WidgetState.selected, _selected);
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  void _select() {
    if (!_enabled || _selected) return;
    widget.onChanged!(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final Color borderColor;
    final Color? dotColor;
    if (!_enabled) {
      borderColor = theme.colors.border.muted;
      dotColor = _selected ? theme.colors.fg.muted : null;
    } else if (_selected) {
      borderColor = theme.colors.accent.emphasis;
      dotColor = theme.colors.accent.emphasis;
    } else {
      borderColor = theme.colors.border.defaultColor;
      dotColor = null;
    }
    final radius = BorderRadius.all(Radius.circular(theme.radii.full));

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: _selected,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: _enabled ? (_) => _states.update(WidgetState.hovered, true) : null,
        onExit: _enabled ? (_) => _states.update(WidgetState.hovered, false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _select : null,
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
                  _select();
                  return null;
                },
              ),
            },
            child: OctoFocusRing(
              borderRadius: radius,
              child: Container(
                width: _size,
                height: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: borderColor, width: _selected ? 2 : 1),
                ),
                child: dotColor == null
                    ? null
                    : Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          color: dotColor,
                          borderRadius: radius,
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
