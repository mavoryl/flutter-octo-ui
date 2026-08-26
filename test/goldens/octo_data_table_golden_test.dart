import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

class _Service {
  final String name;
  final String owner;
  final int p95;
  final String health;
  final OctoStateLabelVariant status;
  final IconData icon;
  const _Service(
    this.name,
    this.owner,
    this.p95,
    this.health,
    this.status,
    this.icon,
  );
}

// The variant's default icon is lifecycle-shaped (a pull-request glyph), which
// reads oddly next to "Healthy" — so each row names its own.
const _rows = [
  _Service(
    'checkout-api',
    'payments',
    142,
    'Healthy',
    OctoStateLabelVariant.open,
    OctIcons.check_circle_16,
  ),
  _Service(
    'search-indexer',
    'discovery',
    890,
    'Degraded',
    OctoStateLabelVariant.attention,
    OctIcons.alert_16,
  ),
  _Service(
    'image-resizer',
    'media',
    0,
    'Down',
    OctoStateLabelVariant.closed,
    OctIcons.x_circle_16,
  ),
  _Service(
    'billing-worker',
    'payments',
    210,
    'Maintenance',
    OctoStateLabelVariant.draft,
    OctIcons.tools_16,
  ),
];

List<OctoDataColumn<_Service>> _buildColumns() => [
      // Service is the wide flex column — it soaks up the leftover space
      // while every other column hugs its content via IntrinsicColumnWidth.
      OctoDataColumn<_Service>(
        label: 'Service',
        text: (r) => r.name,
        sortable: true,
        flex: 1,
      ),
      OctoDataColumn<_Service>(
        label: 'Status',
        cell: (_, r) => OctoStateLabel(
          label: r.health,
          variant: r.status,
          icon: r.icon,
          emphasis: OctoStateLabelEmphasis.low,
        ),
      ),
      OctoDataColumn<_Service>(label: 'Team', text: (r) => r.owner),
      OctoDataColumn<_Service>(
        label: 'p95 ms',
        text: (r) => '${r.p95}',
        alignment: OctoDataColumnAlignment.end,
        sortable: true,
      ),
    ];

void main() {
  matrixGolden(
    'octo_data_table',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => _Sampler(
          child: SizedBox(
            width: 640,
            child: OctoDataTable<_Service>(columns: _buildColumns(), rows: _rows),
          ),
        ),
      ),
      MatrixScenario(
        'sorted_desc',
        builder: () => _Sampler(
          child: SizedBox(
            width: 640,
            child: OctoDataTable<_Service>(
              columns: _buildColumns(),
              rows: _rows,
              sortColumnIndex: 3,
              sortDirection: OctoSortDirection.desc,
            ),
          ),
        ),
      ),
      MatrixScenario(
        'compact',
        builder: () => _Sampler(
          child: SizedBox(
            width: 640,
            child: OctoDataTable<_Service>(
              columns: _buildColumns(),
              rows: _rows,
              density: OctoDataTableDensity.compact,
              zebra: false,
            ),
          ),
        ),
      ),
      MatrixScenario(
        'empty',
        builder: () => _Sampler(
          child: SizedBox(
            width: 640,
            child: OctoDataTable<_Service>(
              columns: _buildColumns(),
              rows: const [],
              emptyMessage: 'No PRs match the filter',
            ),
          ),
        ),
      ),
    ],
    axes: MatrixAxes(
      themes: octoThemes,
      // DataTable is wide — phoneSmall (320 px) crams cells to a single
      // character per column. Use a tablet-landscape viewport so the
      // golden reflects how the component is actually consumed (admin
      // panels, devtools).
      devices: [MatrixDevice.tabletLandscape],
    ),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

class _Sampler extends StatelessWidget {
  final Widget child;

  const _Sampler({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Align(alignment: Alignment.topLeft, child: child),
      );
}
