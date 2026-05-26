import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_label',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'all_variants',
        builder: () => const _Sampler(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OctoLabel('Bug'),
              OctoLabel('Feature', variant: OctoLabelVariant.accent),
              OctoLabel('Merged', variant: OctoLabelVariant.success),
              OctoLabel('Review', variant: OctoLabelVariant.attention),
              OctoLabel('Critical', variant: OctoLabelVariant.danger),
            ],
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
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
