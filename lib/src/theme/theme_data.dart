import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeExtension;

import 'package:octo_ui/src/tokens/animation.dart';
import 'package:octo_ui/src/tokens/breakpoints.dart';
import 'package:octo_ui/src/tokens/color_scheme.dart';
import 'package:octo_ui/src/tokens/radius.dart';
import 'package:octo_ui/src/tokens/shadows.dart';
import 'package:octo_ui/src/tokens/spacing.dart';
import 'package:octo_ui/src/tokens/typography.dart';

/// Aggregates every design token group consumed by widgets.
///
/// Implements [ThemeExtension] so applications mounted under a `MaterialApp`
/// can register the Octo theme via `ThemeData.extensions` (see ADR-0007).
@immutable
class OctoThemeData extends ThemeExtension<OctoThemeData> with Diagnosticable {
  final OctoColorScheme colors;
  final OctoSpacing spacing;
  final OctoRadius radii;
  final OctoTypography typography;
  final OctoShadows shadows;
  final OctoBreakpoints breakpoints;
  final OctoAnimation animation;

  const OctoThemeData({
    required this.colors,
    required this.spacing,
    required this.radii,
    required this.typography,
    required this.shadows,
    required this.breakpoints,
    required this.animation,
  });

  factory OctoThemeData.light({
    OctoColorSchemeVariant variant = OctoColorSchemeVariant.standard,
  }) =>
      OctoThemeData(
        colors: OctoColorScheme.light(variant: variant),
        spacing: OctoSpacing.standard(),
        radii: OctoRadius.standard(),
        typography: OctoTypography.standard(),
        shadows: OctoShadows.standard(),
        breakpoints: OctoBreakpoints.standard(),
        animation: OctoAnimation.standard(),
      );

  factory OctoThemeData.dark({
    OctoColorSchemeVariant variant = OctoColorSchemeVariant.standard,
  }) =>
      OctoThemeData(
        colors: OctoColorScheme.dark(variant: variant),
        spacing: OctoSpacing.standard(),
        radii: OctoRadius.standard(),
        typography: OctoTypography.standard(),
        shadows: OctoShadows.standardDark(),
        breakpoints: OctoBreakpoints.standard(),
        animation: OctoAnimation.standard(),
      );

  @override
  OctoThemeData copyWith({
    OctoColorScheme? colors,
    OctoSpacing? spacing,
    OctoRadius? radii,
    OctoTypography? typography,
    OctoShadows? shadows,
    OctoBreakpoints? breakpoints,
    OctoAnimation? animation,
  }) =>
      OctoThemeData(
        colors: colors ?? this.colors,
        spacing: spacing ?? this.spacing,
        radii: radii ?? this.radii,
        typography: typography ?? this.typography,
        shadows: shadows ?? this.shadows,
        breakpoints: breakpoints ?? this.breakpoints,
        animation: animation ?? this.animation,
      );

  @override
  OctoThemeData lerp(ThemeExtension<OctoThemeData>? other, double t) {
    if (other is! OctoThemeData) return this;
    if (identical(this, other)) return this;
    return OctoThemeData(
      colors: OctoColorScheme.lerp(colors, other.colors, t),
      spacing: OctoSpacing.lerp(spacing, other.spacing, t),
      radii: OctoRadius.lerp(radii, other.radii, t),
      typography: OctoTypography.lerp(typography, other.typography, t),
      shadows: OctoShadows.lerp(shadows, other.shadows, t),
      breakpoints: OctoBreakpoints.lerp(breakpoints, other.breakpoints, t),
      animation: OctoAnimation.lerp(animation, other.animation, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoThemeData &&
          other.colors == colors &&
          other.spacing == spacing &&
          other.radii == radii &&
          other.typography == typography &&
          other.shadows == shadows &&
          other.breakpoints == breakpoints &&
          other.animation == animation;

  @override
  int get hashCode =>
      Object.hash(colors, spacing, radii, typography, shadows, breakpoints, animation);
}
