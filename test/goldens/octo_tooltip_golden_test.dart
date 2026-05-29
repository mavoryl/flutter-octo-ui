import 'package:flutter/material.dart' show TooltipState;
import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_tooltip',
    scenarios: <MatrixScenario>[
      MatrixScenario('shown', builder: () => const _TooltipShownStage()),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
    // No `captureAfter` here — the tooltip fade-in is bounded (150 ms),
    // so matrixGolden's default `pumpAndSettle` settles cleanly and
    // delivers the popup at full opacity. Specifying captureAfter would
    // switch to a single `pump(duration)` which doesn't tick the
    // overlay mount on the same frame.
  );
}

/// Anchors an [OctoTooltip] in the centre of the viewport and forces its
/// overlay open on the first frame so the snapshot captures the popup,
/// not just the trigger.
class _TooltipShownStage extends StatefulWidget {
  const _TooltipShownStage();

  @override
  State<_TooltipShownStage> createState() => _TooltipShownStageState();
}

class _TooltipShownStageState extends State<_TooltipShownStage> {
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tooltipKey.currentState?.ensureTooltipVisible();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Align(
        alignment: Alignment.topCenter,
        child: OctoTooltip(
          tooltipKey: _tooltipKey,
          message: 'Open command palette (⌘K)',
          child: OctoButton.label(
            'Hover me',
            onPressed: () {},
            variant: OctoButtonVariant.invisible,
          ),
        ),
      ),
    );
  }
}
