import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

const _info = IconData(0xe88e, fontFamily: 'MaterialIcons');

void main() {
  matrixGolden(
    'octo_flash',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'info',
        builder: () => const _Pad(child: OctoFlash(message: 'New release available')),
      ),
      MatrixScenario(
        'success',
        builder: () => const _Pad(
          child: OctoFlash(
            message: 'Saved successfully',
            variant: OctoFlashVariant.success,
            icon: _info,
          ),
        ),
      ),
      MatrixScenario(
        'attention',
        builder: () => const _Pad(
          child: OctoFlash(
            message: 'Review required before merge',
            variant: OctoFlashVariant.attention,
          ),
        ),
      ),
      MatrixScenario(
        'danger',
        builder: () => const _Pad(
          child: OctoFlash(
            message: 'Build failed — see logs',
            variant: OctoFlashVariant.danger,
            icon: _info,
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: const <MatrixReportFormat>{},
  );
}

class _Pad extends StatelessWidget {
  final Widget child;

  const _Pad({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: child,
  );
}
