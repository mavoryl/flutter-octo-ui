import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/avatar/octo_avatar.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Row of overlapping avatars (Primer "AvatarStack") — assignees on an
/// issue, participants in a thread, members of a team.
///
/// The first avatar paints on top, as in Primer, so the leading face stays
/// fully visible however long the list gets. Each avatar is ringed in the
/// canvas colour; without that ring, overlapping circles read as one blob.
///
/// When [maxVisible] is set and the list is longer, the extras collapse
/// into a `+N` counter rendered as a trailing avatar.
class OctoAvatarStack extends StatelessWidget {
  /// Avatars in reading order. The first one paints on top.
  final List<OctoAvatar> avatars;

  /// Maximum number of faces to show. `null` (default) shows all of them.
  /// When the list is longer, the remainder collapses into a `+N` counter.
  final int? maxVisible;

  /// Fraction of an avatar's diameter hidden by its right-hand neighbour.
  /// `0` places them edge to edge; `0.3` (default) matches Primer.
  final double overlapRatio;

  /// Builds the accessibility label of the `+N` counter from the number of
  /// hidden avatars. Defaults to `'N more'`.
  final String Function(int hidden)? overflowLabelBuilder;

  /// Creates an avatar stack.
  const OctoAvatarStack({
    super.key,
    required this.avatars,
    this.maxVisible,
    this.overlapRatio = 0.3,
    this.overflowLabelBuilder,
  })  : assert(
          overlapRatio >= 0 && overlapRatio < 1,
          'overlapRatio must be in [0, 1) — 1 would stack every avatar on '
          'the same spot.',
        ),
        assert(
          maxVisible == null || maxVisible > 0,
          'maxVisible must be positive; use an empty avatars list to render '
          'nothing.',
        );

  @override
  Widget build(BuildContext context) {
    if (avatars.isEmpty) return const SizedBox.shrink();

    final theme = OctoTheme.of(context);
    final limit = maxVisible;
    final hidden = limit == null ? 0 : (avatars.length - limit).clamp(0, avatars.length);
    final visible = hidden == 0 ? avatars : avatars.take(limit!).toList();

    final tiles = <OctoAvatar>[
      ...visible,
      if (hidden > 0)
        OctoAvatar(
          initials: '+$hidden',
          size: visible.last.size,
          shape: visible.last.shape,
          semanticLabel: overflowLabelBuilder?.call(hidden) ?? '$hidden more',
        ),
    ];

    // Left edge of each tile, plus the total width: every tile but the last
    // contributes one step; the last contributes its full diameter.
    var offset = 0.0;
    final offsets = <double>[];
    for (final tile in tiles) {
      offsets.add(offset);
      offset += tile.dimension * (1 - overlapRatio);
    }
    final last = tiles.last;
    final width = offsets.last + last.dimension;
    final height = tiles.map((t) => t.dimension).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        // Later children paint on top, so the visual order is reversed:
        // the first avatar is built last and stays fully visible.
        children: [
          for (var i = tiles.length - 1; i >= 0; i--)
            Positioned(
              left: offsets[i],
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: tiles[i].shape == OctoAvatarShape.circle
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: tiles[i].shape == OctoAvatarShape.circle
                      ? null
                      : BorderRadius.all(Radius.circular(theme.radii.medium)),
                  border: Border.all(color: theme.colors.canvas.defaultColor, width: 2),
                ),
                child: tiles[i],
              ),
            ),
        ],
      ),
    );
  }
}
