import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';
import 'package:octo_ui/octo_ui.dart';

import '_octo_matrix.dart';

const _team = [
  OctoAvatar(initials: 'MA', semanticLabel: 'Marat'),
  OctoAvatar(initials: 'JD', semanticLabel: 'Jane'),
  OctoAvatar(initials: 'SP', semanticLabel: 'Sam'),
  OctoAvatar(initials: 'KL', semanticLabel: 'Kim'),
  OctoAvatar(initials: 'RO', semanticLabel: 'Robin'),
];

void main() {
  componentMatrixGolden(
    'octo_avatar_stack',
    scenarios: <MatrixScenario>[
      MatrixScenario(
        'sizes_and_overflow',
        builder: () => octoComponentWrap(
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              OctoAvatarStack(avatars: _team),
              SizedBox(height: 16),
              OctoAvatarStack(avatars: _team, maxVisible: 3),
              SizedBox(height: 16),
              OctoAvatarStack(avatars: _team, overlapRatio: 0.5, maxVisible: 3),
              SizedBox(height: 16),
              OctoAvatarStack(
                avatars: [
                  OctoAvatar(initials: 'A', size: OctoAvatarSize.sm, semanticLabel: 'A'),
                  OctoAvatar(initials: 'B', size: OctoAvatarSize.sm, semanticLabel: 'B'),
                  OctoAvatar(initials: 'C', size: OctoAvatarSize.sm, semanticLabel: 'C'),
                ],
              ),
              SizedBox(height: 16),
              OctoAvatarStack(
                avatars: [
                  OctoAvatar(initials: 'A', size: OctoAvatarSize.lg, semanticLabel: 'A'),
                  OctoAvatar(initials: 'B', size: OctoAvatarSize.lg, semanticLabel: 'B'),
                  OctoAvatar(
                    initials: 'C',
                    size: OctoAvatarSize.lg,
                    shape: OctoAvatarShape.square,
                    semanticLabel: 'C',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
    axes: MatrixAxes(themes: octoThemes),
    reportFormats: octoReportFormats,
    tolerance: octoGoldenTolerance,
  );
}
