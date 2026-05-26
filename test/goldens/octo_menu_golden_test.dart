import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void main() {
  matrixGolden(
    'octo_menu',
    scenarios: <MatrixScenario>[
      MatrixScenario('open', builder: () => const _MenuStage()),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}

/// Stateful wrapper that opens the menu after the first frame so the
/// golden capture sees the popover, not just the anchor button.
class _MenuStage extends StatefulWidget {
  const _MenuStage();

  @override
  State<_MenuStage> createState() => _MenuStageState();
}

class _MenuStageState extends State<_MenuStage> {
  final OctoMenuController _controller = OctoMenuController();

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
        alignment: Alignment.topLeft,
        child: OctoMenu(
          controller: _controller,
          items: const [
            OctoActionListItem(
              label: 'New issue',
              leading: Icon(Icons.add),
              onPressed: _noop,
            ),
            OctoActionListItem(
              label: 'New pull request',
              leading: Icon(Icons.merge_type),
              onPressed: _noop,
            ),
            OctoActionListItem(
              label: 'Settings',
              leading: Icon(Icons.settings_outlined),
              onPressed: _noop,
            ),
            OctoActionListItem(
              label: 'Delete repository',
              leading: Icon(Icons.delete_outline),
              variant: OctoActionListItemVariant.danger,
              onPressed: _noop,
            ),
          ],
          child: OctoButton.label('More actions', onPressed: _controller.toggle),
        ),
      ),
    );
  }
}

void _noop() {}
