import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noop(Object? _) {}

void main() {
  matrixGolden(
    'octo_form_controls',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'switches',
        builder: () => const _Sampler(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              OctoSwitch(value: false, onChanged: _noop),
              OctoSwitch(value: true, onChanged: _noop),
              OctoSwitch(value: false, onChanged: null),
              OctoSwitch(value: true, onChanged: null),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'checkboxes',
        builder: () => const _Sampler(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              OctoCheckbox(value: false, onChanged: _noop),
              OctoCheckbox(value: true, onChanged: _noop),
              OctoCheckbox(value: null, tristate: true, onChanged: _noop),
              OctoCheckbox(value: false, onChanged: null),
              OctoCheckbox(value: true, onChanged: null),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'radios',
        builder: () => const _Sampler(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              OctoRadio<String>(value: 'a', groupValue: 'a', onChanged: _noop),
              OctoRadio<String>(value: 'b', groupValue: 'a', onChanged: _noop),
              OctoRadio<String>(value: 'c', groupValue: 'c', onChanged: null),
              OctoRadio<String>(value: 'd', groupValue: 'c', onChanged: null),
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
