import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

const _star = IconData(0xe838, fontFamily: 'MaterialIcons');

void main() {
  matrixGolden(
    'octo_icon_button',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'variants',
        builder: () => const _Sampler(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoIconButton(icon: _star, onPressed: _noop, semanticLabel: 'Star'),
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                variant: OctoButtonVariant.primary,
                semanticLabel: 'Star',
              ),
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                variant: OctoButtonVariant.invisible,
                semanticLabel: 'Star',
              ),
              OctoIconButton(icon: _star, onPressed: null, semanticLabel: 'Star'),
            ],
          ),
        ),
      ),
      MatrixScenario(
        'sizes',
        builder: () => const _Sampler(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                size: OctoButtonSize.small,
                semanticLabel: 'Star',
              ),
              OctoIconButton(icon: _star, onPressed: _noop, semanticLabel: 'Star'),
              OctoIconButton(
                icon: _star,
                onPressed: _noop,
                size: OctoButtonSize.large,
                semanticLabel: 'Star',
              ),
            ],
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    wrapApp: wrapInOctoTheme,
    reportFormats: octoReportFormats,
  );
}

void _noop() {}

class _Sampler extends StatelessWidget {
  final Widget child;

  const _Sampler({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Align(alignment: Alignment.topLeft, child: child),
      );
}
