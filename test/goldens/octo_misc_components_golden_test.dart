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
              OctoBreadcrumbItem(label: 'Autocrab', onPressed: _noop),
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
        'dividers',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Subtle'),
                SizedBox(height: 8),
                OctoDivider(emphasis: OctoDividerEmphasis.subtle),
                SizedBox(height: 16),
                Text('Muted (default)'),
                SizedBox(height: 8),
                OctoDivider(),
                SizedBox(height: 16),
                Text('Strong + indent'),
                SizedBox(height: 8),
                OctoDivider(
                  emphasis: OctoDividerEmphasis.strong,
                  indent: 24,
                  endIndent: 24,
                ),
                SizedBox(height: 16),
                Text('Thickness 4'),
                SizedBox(height: 8),
                OctoDivider(thickness: 4),
                SizedBox(height: 16),
                SizedBox(
                  height: 32,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Center(child: Text('Inline A')),
                      ),
                      OctoDivider.vertical(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Center(child: Text('Inline B')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      MatrixScenario(
        'toasts',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                OctoToast(
                  message: 'Repository created',
                  variant: OctoToastVariant.success,
                ),
                SizedBox(height: 12),
                OctoToast(
                  message: 'Heads up — 3 packages need an upgrade',
                  variant: OctoToastVariant.attention,
                ),
                SizedBox(height: 12),
                OctoToast(
                  message: 'Note archived',
                  action: OctoToastAction(label: 'Undo', onPressed: _noop),
                ),
                SizedBox(height: 12),
                OctoToast(
                  message: 'Failed to publish workflow',
                  variant: OctoToastVariant.danger,
                  dismissible: true,
                  onDismiss: _noop,
                ),
              ],
            ),
          ),
        ),
      ),
      MatrixScenario(
        'collapsibles',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                OctoCollapsible(
                  title: 'Collapsed section',
                  child: Text(
                    'Hidden body — only the chevron and title show.',
                  ),
                ),
                SizedBox(height: 12),
                OctoCollapsible(
                  title: 'Expanded section',
                  initiallyExpanded: true,
                  child: Text(
                    'Body content is visible while the chevron points down.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      MatrixScenario(
        'spinners',
        // Park each spinner via motion-reduce so the snapshot stays
        // deterministic under freezeAnimations.
        builder: () => const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: _Sampler(
            child: SizedBox(
              width: 280,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OctoSpinner(size: OctoSpinnerSize.small),
                  OctoSpinner(),
                  OctoSpinner(size: OctoSpinnerSize.large),
                ],
              ),
            ),
          ),
        ),
      ),
      MatrixScenario(
        'progress_bars',
        builder: () => const _Sampler(
          child: SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('accent · 25%'),
                SizedBox(height: 6),
                OctoProgressBar(value: 0.25),
                SizedBox(height: 12),
                Text('success · 75%'),
                SizedBox(height: 6),
                OctoProgressBar(
                  value: 0.75,
                  variant: OctoProgressBarVariant.success,
                ),
                SizedBox(height: 12),
                Text('attention · 100%'),
                SizedBox(height: 6),
                OctoProgressBar(
                  value: 1,
                  variant: OctoProgressBarVariant.attention,
                ),
                SizedBox(height: 12),
                Text('danger · small · 40%'),
                SizedBox(height: 6),
                OctoProgressBar(
                  value: 0.4,
                  variant: OctoProgressBarVariant.danger,
                  size: OctoProgressBarSize.small,
                ),
                SizedBox(height: 12),
                Text('indeterminate · motion-reduce → 50% static'),
                SizedBox(height: 6),
                // Force the motion-reduce path so the snapshot is
                // deterministic — without it the animated stripe lives at
                // controller.value = 0 (off-screen) under freezeAnimations.
                MediaQuery(
                  data: MediaQueryData(disableAnimations: true),
                  child: OctoProgressBar(),
                ),
              ],
            ),
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
