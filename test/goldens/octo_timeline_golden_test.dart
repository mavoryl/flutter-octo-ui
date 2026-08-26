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
                  icon: OctIcons.graph_16,
                  title: 'p95 latency crossed 800 ms',
                  subtitle: '2 hours ago',
                  variant: OctoTimelineVariant.attention,
                ),
                OctoTimelineItem(
                  icon: OctIcons.x_circle_16,
                  title: 'search-indexer stopped responding',
                  subtitle: '1 hour ago',
                  variant: OctoTimelineVariant.danger,
                ),
                OctoTimelineItem(
                  icon: OctIcons.comment_16,
                  title: 'Anna acknowledged the alert',
                  subtitle: '54 minutes ago',
                  variant: OctoTimelineVariant.accent,
                  body: Text('Rolling back to v2.4.1.'),
                ),
                OctoTimelineItem(
                  icon: OctIcons.sync_16,
                  title: 'Rollback finished',
                  subtitle: '12 minutes ago',
                ),
                OctoTimelineItem(
                  icon: OctIcons.check_circle_16,
                  title: 'Error rate back to baseline',
                  subtitle: 'just now',
                  variant: OctoTimelineVariant.success,
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
