import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/button/octo_button.dart';
import 'package:octo_ui/src/components/counter_label/octo_counter_label.dart';
import 'package:octo_ui/src/components/text_field/octo_text_field.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Search-and-filter row above a list or table (Primer "FilterBar") — the
/// header of an issue list, a service table, an audit log.
///
/// Composition, not configuration: the search box is built in, but the
/// [filters] themselves are whatever widgets the caller passes — an
/// [OctoDropdown] for severity, an [OctoSegmentedControl] for environment,
/// [OctoChip]s for applied facets. They sit in a [Wrap], so a narrow bar
/// reflows them onto the next line instead of overflowing.
///
/// Deciding *which* filters collapse on a phone is a screen-level decision,
/// not a component one, so the bar itself has no breakpoint logic. Wrap it
/// in an `OctoResponsiveBuilder` when a layout wants that.
class OctoFilterBar extends StatelessWidget {
  /// Controller for the search field. Supply one to read or reset the query
  /// from outside.
  final TextEditingController? searchController;

  /// Placeholder shown while the search field is empty.
  final String searchPlaceholder;

  /// Called on every keystroke in the search field.
  final ValueChanged<String>? onSearchChanged;

  /// Filter controls rendered after the search field.
  final List<Widget> filters;

  /// Resets every filter. When `null`, no clear button is rendered.
  final VoidCallback? onClear;

  /// Number of filters currently applied. When greater than zero, a
  /// [OctoCounterLabel] is shown so the count survives a collapsed bar.
  final int activeFilterCount;

  /// Accessibility label for the bar as a whole.
  final String? semanticLabel;

  /// Creates a filter bar.
  const OctoFilterBar({
    super.key,
    this.searchController,
    this.searchPlaceholder = 'Filter…',
    this.onSearchChanged,
    this.filters = const [],
    this.onClear,
    this.activeFilterCount = 0,
    this.semanticLabel,
  }) : assert(activeFilterCount >= 0, 'activeFilterCount cannot be negative.');

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: theme.spacing.gap.md,
        runSpacing: theme.spacing.gap.sm,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
            child: OctoTextField(
              controller: searchController,
              placeholder: searchPlaceholder,
              onChanged: onSearchChanged,
            ),
          ),
          ...filters,
          if (activeFilterCount > 0)
            OctoCounterLabel(
              activeFilterCount,
              semanticLabel: '$activeFilterCount active filters',
            ),
          if (onClear != null)
            OctoButton.label(
              'Clear',
              onPressed: onClear,
              variant: OctoButtonVariant.invisible,
              size: OctoButtonSize.small,
            ),
        ],
      ),
    );
  }
}
