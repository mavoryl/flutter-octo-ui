import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_command_palette',
    scenarios: <MatrixScenario>[
      MatrixScenario('open', builder: () => const _PaletteStage()),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

class _PaletteStage extends StatefulWidget {
  const _PaletteStage();

  @override
  State<_PaletteStage> createState() => _PaletteStageState();
}

class _PaletteStageState extends State<_PaletteStage> {
  final OctoCommandPaletteController _controller = OctoCommandPaletteController();

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
    final theme = OctoTheme.of(context);
    return ColoredBox(
      color: theme.colors.canvas.defaultColor,
      child: OctoCommandPalette(
        controller: _controller,
        items: const [
          OctoActionListItem(
            label: 'Restart service',
            leading: Icon(OctIcons.sync_16),
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'Acknowledge alert',
            leading: Icon(OctIcons.bell_16),
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'Open runbook',
            leading: Icon(OctIcons.book_16),
            description: 'Escalation steps and on-call contacts',
            onPressed: _noop,
          ),
          OctoActionListItem(
            label: 'Toggle dark mode',
            leading: Icon(OctIcons.moon_16),
            onPressed: _noop,
          ),
        ],
        child: const SizedBox.expand(),
      ),
    );
  }
}

void _noop() {}
