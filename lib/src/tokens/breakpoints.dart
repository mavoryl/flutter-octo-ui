import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// Layout breakpoints mirroring Primer Viewport sizes.
@immutable
class OctoBreakpoints {
  /// Minimum viewport — phones in portrait.
  final double xs;

  /// Small — large phones / phones in landscape.
  final double sm;

  /// Medium — tablets in portrait.
  final double md;

  /// Large — tablets in landscape / small laptops.
  final double lg;

  /// Extra large — desktops.
  final double xl;

  /// Wide desktop / large monitors.
  final double xxl;

  /// Creates a breakpoint set. Defaults match Primer Viewport sizes.
  const OctoBreakpoints({
    this.xs = 320,
    this.sm = 544,
    this.md = 768,
    this.lg = 1012,
    this.xl = 1280,
    this.xxl = 1400,
  });

  /// Default Primer-aligned breakpoints.
  factory OctoBreakpoints.standard() => const OctoBreakpoints();

  /// Returns a copy with the given fields overridden.
  OctoBreakpoints copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) =>
      OctoBreakpoints(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
        xxl: xxl ?? this.xxl,
      );

  /// Linear interpolation between two breakpoint sets.
  static OctoBreakpoints lerp(
    OctoBreakpoints a,
    OctoBreakpoints b,
    double t,
  ) =>
      identical(a, b)
          ? a
          : OctoBreakpoints(
              xs: lerpDouble(a.xs, b.xs, t)!,
              sm: lerpDouble(a.sm, b.sm, t)!,
              md: lerpDouble(a.md, b.md, t)!,
              lg: lerpDouble(a.lg, b.lg, t)!,
              xl: lerpDouble(a.xl, b.xl, t)!,
              xxl: lerpDouble(a.xxl, b.xxl, t)!,
            );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoBreakpoints &&
          other.xs == xs &&
          other.sm == sm &&
          other.md == md &&
          other.lg == lg &&
          other.xl == xl &&
          other.xxl == xxl;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl, xxl);
}
