import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_text_field',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const _Pad(child: OctoTextField(placeholder: 'username')),
      ),
      MatrixScenario(
        'with_label',
        builder: () => const _Pad(
          child: OctoTextField(label: 'Email', placeholder: 'you@example.com'),
        ),
      ),
      MatrixScenario(
        'with_helper',
        builder: () => const _Pad(
          child: OctoTextField(
            label: 'Email',
            placeholder: 'you@example.com',
            helperText: 'Used for login only',
          ),
        ),
      ),
      MatrixScenario(
        'with_error',
        builder: () => const _Pad(
          child: OctoTextField(
            label: 'Email',
            placeholder: 'you@example.com',
            errorText: 'Invalid email address',
          ),
        ),
      ),
      MatrixScenario(
        'disabled',
        builder: () => const _Pad(
          child: OctoTextField(label: 'Email', placeholder: 'you@example.com', enabled: false),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

class _Pad extends StatelessWidget {
  final Widget child;

  const _Pad({required this.child});

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(24), child: child);
}
