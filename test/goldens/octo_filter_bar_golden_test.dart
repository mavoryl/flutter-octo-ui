import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noop() {}

void main() {
  componentMatrixGolden(
    'octo_filter_bar',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'search_only',
        builder: () => octoComponentWrap(
          const SizedBox(
            width: 640,
            child: OctoFilterBar(searchPlaceholder: 'Find a service'),
          ),
        ),
      ),
      MatrixScenario(
        'with_filters_and_clear',
        builder: () => octoComponentWrap(
          const SizedBox(
            width: 640,
            child: OctoFilterBar(
              searchPlaceholder: 'Find a service',
              activeFilterCount: 2,
              onClear: _noop,
              filters: [
                OctoChip(label: 'severity: high', onDismiss: _noop),
                OctoChip(label: 'env: production', onDismiss: _noop),
              ],
            ),
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}
