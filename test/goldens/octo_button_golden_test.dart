import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_button',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'variants',
        builder: () => _Sampler(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoButton.label('Save', onPressed: _noop, variant: OctoButtonVariant.primary),
              OctoButton.label('Cancel', onPressed: _noop),
              OctoButton.label('Delete', onPressed: _noop, variant: OctoButtonVariant.danger),
              OctoButton.label('Edit', onPressed: _noop, variant: OctoButtonVariant.invisible),
              OctoButton.label('Submit', onPressed: null),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'sizes',
        builder: () => _Sampler(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoButton.label('Small', onPressed: _noop, size: OctoButtonSize.small),
              OctoButton.label('Medium', onPressed: _noop),
              OctoButton.label('Large', onPressed: _noop, size: OctoButtonSize.large),
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

void _noop() {}

class _Sampler extends StatelessWidget {
  final Widget child;

  const _Sampler({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Align(alignment: Alignment.topLeft, child: child),
      );
}
