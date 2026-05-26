import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_tabs',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'overview',
        builder: () => _Sampler(
          child: OctoTabs(
            tabs: const [
              OctoUnderlineNavItem(label: 'Overview'),
              OctoUnderlineNavItem(label: 'Issues'),
              OctoUnderlineNavItem(label: 'Pull requests'),
            ],
            children: const [
              _Panel(text: 'Repository overview goes here.'),
              _Panel(text: 'Open issues live in this panel.'),
              _Panel(text: 'Pending pull requests show up here.'),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'issues_selected',
        builder: () => _Sampler(
          child: OctoTabs(
            initialIndex: 1,
            tabs: const [
              OctoUnderlineNavItem(label: 'Overview'),
              OctoUnderlineNavItem(label: 'Issues'),
              OctoUnderlineNavItem(label: 'Pull requests'),
            ],
            children: const [
              _Panel(text: 'Repository overview goes here.'),
              _Panel(text: 'Open issues live in this panel.'),
              _Panel(text: 'Pending pull requests show up here.'),
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

class _Panel extends StatelessWidget {
  final String text;

  const _Panel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: OctoText(text),
    );
  }
}
