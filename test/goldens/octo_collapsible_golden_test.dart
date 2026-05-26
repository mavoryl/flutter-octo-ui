import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_collapsible',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                OctoCollapsible(
                  title: 'Collapsed section',
                  child: Text(
                    'Hidden body — only the chevron and title show.',
                  ),
                ),
                SizedBox(height: 12),
                OctoCollapsible(
                  title: 'Expanded section',
                  initiallyExpanded: true,
                  child: Text(
                    'Body content is visible while the chevron points down.',
                  ),
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
