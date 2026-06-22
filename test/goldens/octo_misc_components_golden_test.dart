import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noop() {}

void main() {
  matrixGolden(
    'octo_misc',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'breadcrumbs',
        builder: () => _Sampler(
          child: OctoBreadcrumbs(
            items: const [
              OctoBreadcrumbItem(label: 'mavoryl', onPressed: _noop),
              OctoBreadcrumbItem(label: 'octo_ui', onPressed: _noop),
              OctoBreadcrumbItem(label: 'main'),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'avatars',
        builder: () => const _Sampler(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              OctoAvatar(initials: 'M', size: OctoAvatarSize.xs, semanticLabel: 'M'),
              OctoAvatar(initials: 'A', size: OctoAvatarSize.sm, semanticLabel: 'A'),
              OctoAvatar(initials: 'MA', semanticLabel: 'MA'),
              OctoAvatar(initials: 'JD', size: OctoAvatarSize.lg, semanticLabel: 'JD'),
              OctoAvatar(initials: 'XL', size: OctoAvatarSize.xl, semanticLabel: 'XL'),
              OctoAvatar(
                initials: 'SQ',
                shape: OctoAvatarShape.square,
                size: OctoAvatarSize.lg,
                semanticLabel: 'SQ',
              ),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'skeletons',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    OctoSkeletonAvatar(),
                    SizedBox(width: 12),
                    Expanded(child: OctoSkeletonText(lines: 2)),
                  ],
                ),
                SizedBox(height: 16),
                OctoSkeleton(height: 32),
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
    // Skeleton uses an infinite AnimationController; freeze tickers so
    // pumpAndSettle terminates and the snapshot is deterministic.
    freezeAnimations: true,
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
