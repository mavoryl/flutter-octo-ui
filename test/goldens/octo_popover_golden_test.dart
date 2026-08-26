import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_popover',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'open_bottom_start',
        builder: () => const _PopoverStage(placement: OctoPopoverPlacement.bottomStart),
      ),
      MatrixScenario(
        'open_bottom_end',
        builder: () => const _PopoverStage(
          placement: OctoPopoverPlacement.bottomEnd,
          alignment: Alignment.topRight,
        ),
      ),
      MatrixScenario(
        'open_top_start',
        builder: () => const _PopoverStage(
          placement: OctoPopoverPlacement.topStart,
          alignment: Alignment.bottomLeft,
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

/// Opens the popover after the first frame so the capture shows the
/// surface, not just the trigger.
class _PopoverStage extends StatefulWidget {
  final OctoPopoverPlacement placement;
  final Alignment alignment;

  const _PopoverStage({
    required this.placement,
    this.alignment = Alignment.topLeft,
  });

  @override
  State<_PopoverStage> createState() => _PopoverStageState();
}

class _PopoverStageState extends State<_PopoverStage> {
  final OctoOverlayController _controller = OctoOverlayController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.open());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: widget.alignment,
        child: OctoPopover(
          controller: _controller,
          placement: widget.placement,
          semanticLabel: 'Author filter',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const OctoText('Filter by author', kind: OctoTextKind.bodyEmphasis),
              const SizedBox(height: 8),
              const OctoText(
                'Only issues opened by the selected people are shown.',
                kind: OctoTextKind.bodySmall,
              ),
              const SizedBox(height: 12),
              OctoButton.label(
                'Apply',
                onPressed: _noop,
                variant: OctoButtonVariant.primary,
                size: OctoButtonSize.small,
              ),
            ],
          ),
          child: OctoButton.label('Author', onPressed: _controller.toggle),
        ),
      ),
    );
  }
}

void _noop() {}
