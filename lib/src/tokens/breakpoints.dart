import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// Layout breakpoints mirroring Primer Viewport sizes.
@immutable
class OctoBreakpoints {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  const OctoBreakpoints({
    this.xs = 320,
    this.sm = 544,
    this.md = 768,
    this.lg = 1012,
    this.xl = 1280,
    this.xxl = 1400,
  });

  factory OctoBreakpoints.standard() => const OctoBreakpoints();

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
