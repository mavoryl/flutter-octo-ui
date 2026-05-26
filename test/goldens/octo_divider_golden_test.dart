import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_divider',
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
                Text('Subtle'),
                SizedBox(height: 8),
                OctoDivider(emphasis: OctoDividerEmphasis.subtle),
                SizedBox(height: 16),
                Text('Muted (default)'),
                SizedBox(height: 8),
                OctoDivider(),
                SizedBox(height: 16),
                Text('Strong + indent'),
                SizedBox(height: 8),
                OctoDivider(
                  emphasis: OctoDividerEmphasis.strong,
                  indent: 24,
                  endIndent: 24,
                ),
                SizedBox(height: 16),
                Text('Thickness 4'),
                SizedBox(height: 8),
                OctoDivider(thickness: 4),
                SizedBox(height: 16),
                SizedBox(
                  height: 32,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Center(child: Text('Inline A')),
                      ),
                      OctoDivider.vertical(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Center(child: Text('Inline B')),
                      ),
                    ],
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
