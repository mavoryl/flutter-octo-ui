import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_state_label',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('High emphasis'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OctoStateLabel(label: 'Open', variant: OctoStateLabelVariant.open),
                    OctoStateLabel(label: 'Closed', variant: OctoStateLabelVariant.closed),
                    OctoStateLabel(label: 'Merged', variant: OctoStateLabelVariant.merged),
                    OctoStateLabel(label: 'Draft', variant: OctoStateLabelVariant.draft),
                    OctoStateLabel(
                      label: 'Stale',
                      variant: OctoStateLabelVariant.attention,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Low emphasis'),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OctoStateLabel(
                      label: 'Open',
                      variant: OctoStateLabelVariant.open,
                      emphasis: OctoStateLabelEmphasis.low,
                    ),
                    OctoStateLabel(
                      label: 'Closed',
                      variant: OctoStateLabelVariant.closed,
                      emphasis: OctoStateLabelEmphasis.low,
                    ),
                    OctoStateLabel(
                      label: 'Merged',
                      variant: OctoStateLabelVariant.merged,
                      emphasis: OctoStateLabelEmphasis.low,
                    ),
                    OctoStateLabel(
                      label: 'Draft',
                      variant: OctoStateLabelVariant.draft,
                      emphasis: OctoStateLabelEmphasis.low,
                    ),
                  ],
                ),
              ],
            ),
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
