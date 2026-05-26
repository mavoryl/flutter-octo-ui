import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noopInt(int _) {}

void main() {
  matrixGolden(
    'octo_pagination',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'compact',
        builder: () => const _Sampler(
          child: OctoPagination(
            currentPage: 2,
            pageCount: 5,
            onPageChanged: _noopInt,
          ),
        ),
      ),
      MatrixScenario(
        'wide_middle',
        builder: () => const _Sampler(
          child: OctoPagination(
            currentPage: 10,
            pageCount: 20,
            onPageChanged: _noopInt,
          ),
        ),
      ),
      MatrixScenario(
        'wide_start',
        builder: () => const _Sampler(
          child: OctoPagination(
            currentPage: 1,
            pageCount: 20,
            onPageChanged: _noopInt,
          ),
        ),
      ),
      MatrixScenario(
        'wide_end',
        builder: () => const _Sampler(
          child: OctoPagination(
            currentPage: 20,
            pageCount: 20,
            onPageChanged: _noopInt,
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
