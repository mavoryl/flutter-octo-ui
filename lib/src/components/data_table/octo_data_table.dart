import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/components/data_table/octo_data_column.dart';
import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Sort state for a single column.
enum OctoSortDirection {
  /// Ascending (A → Z, low → high).
  asc,

  /// Descending (Z → A, high → low).
  desc,

  /// Not currently sorted by this column.
  none,
}

/// Density preset — controls vertical padding inside cells.
enum OctoDataTableDensity {
  /// Comfortable rows — readable for body content.
  comfortable,

  /// Compact rows — dense admin lists.
  compact,
}

/// Tabular data presenter (Primer "DataTable") generic over the row
/// type [T].
///
/// Columns are described via [OctoDataColumn] with a typed accessor or
/// custom cell builder. Headers can opt into sorting; the table itself
/// is *presentation only* — it does not reorder [rows] internally.
/// Wire [sortColumnIndex] / [sortDirection] + [onSortChanged] to the
/// parent and sort the underlying list there.
///
/// Layout is delegated to Flutter's `Table` widget so columns honour
/// `IntrinsicColumnWidth` by default — set [OctoDataColumn.width] for a
/// fixed-pixel column or [OctoDataColumn.flex] for the column that
/// should soak up the leftover horizontal space (usually the title /
/// subject column).
///
/// ```dart
/// OctoDataTable<Issue>(
///   rows: issues,
///   sortColumnIndex: _sortColumn,
///   sortDirection: _sortDirection,
///   onSortChanged: _sort,
///   columns: [
///     OctoDataColumn(label: '#', text: (i) => '#${i.number}', width: 64),
///     OctoDataColumn(label: 'Title', text: (i) => i.title, flex: 1, sortable: true),
///     OctoDataColumn(
///       label: 'Status',
///       cell: (context, i) => OctoStateLabel(
///         label: i.state,
///         variant: OctoStateLabelVariant.open,
///       ),
///     ),
///   ],
/// )
/// ```
///
/// **Variants** — [zebra] alternates row backgrounds for scanning wide rows;
/// [emptyMessage] replaces the body when [rows] is empty.
///
/// **Sizes** — [OctoDataTableDensity]: `comfortable` for body content,
/// `compact` for dense admin lists.
///
/// **States** — sortable headers track hover and focus; rows track hover when
/// [onRowTap] is set. Sorting itself is external: the table renders the
/// direction it is told and calls [onSortChanged], it never reorders [rows].
///
/// **Accessibility** — the table is one semantic container labelled
/// `Data table`. A sortable header announces itself as a button labelled
/// `<column>, sortable` and activates from the keyboard; non-sortable headers
/// are excluded from semantics so screen-reader users are not walked through
/// inert text. Cell content keeps whatever semantics its own widgets expose.
///
/// See also:
///
///  * [OctoDataColumn], for describing one column.
///  * [OctoEmptyState], for a richer empty view than [emptyMessage].
class OctoDataTable<T> extends StatelessWidget {
  /// Column descriptors. Order matters — left to right.
  final List<OctoDataColumn<T>> columns;

  /// Row data in display order.
  final List<T> rows;

  /// Active sort column (0-based) or `null` when unsorted.
  final int? sortColumnIndex;

  /// Current sort direction for [sortColumnIndex].
  final OctoSortDirection sortDirection;

  /// Fires when the user activates a sortable header. The receiver is
  /// expected to update its sort state and re-sort [rows].
  final void Function(int columnIndex, OctoSortDirection direction)? onSortChanged;

  /// Optional tap handler for a row — used to wire row-level
  /// navigation (open detail page).
  final void Function(T row)? onRowTap;

  /// When `true`, alternate rows use `neutral.subtle` background.
  final bool zebra;

  /// Density preset. See [OctoDataTableDensity].
  final OctoDataTableDensity density;

  /// Optional empty-state message rendered when [rows] is empty.
  final String emptyMessage;

  /// Creates a data table.
  const OctoDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortDirection = OctoSortDirection.none,
    this.onSortChanged,
    this.onRowTap,
    this.zebra = true,
    this.density = OctoDataTableDensity.comfortable,
    this.emptyMessage = 'No data',
  });

  Map<int, TableColumnWidth> _columnWidths() {
    final widths = <int, TableColumnWidth>{};
    for (var i = 0; i < columns.length; i++) {
      final col = columns[i];
      if (col.width != null) {
        widths[i] = FixedColumnWidth(col.width!);
      } else if (col.flex != null && col.flex! > 0) {
        widths[i] = FlexColumnWidth(col.flex!.toDouble());
      } else {
        widths[i] = const IntrinsicColumnWidth();
      }
    }
    return widths;
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));

    return Semantics(
      container: true,
      label: 'Data table',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border.muted),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Table(
                columnWidths: _columnWidths(),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _headerRow(theme),
                  if (rows.isNotEmpty)
                    for (var i = 0; i < rows.length; i++) _dataRow(theme, i),
                ],
              ),
              if (rows.isEmpty) _EmptyState(message: emptyMessage, theme: theme),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _headerRow(OctoThemeData theme) {
    return TableRow(
      decoration: BoxDecoration(
        color: theme.colors.canvas.subtle,
        border: Border(bottom: BorderSide(color: theme.colors.border.muted)),
      ),
      children: [
        for (var i = 0; i < columns.length; i++)
          _HeaderCell<T>(
            column: columns[i],
            columnIndex: i,
            isSorted: sortColumnIndex == i,
            direction: sortDirection,
            onSortChanged: onSortChanged,
            density: density,
            theme: theme,
          ),
      ],
    );
  }

  TableRow _dataRow(OctoThemeData theme, int index) {
    final row = rows[index];
    final isLast = index == rows.length - 1;
    final bg = zebra && index.isOdd ? theme.colors.neutral.subtle : null;
    return TableRow(
      decoration: BoxDecoration(
        color: bg,
        border: isLast ? null : Border(bottom: BorderSide(color: theme.colors.border.muted)),
      ),
      children: [
        for (final col in columns)
          _DataCell<T>(
            column: col,
            row: row,
            density: density,
            theme: theme,
            onTap: onRowTap == null ? null : () => onRowTap!(row),
          ),
      ],
    );
  }
}

class _HeaderCell<T> extends StatefulWidget {
  final OctoDataColumn<T> column;
  final int columnIndex;
  final bool isSorted;
  final OctoSortDirection direction;
  final void Function(int columnIndex, OctoSortDirection direction)? onSortChanged;
  final OctoDataTableDensity density;
  final OctoThemeData theme;

  const _HeaderCell({
    required this.column,
    required this.columnIndex,
    required this.isSorted,
    required this.direction,
    required this.onSortChanged,
    required this.density,
    required this.theme,
  });

  @override
  State<_HeaderCell<T>> createState() => _HeaderCellState<T>();
}

class _HeaderCellState<T> extends State<_HeaderCell<T>> {
  late final WidgetStatesController _states;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _states.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  OctoSortDirection get _nextDirection {
    if (!widget.isSorted) return OctoSortDirection.asc;
    switch (widget.direction) {
      case OctoSortDirection.asc:
        return OctoSortDirection.desc;
      case OctoSortDirection.desc:
        return OctoSortDirection.none;
      case OctoSortDirection.none:
        return OctoSortDirection.asc;
    }
  }

  void _activate() {
    if (!widget.column.sortable) return;
    widget.onSortChanged?.call(widget.columnIndex, _nextDirection);
  }

  IconData? _sortIcon() {
    if (!widget.isSorted) return null;
    switch (widget.direction) {
      case OctoSortDirection.asc:
        return OctIcons.triangle_up_16;
      case OctoSortDirection.desc:
        return OctIcons.triangle_down_16;
      case OctoSortDirection.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final align = _mainAxisAlign(widget.column.alignment);
    final pad = _vPad(widget.density, widget.theme);
    final label = IconTheme(
      data: IconThemeData(color: widget.theme.colors.fg.muted, size: 14),
      child: widget.column.header ??
          OctoText(
            widget.column.label,
            kind: OctoTextKind.bodyEmphasis,
            color: widget.theme.colors.fg.muted,
          ),
    );
    final icon = _sortIcon();
    final content = Row(
      mainAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: label),
        if (icon != null) ...[
          SizedBox(width: widget.theme.spacing.gap.xs),
          Icon(icon, size: 12, color: widget.theme.colors.fg.muted),
        ],
      ],
    );

    final padded = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.theme.spacing.gap.md,
        vertical: pad,
      ),
      child: content,
    );

    if (!widget.column.sortable) {
      return ExcludeSemantics(child: padded);
    }

    return Semantics(
      button: true,
      label: '${widget.column.label}, sortable',
      child: FocusableActionDetector(
        focusNode: _focusNode,
        mouseCursor: SystemMouseCursors.click,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
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
          onTap: _activate,
          child: ListenableBuilder(
            listenable: _states,
            builder: (_, __) {
              final focused = _states.value.contains(WidgetState.focused);
              return OctoFocusRing(
                enabled: focused,
                borderRadius: BorderRadius.zero,
                child: OctoStateLayer(
                  states: _states.value,
                  borderRadius: BorderRadius.zero,
                  child: padded,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DataCell<T> extends StatelessWidget {
  final OctoDataColumn<T> column;
  final T row;
  final OctoDataTableDensity density;
  final OctoThemeData theme;
  final VoidCallback? onTap;

  const _DataCell({
    required this.column,
    required this.row,
    required this.density,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pad = _vPad(density, theme);
    final cellContent = column.cell != null
        ? column.cell!(context, row)
        : OctoText(
            column.text!(row),
            color: theme.colors.fg.defaultColor,
          );

    final padded = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.gap.md,
        vertical: pad,
      ),
      child: Align(alignment: _alignment(column.alignment), child: cellContent),
    );

    if (onTap == null) return padded;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: padded,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final OctoThemeData theme;

  const _EmptyState({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.gap.md,
        vertical: theme.spacing.gap.lg,
      ),
      child: Center(
        child: OctoText(message, color: theme.colors.fg.muted),
      ),
    );
  }
}

double _vPad(OctoDataTableDensity density, OctoThemeData theme) {
  switch (density) {
    case OctoDataTableDensity.comfortable:
      return theme.spacing.gap.sm;
    case OctoDataTableDensity.compact:
      return theme.spacing.scale(1);
  }
}

MainAxisAlignment _mainAxisAlign(OctoDataColumnAlignment a) {
  switch (a) {
    case OctoDataColumnAlignment.start:
      return MainAxisAlignment.start;
    case OctoDataColumnAlignment.center:
      return MainAxisAlignment.center;
    case OctoDataColumnAlignment.end:
      return MainAxisAlignment.end;
  }
}

AlignmentGeometry _alignment(OctoDataColumnAlignment a) {
  switch (a) {
    case OctoDataColumnAlignment.start:
      return AlignmentDirectional.centerStart;
    case OctoDataColumnAlignment.center:
      return Alignment.center;
    case OctoDataColumnAlignment.end:
      return AlignmentDirectional.centerEnd;
  }
}
