import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

void _noop() {}

Widget _body(String title, String subtitle) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        OctoText(title, kind: OctoTextKind.bodyEmphasis),
        const SizedBox(height: 4),
        OctoText(subtitle, kind: OctoTextKind.bodySmall),
      ],
    );

void main() {
  componentMatrixGolden(
    'octo_card',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'variants',
        builder: () => octoComponentWrap(
          SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OctoCard(child: _body('Outlined', 'Hairline border, no shadow')),
                const SizedBox(height: 16),
                OctoCard(
                  variant: OctoCardVariant.elevated,
                  child: _body('Elevated', 'Drop shadow, no border'),
                ),
              ],
            ),
          ),
        ),
      ),
      MatrixScenario(
        'interactive_states',
        builder: () => octoComponentWrap(
          SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OctoCard(
                  onPressed: _noop,
                  child: _body('Default', 'Interactive, idle'),
                ),
                const SizedBox(height: 16),
                OctoCard(
                  onPressed: _noop,
                  debugStates: const {WidgetState.hovered},
                  child: _body('Hovered', 'Subtle neutral overlay'),
                ),
                const SizedBox(height: 16),
                OctoCard(
                  onPressed: _noop,
                  debugStates: const {WidgetState.pressed},
                  child: _body('Pressed', 'Stronger neutral overlay'),
                ),
                const SizedBox(height: 16),
                OctoCard(
                  onPressed: _noop,
                  selected: true,
                  debugStates: const {WidgetState.selected},
                  child: _body('Selected', 'Accent-tinted overlay'),
                ),
              ],
            ),
          ),
        ),
      ),
      MatrixScenario(
        'focused',
        builder: () => octoComponentWrap(
          GoldenFocusScope(
            child: SizedBox(
              width: 320,
              child: OctoCard(
                onPressed: _noop,
                autofocus: true,
                child: _body('Focused', 'Keyboard focus ring'),
              ),
            ),
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}
