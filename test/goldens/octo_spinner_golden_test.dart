import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_spinner',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        // Park each spinner via motion-reduce so the snapshot stays
        // deterministic under freezeAnimations.
        builder: () => const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: _Sampler(
            child: SizedBox(
              width: 280,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OctoSpinner(size: OctoSpinnerSize.small),
                  OctoSpinner(),
                  OctoSpinner(size: OctoSpinnerSize.large),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
    freezeAnimations: true,
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
