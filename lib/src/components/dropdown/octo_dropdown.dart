import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/components/action_list/octo_action_list_item.dart';
import 'package:octo_ui/src/components/button/octo_button.dart';
import 'package:octo_ui/src/components/menu/octo_menu.dart';
import 'package:octo_ui/src/components/menu/octo_menu_controller.dart';

/// One option in an [OctoDropdown].
@immutable
class OctoDropdownItem<T> {
  /// Identity of this option.
  final T value;

  /// Visible text shown both in the trigger button and the menu row.
  final String label;

  /// Optional glyph rendered before [label] inside the menu (the trigger
  /// shows label only).
  final Widget? leading;

  /// Accessibility label override for the menu row.
  final String? semanticLabel;

  /// Creates a dropdown option.
  const OctoDropdownItem({
    required this.value,
    required this.label,
    this.leading,
    this.semanticLabel,
  });
}

/// Single-select dropdown — a button that opens an [OctoMenu] of
/// [OctoDropdownItem]s.
///
/// Controlled — pass [value] + react to [onChanged]. `onChanged: null`
/// renders an inert trigger. The trigger shows the selected item's label
/// (or [placeholder] when nothing is selected) plus a chevron, and
/// dismisses the menu via [OctoMenuController.close] on selection.
///
/// ```dart
/// OctoDropdown<Severity>(
///   value: _severity,
///   placeholder: 'Severity',
///   onChanged: (s) => setState(() => _severity = s),
///   items: const [
///     OctoDropdownItem(value: Severity.high, label: 'High'),
///     OctoDropdownItem(value: Severity.low, label: 'Low'),
///   ],
/// )
/// ```
///
/// **Variants / sizes** — the trigger is an [OctoButton], so [variant] and
/// [size] accept the same tiers and a dropdown lines up with neighbouring
/// buttons. [minWidth] pins the panel when the labels differ in length and you
/// don't want the width jumping between selections.
///
/// **States** — the trigger tracks hover, focus and pressed; the open panel
/// marks the current item selected. `disabled` follows `onChanged == null`.
/// Pass a [controller] to open or close it from outside.
///
/// **Accessibility** — panel entries carry `Semantics(selected: …)`. Arrow keys
/// move through them, Enter picks, Escape closes and returns focus to the
/// trigger — so the control is fully operable without a pointer.
///
/// See also:
///
///  * [OctoMenu], when the entries are commands rather than a value to select.
class OctoDropdown<T> extends StatefulWidget {
  /// Options shown when the user opens the dropdown.
  final List<OctoDropdownItem<T>> items;

  /// Currently selected value. `null` makes the trigger show [placeholder].
  final T? value;

  /// Called when the user picks a different option.
  final ValueChanged<T>? onChanged;

  /// Trigger text shown when [value] is `null`.
  final String placeholder;

  /// Variant of the trigger button.
  final OctoButtonVariant variant;

  /// Size of the trigger button.
  final OctoButtonSize size;

  /// Minimum width of the popover. Defaults to the trigger button's
  /// measured width.
  final double? minWidth;

  /// Optional external menu controller. When `null`, the dropdown owns
  /// its own controller; supply one to open / close the menu
  /// programmatically (tests, "expand on focus" patterns).
  final OctoMenuController? controller;

  /// Creates a dropdown.
  const OctoDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Select…',
    this.variant = OctoButtonVariant.standard,
    this.size = OctoButtonSize.medium,
    this.minWidth,
    this.controller,
  });

  @override
  State<OctoDropdown<T>> createState() => _OctoDropdownState<T>();
}

class _OctoDropdownState<T> extends State<OctoDropdown<T>> {
  OctoMenuController? _ownedController;
  OctoMenuController get _menuController =>
      widget.controller ?? (_ownedController ??= OctoMenuController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  String get _triggerLabel {
    if (widget.value == null) return widget.placeholder;
    final selected = widget.items.cast<OctoDropdownItem<T>?>().firstWhere(
          (i) => i?.value == widget.value,
          orElse: () => null,
        );
    return selected?.label ?? widget.placeholder;
  }

  List<OctoActionListItem> _menuItems() {
    return [
      for (final item in widget.items)
        OctoActionListItem(
          label: item.label,
          leading: item.leading,
          semanticLabel: item.semanticLabel,
          selected: item.value == widget.value,
          onPressed: widget.onChanged == null ? null : () => widget.onChanged!(item.value),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    return OctoMenu(
      controller: _menuController,
      items: _menuItems(),
      minWidth: widget.minWidth,
      child: OctoButton.label(
        _triggerLabel,
        onPressed: enabled ? _menuController.toggle : null,
        variant: widget.variant,
        size: widget.size,
        trailingIcon: const Icon(OctIcons.chevron_down_16),
      ),
    );
  }
}
