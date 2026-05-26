import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_timeline',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'default',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 360,
            child: OctoTimeline(
              items: [
                OctoTimelineItem(
                  icon: OctIcons.git_commit_16,
                  title: 'Created branch feature/foo',
                  subtitle: '2 hours ago',
                ),
                OctoTimelineItem(
                  icon: OctIcons.comment_16,
                  title: 'Anna commented',
                  subtitle: '1 hour ago',
                  variant: OctoTimelineVariant.accent,
                  body: Text('LGTM — ship it.'),
                ),
                OctoTimelineItem(
                  icon: OctIcons.git_pull_request_16,
                  title: 'Opened pull request #42',
                  subtitle: '54 minutes ago',
                  variant: OctoTimelineVariant.success,
                ),
                OctoTimelineItem(
                  icon: OctIcons.alert_16,
                  title: 'CI flagged 3 lint warnings',
                  subtitle: '12 minutes ago',
                  variant: OctoTimelineVariant.attention,
                ),
                OctoTimelineItem(
                  icon: OctIcons.x_circle_16,
                  title: 'Deploy to staging failed',
                  subtitle: 'just now',
                  variant: OctoTimelineVariant.danger,
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
