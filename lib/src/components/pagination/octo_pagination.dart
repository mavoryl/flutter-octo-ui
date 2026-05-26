import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Paged navigator (Primer "Pagination"). Renders a row of compact
/// numeric buttons with Previous / Next controls and an ellipsis when
/// the range is too wide to fit linearly.
///
/// **Page numbers are 1-based** — `currentPage = 1` is the first page,
/// `currentPage = pageCount` is the last.
///
/// The visible window of numbered slots is bounded by [maxVisible]. The
/// component always keeps the first and last page in view; the rest of
/// the slots track `currentPage` with ellipsis gaps where the gap to
/// the next number is larger than one.
class OctoPagination extends StatelessWidget {
  /// Current page (1-based, inclusive).
  final int currentPage;

  /// Total number of pages (1-based, inclusive). Must be `>= 1`.
  final int pageCount;

  /// Fires with the requested next page index (1-based). Not invoked
  /// when the user activates the already-selected page.
  final ValueChanged<int> onPageChanged;

  /// Maximum number of numbered slots shown between the prev / next
  /// arrows. Ellipsis tokens count toward the limit. Defaults to 7,
  /// which fits a `1 … 4 5 6 … 20`-style window.
  final int maxVisible;

  /// When `true`, prepend a Previous arrow and append a Next arrow.
  final bool showPrevNext;

  /// Creates a pagination row.
  const OctoPagination({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onPageChanged,
    this.maxVisible = 7,
    this.showPrevNext = true,
  })  : assert(pageCount >= 1, 'pageCount must be >= 1'),
        assert(maxVisible >= 5, 'maxVisible must be >= 5');

  /// Computes which slots to render between Previous and Next.
  ///
  /// `null` entries represent ellipsis tokens. Public so callers (and
  /// tests) can predict the rendered slot sequence without diving into
  /// the widget tree.
  static List<int?> computeSlots({
    required int currentPage,
    required int pageCount,
    required int maxVisible,
  }) {
    if (pageCount <= maxVisible) {
      return [for (var i = 1; i <= pageCount; i++) i];
    }
    // Always keep first and last. Reserve two slots for ellipsis on
    // either side and centre the rest around currentPage.
    final pages = <int>{1, pageCount};
    // Show currentPage and neighbours.
    for (var offset = -1; offset <= 1; offset++) {
      final p = currentPage + offset;
      if (p >= 1 && p <= pageCount) pages.add(p);
    }
    // Fill until we hit maxVisible (counting ellipsis slots — but we
    // don't know yet, so we widen the centre window until close enough).
    var radius = 1;
    while (true) {
      final probe = {1, pageCount};
      for (var offset = -radius; offset <= radius; offset++) {
        final p = currentPage + offset;
        if (p >= 1 && p <= pageCount) probe.add(p);
      }
      final ordered = probe.toList()..sort();
      final slots = <int?>[];
      for (var i = 0; i < ordered.length; i++) {
        if (i > 0 && ordered[i] - ordered[i - 1] > 1) slots.add(null);
        slots.add(ordered[i]);
      }
      if (slots.length >= maxVisible) {
        // Trim back to the previous radius if we overshot.
        if (slots.length > maxVisible && radius > 1) {
          radius -= 1;
          continue;
        }
        return slots;
      }
      radius += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final slots = computeSlots(
      currentPage: currentPage,
      pageCount: pageCount,
      maxVisible: maxVisible,
    );

    final prevEnabled = currentPage > 1;
    final nextEnabled = currentPage < pageCount;

    return Semantics(
      container: true,
      label: 'Pagination',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPrevNext)
            _PaginationTile(
              icon: OctIcons.chevron_left_16,
              semanticLabel: 'Previous page',
              enabled: prevEnabled,
              onPressed: () => onPageChanged(currentPage - 1),
            ),
          for (final slot in slots)
            slot == null
                ? _PaginationEllipsis(color: theme.colors.fg.muted)
                : _PaginationTile(
                    label: '$slot',
                    selected: slot == currentPage,
                    semanticLabel: 'Page $slot',
                    onPressed: slot == currentPage ? null : () => onPageChanged(slot),
                  ),
          if (showPrevNext)
            _PaginationTile(
              icon: OctIcons.chevron_right_16,
              semanticLabel: 'Next page',
              enabled: nextEnabled,
              onPressed: () => onPageChanged(currentPage + 1),
            ),
        ],
      ),
    );
  }
}

class _PaginationTile extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;
  final String semanticLabel;

  const _PaginationTile({
    this.label,
    this.icon,
    this.selected = false,
    this.enabled = true,
    required this.onPressed,
    required this.semanticLabel,
  }) : assert(label != null || icon != null, 'either label or icon required');

  @override
  State<_PaginationTile> createState() => _PaginationTileState();
}

class _PaginationTileState extends State<_PaginationTile> {
  late final WidgetStatesController _states;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (!widget.enabled || widget.onPressed == null) WidgetState.disabled,
      if (widget.selected) WidgetState.selected,
    });
  }

  @override
  void didUpdateWidget(_PaginationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, !widget.enabled || widget.onPressed == null);
    _states.update(WidgetState.selected, widget.selected);
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  bool get _interactive => widget.enabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));

    final fgDefault = theme.colors.fg.defaultColor;
    final fgDisabled = theme.colors.fg.subtle;
    final fgSelected = theme.colors.fg.onEmphasis;
    final bgSelected = theme.colors.accent.emphasis;

    Color resolveFg() {
      if (!widget.enabled) return fgDisabled;
      if (widget.selected) return fgSelected;
      return fgDefault;
    }

    final fg = resolveFg();

    final body = SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: widget.icon != null
            ? Icon(widget.icon, size: 16, color: fg)
            : OctoText(widget.label!, kind: OctoTextKind.labelSmall, color: fg),
      ),
    );

    final decoratedBody = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.selected ? bgSelected : null,
        borderRadius: radius,
      ),
      child: body,
    );

    return Semantics(
      container: true,
      button: true,
      enabled: _interactive,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: ExcludeSemantics(
        child: _interactive
            ? MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => _states.update(WidgetState.hovered, true),
                onExit: (_) => _states.update(WidgetState.hovered, false),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onPressed,
                  onTapDown: (_) => _states.update(WidgetState.pressed, true),
                  onTapUp: (_) => _states.update(WidgetState.pressed, false),
                  onTapCancel: () => _states.update(WidgetState.pressed, false),
                  child: ListenableBuilder(
                    listenable: _states,
                    builder: (_, __) => OctoFocusRing(
                      enabled: _states.value.contains(WidgetState.focused),
                      borderRadius: radius,
                      child: OctoStateLayer(
                        states: _states.value,
                        borderRadius: radius,
                        child: decoratedBody,
                      ),
                    ),
                  ),
                ),
              )
            : decoratedBody,
      ),
    );
  }
}

class _PaginationEllipsis extends StatelessWidget {
  final Color color;

  const _PaginationEllipsis({required this.color});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: OctoText('…', kind: OctoTextKind.labelSmall, color: color),
        ),
      ),
    );
  }
}
