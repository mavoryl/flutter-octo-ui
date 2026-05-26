import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Canonical avatar sizes — matches the rest of the kit's `xs/sm/md/lg/xl`
/// scale.
enum OctoAvatarSize {
  /// 16 px — inline with text or counters.
  xs,

  /// 20 px — list rows, kebab menus.
  sm,

  /// 32 px — default user chip.
  md,

  /// 48 px — comment heads, side panels.
  lg,

  /// 64 px — profile headers.
  xl,
}

/// Avatar shape — almost always [circle]; [square] is for org / team
/// avatars in Primer.
enum OctoAvatarShape {
  /// Circular avatar.
  circle,

  /// Rounded square (matches `theme.radii.medium`).
  square,
}

/// User avatar with image-then-initials fallback (Primer "Avatar").
///
/// Provide an [imageUrl] (or [imageProvider] for cache control), an
/// [initials] string for the fallback, plus an accessibility label.
/// While the image loads — or if it fails — a neutral surface with the
/// initials is shown.
class OctoAvatar extends StatelessWidget {
  /// Image URL fetched via [NetworkImage]. Mutually exclusive with
  /// [imageProvider].
  final String? imageUrl;

  /// Pre-built image provider. Use this for [MemoryImage] / [AssetImage]
  /// or to share a custom cache.
  final ImageProvider? imageProvider;

  /// Fallback text rendered when no image is available. Typically 1–2
  /// letters ("MA", "S").
  final String? initials;

  /// Size bucket. See [OctoAvatarSize].
  final OctoAvatarSize size;

  /// Shape. Defaults to [OctoAvatarShape.circle].
  final OctoAvatarShape shape;

  /// Accessibility label. Required — a bare avatar is unintelligible to
  /// screen readers without it.
  final String semanticLabel;

  /// Creates an avatar.
  const OctoAvatar({
    super.key,
    this.imageUrl,
    this.imageProvider,
    this.initials,
    this.size = OctoAvatarSize.md,
    this.shape = OctoAvatarShape.circle,
    required this.semanticLabel,
  }) : assert(
          imageUrl == null || imageProvider == null,
          'Provide either imageUrl or imageProvider, not both.',
        );

  double get _dimension => switch (size) {
        OctoAvatarSize.xs => 16,
        OctoAvatarSize.sm => 20,
        OctoAvatarSize.md => 32,
        OctoAvatarSize.lg => 48,
        OctoAvatarSize.xl => 64,
      };

  double _fontSize() => switch (size) {
        OctoAvatarSize.xs => 8,
        OctoAvatarSize.sm => 10,
        OctoAvatarSize.md => 14,
        OctoAvatarSize.lg => 20,
        OctoAvatarSize.xl => 28,
      };

  ImageProvider? _resolvedImage() {
    if (imageProvider != null) return imageProvider;
    if (imageUrl != null) return NetworkImage(imageUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final dim = _dimension;
    final radius = shape == OctoAvatarShape.circle
        ? BorderRadius.all(Radius.circular(dim))
        : BorderRadius.all(Radius.circular(theme.radii.medium));

    final image = _resolvedImage();

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: dim,
          height: dim,
          child: ColoredBox(
            color: theme.colors.neutral.muted,
            child: image != null
                ? Image(
                    image: image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Fallback(
                      initials: initials,
                      fontSize: _fontSize(),
                      theme: theme,
                    ),
                  )
                : _Fallback(
                    initials: initials,
                    fontSize: _fontSize(),
                    theme: theme,
                  ),
          ),
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  final String? initials;
  final double fontSize;
  final OctoThemeData theme;

  const _Fallback({required this.initials, required this.fontSize, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (initials == null || initials!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Center(
      child: OctoText.styled(
        initials!,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, height: 1),
        color: theme.colors.fg.defaultColor,
      ),
    );
  }
}
