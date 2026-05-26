import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_progress_bar',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('accent · 25%'),
                SizedBox(height: 6),
                OctoProgressBar(value: 0.25),
                SizedBox(height: 12),
                Text('success · 75%'),
                SizedBox(height: 6),
                OctoProgressBar(
                  value: 0.75,
                  variant: OctoProgressBarVariant.success,
                ),
                SizedBox(height: 12),
                Text('attention · 100%'),
                SizedBox(height: 6),
                OctoProgressBar(
                  value: 1,
                  variant: OctoProgressBarVariant.attention,
                ),
                SizedBox(height: 12),
                Text('danger · small · 40%'),
                SizedBox(height: 6),
                OctoProgressBar(
                  value: 0.4,
                  variant: OctoProgressBarVariant.danger,
                  size: OctoProgressBarSize.small,
                ),
                SizedBox(height: 12),
                Text('indeterminate · motion-reduce → 50% static'),
                SizedBox(height: 6),
                // Force the motion-reduce path so the snapshot is
                // deterministic — without it the animated stripe lives at
                // controller.value = 0 (off-screen) under freezeAnimations.
                MediaQuery(
                  data: MediaQueryData(disableAnimations: true),
                  child: OctoProgressBar(),
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
