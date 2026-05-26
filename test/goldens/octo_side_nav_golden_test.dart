import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noopInt(int _) {}

void main() {
  matrixGolden(
    'octo_side_nav',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 220,
            child: OctoSideNav(
              selectedIndex: 1,
              onChanged: _noopInt,
              items: [
                OctoSideNavItem(
                  label: 'Repositories',
                  icon: Icon(OctIcons.repo_16),
                ),
                OctoSideNavItem(
                  label: 'Projects',
                  icon: Icon(OctIcons.project_16),
                  trailing: OctoCounterLabel(7),
                ),
                OctoSideNavItem(
                  label: 'Discussions',
                  icon: Icon(OctIcons.comment_discussion_16),
                ),
                OctoSideNavItem(
                  label: 'Insights',
                  icon: Icon(OctIcons.graph_16),
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
