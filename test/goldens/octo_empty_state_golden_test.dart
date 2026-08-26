import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noop() {}

void main() {
  componentMatrixGolden(
    'octo_empty_state',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'title_only',
        builder: () => octoComponentWrap(
          const SizedBox(width: 360, child: OctoEmptyState(title: 'No issues yet')),
        ),
      ),
      MatrixScenario(
        'full',
        builder: () => octoComponentWrap(
          SizedBox(
            width: 360,
            child: OctoEmptyState(
              icon: OctIcons.issue_opened_24,
              title: 'No issues yet',
              description: 'Issues let you track work, report bugs, and discuss ideas.',
              actions: [
                OctoButton.label(
                  'New issue',
                  onPressed: _noop,
                  variant: OctoButtonVariant.primary,
                ),
                OctoButton.label('Learn more', onPressed: _noop),
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
