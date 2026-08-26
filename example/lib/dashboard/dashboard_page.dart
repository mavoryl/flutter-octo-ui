import 'package:flutter/material.dart';
import 'package:octo_ui/octo_ui.dart';

import 'package:octo_ui_example/dashboard/demo_data.dart';

/// Service-monitoring dashboard — the showcase screen for `octo_ui`.
///
/// Built to look like a tool someone would actually keep open: dense table,
/// live-ish status, filters that really filter. Three layout decisions are
/// driven by the responsive layer rather than by a fixed width:
///
///   * the KPI row goes 1 / 2 / 4 columns via [OctoResponsiveBuilder];
///   * the sidebar collapses into a popover below `lg`;
///   * the table drops its latency / error columns below `md`.
class DashboardPage extends StatefulWidget {
  /// `true` while the dark palette is active.
  final bool isDark;

  /// `true` while the high-contrast palette is active.
  final bool isHighContrast;

  /// Flips light / dark.
  final VoidCallback onToggleTheme;

  /// Flips standard / high contrast.
  final VoidCallback onToggleHighContrast;

  /// Opens the command palette.
  final VoidCallback onOpenPalette;

  /// Switches to the kitchen-sink screen.
  final VoidCallback onOpenKitchenSink;

  /// Creates the dashboard screen.
  const DashboardPage({
    super.key,
    required this.isDark,
    required this.isHighContrast,
    required this.onToggleTheme,
    required this.onToggleHighContrast,
    required this.onOpenPalette,
    required this.onOpenKitchenSink,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _search = TextEditingController();
  final OctoOverlayController _navPopover = OctoOverlayController();

  String _query = '';
  ServiceHealth? _health;
  Environment _environment = Environment.production;
  int _navIndex = 0;
  int? _sortColumn;
  OctoSortDirection _sortDirection = OctoSortDirection.none;

  @override
  void dispose() {
    _search.dispose();
    _navPopover.dispose();
    super.dispose();
  }

  int get _activeFilterCount =>
      (_query.isEmpty ? 0 : 1) +
      (_health == null ? 0 : 1) +
      (_environment == Environment.production ? 0 : 1);

  List<ServiceRow> get _rows {
    final query = _query.trim().toLowerCase();
    final filtered = demoServices.where((s) {
      if (s.environment != _environment) return false;
      if (_health != null && s.health != _health) return false;
      if (query.isEmpty) return true;
      return s.name.toLowerCase().contains(query) ||
          s.team.toLowerCase().contains(query);
    }).toList();

    if (_sortColumn == null || _sortDirection == OctoSortDirection.none) {
      return filtered;
    }
    filtered.sort((a, b) {
      final byColumn = switch (_sortColumn) {
        0 => a.name.compareTo(b.name),
        3 => a.p95Ms.compareTo(b.p95Ms),
        4 => a.errorRate.compareTo(b.errorRate),
        _ => 0,
      };
      return _sortDirection == OctoSortDirection.asc ? byColumn : -byColumn;
    });
    return filtered;
  }

  void _clearFilters() => setState(() {
        _search.clear();
        _query = '';
        _health = null;
        _environment = Environment.production;
      });

  void _acknowledge(ServiceRow row) => OctoToast.show(
        context,
        message: 'Acknowledged ${row.name}',
        variant: OctoToastVariant.success,
        action: OctoToastAction(label: 'Undo', onPressed: () {}),
      );

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final wide = context.isAtLeast(OctoBreakpoint.lg);

    return Scaffold(
      backgroundColor: theme.colors.canvas.defaultColor,
      appBar: AppBar(
        backgroundColor: theme.colors.canvas.subtle,
        surfaceTintColor: theme.colors.canvas.subtle,
        elevation: 0,
        shape:
            Border(bottom: BorderSide(color: theme.colors.border.defaultColor)),
        titleSpacing: theme.spacing.gap.md,
        title: Row(
          children: [
            if (!wide) ...[_navMenu(), SizedBox(width: theme.spacing.gap.sm)],
            const OctoIcon(OctIcons.pulse_16),
            SizedBox(width: theme.spacing.gap.sm),
            const Flexible(
              child: OctoText(
                'Service health',
                kind: OctoTextKind.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          OctoIconButton(
            icon: OctIcons.search_16,
            onPressed: widget.onOpenPalette,
            variant: OctoButtonVariant.invisible,
            semanticLabel: 'Open command palette',
          ),
          OctoIconButton(
            icon: widget.isDark ? OctIcons.sun_16 : OctIcons.moon_16,
            onPressed: widget.onToggleTheme,
            variant: OctoButtonVariant.invisible,
            semanticLabel: widget.isDark
                ? 'Switch to light theme'
                : 'Switch to dark theme',
          ),
          OctoIconButton(
            icon: widget.isHighContrast
                ? OctIcons.accessibility_16
                : OctIcons.accessibility_inset_16,
            onPressed: widget.onToggleHighContrast,
            variant: OctoButtonVariant.invisible,
            semanticLabel: widget.isHighContrast
                ? 'Switch to standard contrast'
                : 'Switch to high contrast',
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing.gap.md),
            child: OctoButton.label(
              'Kitchen sink',
              onPressed: widget.onOpenKitchenSink,
              size: OctoButtonSize.small,
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.canvas.subtle,
                border: Border(
                    right: BorderSide(color: theme.colors.border.defaultColor)),
              ),
              child: SizedBox(
                width: 240,
                child: Padding(
                  padding: EdgeInsets.all(theme.spacing.inset.md),
                  child: _sideNav(),
                ),
              ),
            ),
          Expanded(child: _content(theme)),
        ],
      ),
    );
  }

  Widget _navMenu() => OctoPopover(
        controller: _navPopover,
        semanticLabel: 'Sections',
        content: SizedBox(
          width: 220,
          child: OctoActionList(
            items: [
              for (var i = 0; i < _navLabels.length; i++)
                OctoActionListItem(
                  label: _navLabels[i],
                  leading: Icon(_navIcons[i]),
                  selected: i == _navIndex,
                  onPressed: () {
                    setState(() => _navIndex = i);
                    _navPopover.close();
                  },
                ),
            ],
          ),
        ),
        child: OctoIconButton(
          icon: OctIcons.three_bars_16,
          onPressed: _navPopover.toggle,
          variant: OctoButtonVariant.invisible,
          semanticLabel: 'Sections',
        ),
      );

  Widget _sideNav() => OctoSideNav(
        selectedIndex: _navIndex,
        onChanged: (i) => setState(() => _navIndex = i),
        items: [
          for (var i = 0; i < _navLabels.length; i++)
            OctoSideNavItem(
              label: _navLabels[i],
              icon: Icon(_navIcons[i]),
              trailing: i == 2 ? const OctoCounterLabel(3) : null,
            ),
        ],
      );

  Widget _content(OctoThemeData theme) {
    final rows = _rows;
    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.spacing.inset.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(theme),
          SizedBox(height: theme.spacing.gap.lg),
          _kpiRow(theme),
          SizedBox(height: theme.spacing.gap.xl),
          _filters(theme),
          SizedBox(height: theme.spacing.gap.lg),
          if (rows.isEmpty)
            OctoCard(
              padding: EdgeInsets.all(theme.spacing.inset.xl),
              child: OctoEmptyState(
                icon: OctIcons.search_24,
                title: 'No services match these filters',
                description:
                    'Widen the environment, drop the health filter, or clear the search.',
                actions: [
                  OctoButton.label(
                    'Clear filters',
                    onPressed: _clearFilters,
                    variant: OctoButtonVariant.primary,
                  ),
                ],
              ),
            )
          else
            _table(theme, rows),
          SizedBox(height: theme.spacing.gap.xl),
          _incidents(theme),
        ],
      ),
    );
  }

  Widget _header(OctoThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OctoBreadcrumbs(
            items: [
              OctoBreadcrumbItem(label: 'Platform', onPressed: () {}),
              OctoBreadcrumbItem(label: _environment.label, onPressed: () {}),
              OctoBreadcrumbItem(label: _navLabels[_navIndex]),
            ],
          ),
          SizedBox(height: theme.spacing.gap.md),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: theme.spacing.gap.lg,
            runSpacing: theme.spacing.gap.md,
            children: [
              const OctoText('8 services · 3 open incidents',
                  kind: OctoTextKind.bodyEmphasis),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OctoText(
                    'On call',
                    kind: OctoTextKind.bodySmall,
                    color: theme.colors.fg.muted,
                  ),
                  SizedBox(width: theme.spacing.gap.sm),
                  const OctoAvatarStack(avatars: _onCall, maxVisible: 3),
                ],
              ),
            ],
          ),
        ],
      );

  Widget _kpiRow(OctoThemeData theme) => OctoResponsiveBuilder(
        builder: (context, breakpoint) {
          final columns = switch (breakpoint) {
            OctoBreakpoint.xs || OctoBreakpoint.sm => 1,
            OctoBreakpoint.md => 2,
            _ => 4,
          };
          final gap = theme.spacing.gap.md;
          return LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final kpi in _kpis)
                    SizedBox(width: width, child: _kpiCard(theme, kpi)),
                ],
              );
            },
          );
        },
      );

  Widget _kpiCard(OctoThemeData theme, _Kpi kpi) => OctoCard(
        variant: OctoCardVariant.elevated,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            OctoText(kpi.label,
                kind: OctoTextKind.bodySmall, color: theme.colors.fg.muted),
            SizedBox(height: theme.spacing.gap.xs),
            OctoText(kpi.value, kind: OctoTextKind.heading),
            SizedBox(height: theme.spacing.gap.sm),
            OctoLabel(kpi.delta, variant: kpi.variant),
          ],
        ),
      );

  Widget _filters(OctoThemeData theme) => OctoFilterBar(
        searchController: _search,
        searchPlaceholder: 'Find a service or team',
        semanticLabel: 'Service filters',
        onSearchChanged: (v) => setState(() => _query = v),
        activeFilterCount: _activeFilterCount,
        onClear: _activeFilterCount == 0 ? null : _clearFilters,
        filters: [
          OctoDropdown<ServiceHealth?>(
            value: _health,
            placeholder: 'Any health',
            onChanged: (v) => setState(() => _health = v),
            items: [
              const OctoDropdownItem(value: null, label: 'Any health'),
              for (final h in ServiceHealth.values)
                OctoDropdownItem(value: h, label: h.label),
            ],
          ),
          OctoSegmentedControl<Environment>(
            value: _environment,
            onChanged: (v) => setState(() => _environment = v),
            items: [
              for (final env in Environment.values)
                OctoSegmentedControlItem(value: env, label: env.label),
            ],
          ),
        ],
      );

  Widget _table(OctoThemeData theme, List<ServiceRow> rows) =>
      OctoResponsiveBuilder(
        builder: (context, breakpoint) {
          // Below `md` the latency and error columns are the first to go —
          // status and ownership are what a phone-sized glance needs.
          final dense = breakpoint.isAtMost(OctoBreakpoint.sm);
          return OctoDataTable<ServiceRow>(
            rows: rows,
            sortColumnIndex: _sortColumn,
            sortDirection: _sortDirection,
            onSortChanged: (column, direction) => setState(() {
              _sortColumn = direction == OctoSortDirection.none ? null : column;
              _sortDirection = direction;
            }),
            onRowTap: _acknowledge,
            zebra: true,
            columns: [
              OctoDataColumn<ServiceRow>(
                label: 'Service',
                sortable: true,
                flex: 3,
                cell: (context, row) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OctoText(row.name, kind: OctoTextKind.bodyEmphasis),
                    OctoText(
                      row.team,
                      kind: OctoTextKind.bodySmall,
                      color: theme.colors.fg.muted,
                    ),
                  ],
                ),
              ),
              OctoDataColumn<ServiceRow>(
                label: 'Status',
                flex: 2,
                cell: (context, row) => OctoStateLabel(
                  label: row.health.label,
                  variant: row.health.badge,
                ),
              ),
              if (!dense) ...[
                OctoDataColumn<ServiceRow>(
                  label: 'p95',
                  sortable: true,
                  alignment: OctoDataColumnAlignment.end,
                  flex: 2,
                  text: (row) => row.health == ServiceHealth.down
                      ? '—'
                      : '${row.p95Ms} ms',
                ),
                OctoDataColumn<ServiceRow>(
                  label: 'Errors',
                  sortable: true,
                  alignment: OctoDataColumnAlignment.end,
                  flex: 2,
                  text: (row) => '${(row.errorRate * 100).toStringAsFixed(2)}%',
                ),
              ],
              OctoDataColumn<ServiceRow>(
                label: 'On call',
                flex: 2,
                cell: (context, row) =>
                    OctoAvatarStack(avatars: row.owners, maxVisible: 3),
              ),
            ],
          );
        },
      );

  Widget _incidents(OctoThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const OctoText('Incident feed', kind: OctoTextKind.title),
              SizedBox(width: theme.spacing.gap.sm),
              const OctoCounterLabel(4),
            ],
          ),
          SizedBox(height: theme.spacing.gap.md),
          OctoCard(
            child: OctoTimeline(
              items: [
                for (final event in demoIncidents)
                  OctoTimelineItem(
                    icon: event.icon,
                    title: event.title,
                    subtitle: event.when,
                    variant: event.variant,
                    body: OctoText(
                      event.detail,
                      kind: OctoTextKind.bodySmall,
                      color: theme.colors.fg.muted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
}

const _navLabels = ['Overview', 'Services', 'Incidents', 'Alerts', 'Settings'];

const _navIcons = [
  OctIcons.pulse_16,
  OctIcons.server_16,
  OctIcons.alert_16,
  OctIcons.bell_16,
  OctIcons.gear_16,
];

const _onCall = [
  OctoAvatar(initials: 'AK', size: OctoAvatarSize.sm, semanticLabel: 'Ann Kim'),
  OctoAvatar(
      initials: 'BR', size: OctoAvatarSize.sm, semanticLabel: 'Bo Reyes'),
  OctoAvatar(
      initials: 'CN', size: OctoAvatarSize.sm, semanticLabel: 'Cleo Nunes'),
  OctoAvatar(
      initials: 'DV', size: OctoAvatarSize.sm, semanticLabel: 'Dev Patel'),
];

class _Kpi {
  final String label;
  final String value;
  final String delta;
  final OctoLabelVariant variant;

  const _Kpi(this.label, this.value, this.delta, this.variant);
}

const _kpis = [
  _Kpi('Uptime (30d)', '99.95%', '+0.02 pt', OctoLabelVariant.success),
  _Kpi('p95 latency', '243 ms', '+61 ms', OctoLabelVariant.attention),
  _Kpi('Error rate', '0.42%', '+0.31 pt', OctoLabelVariant.danger),
  _Kpi('Open incidents', '3', '2 critical', OctoLabelVariant.accent),
];
