import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Square checkbox (Primer "Checkbox").
///
/// Controlled — pass [value] + react to [onChanged]. `onChanged: null`
/// renders the checkbox disabled. When [tristate] is `true`, [value] may
/// be `null` (indeterminate); the user cycles `false → true → null →
/// false` via tap or `Space`.
class OctoCheckbox extends StatefulWidget {
  /// Current state. `null` is only allowed when [tristate] is `true`.
  final bool? value;

  /// Called with the next value when the user toggles.
  /// `null` disables the control.
  final ValueChanged<bool?>? onChanged;

  /// When `true`, the checkbox cycles through three states including
  /// `null` ("indeterminate", rendered with a dash glyph).
  final bool tristate;

  /// Accessibility label.
  final String? semanticLabel;

  /// Focus node forwarded to the inner [FocusableActionDetector].
  final FocusNode? focusNode;

  /// Whether the checkbox should request focus when first mounted.
  final bool autofocus;

  /// Creates a checkbox.
  const OctoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
          tristate || value != null,
          'value can only be null when tristate is true',
        );

  @override
  State<OctoCheckbox> createState() => _OctoCheckboxState();
}

class _OctoCheckboxState extends State<OctoCheckbox> {
  late final WidgetStatesController _states;

  static const double _size = 16;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (widget.onChanged == null) WidgetState.disabled,
      if (widget.value == true) WidgetState.selected,
    });
  }

  @override
  void didUpdateWidget(OctoCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, widget.onChanged == null);
    _states.update(WidgetState.selected, widget.value == true);
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onChanged != null;

  bool? _nextValue() {
    if (!widget.tristate) return !(widget.value ?? false);
    return switch (widget.value) {
      false => true,
      true => null,
      null => false,
    };
  }

  void _toggle() {
    if (!_enabled) return;
    widget.onChanged!(_nextValue());
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.small));
    final filled = widget.value != false;
    final Color borderColor;
    final Color? fillColor;
    final Color glyphColor;
    if (!_enabled) {
      borderColor = theme.colors.border.muted;
      fillColor = filled ? theme.colors.neutral.muted : null;
      glyphColor = theme.colors.fg.muted;
    } else if (filled) {
      borderColor = theme.colors.accent.emphasis;
      fillColor = theme.colors.accent.emphasis;
      glyphColor = theme.colors.fg.onEmphasis;
    } else {
      borderColor = theme.colors.border.defaultColor;
      fillColor = null;
      glyphColor = theme.colors.fg.onEmphasis;
    }

    final IconData? glyph = switch (widget.value) {
      true => OctIcons.check_16,
      null => OctIcons.dash_16,
      false => null,
    };

    return Semantics(
      checked: widget.value == true,
      mixed: widget.tristate ? widget.value == null : null,
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
              child: Container(
                width: _size,
                height: _size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: radius,
                  border: Border.all(color: borderColor),
                ),
                child: glyph == null ? null : Icon(glyph, size: 12, color: glyphColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
