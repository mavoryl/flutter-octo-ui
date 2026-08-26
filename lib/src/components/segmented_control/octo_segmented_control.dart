import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/segmented_control/octo_segmented_control_item.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Single-select group of connected buttons (Primer "SegmentedControl").
///
/// Typical use is a "view mode" toggle — `Code` / `Issues` / `Settings`,
/// or `All` / `Open` / `Closed`. Pass [items] + the currently selected
/// [value]; the user picks a new value through [onChanged].
/// `onChanged: null` renders an inert control.
///
/// The outer container is `canvas.subtle` with a 1 px border. The
/// selected segment lifts above the rest with a `canvas.defaultColor`
/// background and a subtle border. Each segment is independently
/// focusable; `Tab` / `Shift+Tab` walk between them and `Space`
/// activates the focused segment.
///
/// ```dart
/// OctoSegmentedControl<Range>(
///   value: _range,
///   onChanged: (r) => setState(() => _range = r),
///   items: const [
///     OctoSegmentedControlItem(value: Range.day, label: '24h'),
///     OctoSegmentedControlItem(value: Range.week, label: '7d'),
///     OctoSegmentedControlItem(value: Range.month, label: '30d'),
///   ],
/// )
/// ```
///
/// **States** — each segment tracks hover, focus and pressed; the segment whose
/// [OctoSegmentedControlItem.value] equals [value] is selected. `disabled`
/// follows `onChanged == null` and applies to the whole control.
///
/// **Accessibility** — every segment is a button carrying
/// `Semantics(selected: …)`, so a screen reader announces which one is current
/// instead of reading a row of unlabelled options. Space activates the focused
/// segment.
///
/// See also:
///
///  * [OctoRadio], when the options need more room than a compact row allows.
///  * [OctoUnderlineNav], for switching views rather than picking a value.
class OctoSegmentedControl<T> extends StatelessWidget {
  /// Segments rendered left → right.
  final List<OctoSegmentedControlItem<T>> items;

  /// Currently selected segment value.
  final T value;

  /// Called when the user picks a different segment.
  final ValueChanged<T>? onChanged;

  /// Creates a segmented control. Not const — the
  /// `assert(items.isNotEmpty, …)` runs at runtime and a const-evaluated
  /// `items.length`/`items.isNotEmpty` is not supported for a List
  /// parameter.
  // ignore: prefer_const_constructors_in_immutables
  OctoSegmentedControl({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  }) : assert(items.isNotEmpty, 'at least one segment is required');

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final outerRadius = BorderRadius.all(Radius.circular(theme.radii.medium));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.canvas.subtle,
        border: Border.all(color: theme.colors.border.defaultColor),
        borderRadius: outerRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              _Segment<T>(
                item: item,
                selected: item.value == value,
                onPressed: onChanged == null ? null : () => onChanged!(item.value),
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment<T> extends StatefulWidget {
  final OctoSegmentedControlItem<T> item;
  final bool selected;
  final VoidCallback? onPressed;
  final OctoThemeData theme;

  const _Segment({
    required this.item,
    required this.selected,
    required this.onPressed,
    required this.theme,
  });

  @override
  State<_Segment<T>> createState() => _SegmentState<T>();
}

class _SegmentState<T> extends State<_Segment<T>> {
  late final WidgetStatesController _states;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (widget.onPressed == null) WidgetState.disabled,
      if (widget.selected) WidgetState.selected,
    });
    _focusNode = FocusNode(
      debugLabel: 'OctoSegmentedControl(${widget.item.label ?? widget.item.value})',
    );
  }

  @override
  void didUpdateWidget(_Segment<T> oldWidget) {
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

  void _activate() {
    if (!_enabled || widget.selected) return;
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final fg = !_enabled
        ? theme.colors.fg.muted
        : (widget.selected ? theme.colors.fg.defaultColor : theme.colors.fg.muted);
    final innerRadius = BorderRadius.all(Radius.circular(theme.radii.small));
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
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
          canRequestFocus: _enabled,
          onFocusChange: (f) => _states.update(WidgetState.focused, f),
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
                onTap: _enabled
                    ? () {
                        _focusNode.requestFocus();
                        _activate();
                      }
                    : null,
                child: ListenableBuilder(
                  listenable: _states,
                  builder: (context, _) {
                    // Selected paints its own raised background so the
                    // state-layer skips the selected-overlay branch.
                    final overlayStates =
                        _states.value.where((s) => s != WidgetState.selected).toSet();
                    return DecoratedBox(
                      decoration: widget.selected
                          ? BoxDecoration(
                              color: theme.colors.canvas.defaultColor,
                              borderRadius: innerRadius,
                              border: Border.all(
                                color: theme.colors.border.defaultColor,
                              ),
                            )
                          : const BoxDecoration(),
                      child: OctoStateLayer(
                        states: overlayStates,
                        borderRadius: innerRadius,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.spacing.gap.md,
                            vertical: theme.spacing.scale(2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.item.icon != null) ...[
                                IconTheme(
                                  data: IconThemeData(color: fg, size: 16),
                                  child: widget.item.icon!,
                                ),
                                if (widget.item.label != null)
                                  SizedBox(width: theme.spacing.gap.sm),
                              ],
                              if (widget.item.label != null)
                                OctoText(
                                  widget.item.label!,
                                  kind: widget.selected
                                      ? OctoTextKind.bodyEmphasis
                                      : OctoTextKind.body,
                                  color: fg,
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
          ),
        ),
      ),
    );
  }
}
