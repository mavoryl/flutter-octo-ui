import 'package:flutter/material.dart';

import 'package:octo_ui/src/theme/theme_data.dart';

/// Build a Material 3 [ThemeData] from an [OctoThemeData] (ADR-0004).
///
/// The adapter exists so that Material affordances rendered outside the
/// Octo widget tree — `AlertDialog`, `SnackBar`, `PopupMenuButton`, default
/// `MaterialPageRoute` chrome — pick up Octo colours, typography, and metrics
/// instead of Material's defaults. It is **read-only**: there is no
/// `fromMaterial` counterpart.
///
/// `useMaterial3` is fixed to `true` — Material 2 is not supported (ADR-0004).
/// The [OctoThemeData] is also registered in `ThemeData.extensions` so
/// `Theme.of(context).extension<OctoThemeData>()` works as a fallback path
/// when an [OctoTheme] ancestor is unavailable (ADR-0007).
extension OctoMaterialAdapter on OctoThemeData {
  /// Produces a Material 3 [ThemeData] mirroring this [OctoThemeData].
  ///
  /// Embeds the receiver in `ThemeData.extensions` so an [OctoTheme] lookup
  /// can fall back through `Theme.of(context).extension<OctoThemeData>()`.
  ThemeData toMaterialTheme() {
    final scheme = _materialColorScheme();
    final textTheme = _materialTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.canvas.defaultColor,
      canvasColor: colors.canvas.defaultColor,
      dividerColor: colors.border.defaultColor,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colors.fg.defaultColor, size: 16),
      splashFactory: NoSplash.splashFactory,
      visualDensity: VisualDensity.compact,
      dividerTheme: DividerThemeData(
        color: colors.border.defaultColor,
        space: 1,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.canvas.overlay,
        surfaceTintColor: colors.canvas.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radii.large)),
          side: BorderSide(color: colors.border.defaultColor),
        ),
        titleTextStyle: typography.heading.copyWith(color: colors.fg.defaultColor),
        contentTextStyle: typography.body.copyWith(color: colors.fg.defaultColor),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.neutral.emphasisPlus,
        contentTextStyle: typography.body.copyWith(color: colors.fg.onEmphasis),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radii.medium)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.canvas.overlay,
        surfaceTintColor: colors.canvas.overlay,
        textStyle: typography.body.copyWith(color: colors.fg.defaultColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radii.medium)),
          side: BorderSide(color: colors.border.defaultColor),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          // Use `neutral.emphasis`, NOT `neutral.emphasisPlus`. In dark
          // mode Primer's `emphasisPlus` flips to a light colour (it's
          // the "highest-contrast inverse surface" slot) — pairing it
          // with `fg.onEmphasis` (white in dark) renders white text on
          // a near-white tooltip, which is unreadable. `neutral.emphasis`
          // stays high-contrast against the canvas in every palette and
          // pairs correctly with `fg.onEmphasis`.
          color: colors.neutral.emphasis,
          borderRadius: BorderRadius.all(Radius.circular(radii.small)),
        ),
        // Tooltip popup mounts in an Overlay, where Material applies the
        // tooltipTheme textStyle verbatim — the ambient DefaultTextStyle
        // is replaced, not merged. Set fontFamily explicitly (with a
        // platform-sensible fallback cascade) so the popup text resolves
        // to a real glyph instead of the Ahem `.notdef` block we'd get
        // if we relied on `fontFamilyFallback` alone.
        textStyle: TextStyle(
          fontFamily: 'Roboto',
          fontFamilyFallback: const <String>[
            'SF Pro Text',
            'Segoe UI',
            'Cantarell',
            'sans-serif',
          ],
          fontSize: 12,
          height: 1.5,
          color: colors.fg.onEmphasis,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[this],
    );
  }

  ColorScheme _materialColorScheme() {
    return ColorScheme(
      brightness: colors.brightness,
      primary: colors.accent.emphasis,
      onPrimary: colors.fg.onEmphasis,
      secondary: colors.neutral.emphasis,
      onSecondary: colors.fg.onEmphasis,
      error: colors.danger.emphasis,
      onError: colors.fg.onEmphasis,
      surface: colors.canvas.defaultColor,
      onSurface: colors.fg.defaultColor,
      surfaceContainerHighest: colors.canvas.subtle,
      outline: colors.border.defaultColor,
      outlineVariant: colors.border.muted,
    );
  }

  TextTheme _materialTextTheme() {
    final fg = colors.fg.defaultColor;
    return TextTheme(
      headlineMedium: typography.heading.copyWith(color: fg),
      headlineSmall: typography.heading.copyWith(color: fg),
      titleLarge: typography.heading.copyWith(color: fg),
      titleMedium: typography.title.copyWith(color: fg),
      titleSmall: typography.bodyEmphasis.copyWith(color: fg),
      bodyLarge: typography.body.copyWith(color: fg),
      bodyMedium: typography.body.copyWith(color: fg),
      bodySmall: typography.bodySmall.copyWith(color: colors.fg.muted),
      labelLarge: typography.bodyEmphasis.copyWith(color: fg),
      labelMedium: typography.label.copyWith(color: fg),
      labelSmall: typography.labelSmall.copyWith(color: colors.fg.muted),
    );
  }
}
