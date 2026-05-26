import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noop() {}

void main() {
  matrixGolden(
    'octo_toast',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                OctoToast(
                  message: 'Repository created',
                  variant: OctoToastVariant.success,
                ),
                SizedBox(height: 12),
                OctoToast(
                  message: 'Heads up — 3 packages need an upgrade',
                  variant: OctoToastVariant.attention,
                ),
                SizedBox(height: 12),
                OctoToast(
                  message: 'Note archived',
                  action: OctoToastAction(label: 'Undo', onPressed: _noop),
                ),
                SizedBox(height: 12),
                OctoToast(
                  message: 'Failed to publish workflow',
                  variant: OctoToastVariant.danger,
                  dismissible: true,
                  onDismiss: _noop,
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
