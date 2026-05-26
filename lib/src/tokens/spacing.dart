import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

/// Indexed spacing scale + semantic aliases (ADR-0003).
///
/// `steps` is the raw scale in logical pixels. Index is a *step position*,
/// not a pixel value. Components address spacing through semantic groups
/// ([gap], [inset]); applications can drop to [scale] for escape hatches.
///
/// Default scale mirrors Primer Primitives `size.*` track.
@immutable
class OctoSpacing {
  static const List<double> _defaultSteps = <double>[
    0,
    2,
    4,
    6,
    8,
    12,
    16,
    24,
    32,
    40,
    48,
    64,
    80,
    96,
  ];

  static const OctoGap _defaultGap = OctoGap(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
  );

  static const OctoInset _defaultInset = OctoInset(
    xs: 4,
    sm: 8,
    md: 12,
    lg: 16,
    xl: 24,
  );

  final List<double> steps;
  final OctoGap? _gap;
  final OctoInset? _inset;

  const OctoSpacing({
    this.steps = _defaultSteps,
    OctoGap? gap,
    OctoInset? inset,
  })  : _gap = gap,
        _inset = inset;

  factory OctoSpacing.standard() => const OctoSpacing();

  OctoGap get gap => _gap ?? _defaultGap;

  OctoInset get inset => _inset ?? _defaultInset;

  /// Raw scale lookup. [step] is a position in [steps], not a pixel value.
  double scale(int step) {
    assert(
      step >= 0 && step < steps.length,
      'step $step out of bounds [0, ${steps.length})',
    );
    return steps[step];
  }

  /// Reverse lookup — returns the step index that produces [value], or -1.
  int indexFor(double value) => steps.indexOf(value);

  OctoSpacing copyWith({List<double>? steps, OctoGap? gap, OctoInset? inset}) => OctoSpacing(
        steps: steps ?? this.steps,
        gap: gap ?? _gap,
        inset: inset ?? _inset,
      );

  static OctoSpacing lerp(OctoSpacing a, OctoSpacing b, double t) {
    if (identical(a, b)) return a;
    // Scales of different shape do not interpolate — step semantics differ.
    final steps = a.steps.length == b.steps.length
        ? <double>[
            for (var i = 0; i < a.steps.length; i++) lerpDouble(a.steps[i], b.steps[i], t)!,
          ]
        : (t < 0.5 ? a.steps : b.steps);
    return OctoSpacing(
      steps: steps,
      gap: OctoGap.lerp(a.gap, b.gap, t),
      inset: OctoInset.lerp(a.inset, b.inset, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoSpacing &&
          listEquals(other.steps, steps) &&
          other.gap == gap &&
          other.inset == inset;

  @override
  int get hashCode => Object.hash(Object.hashAll(steps), gap, inset);
}

@immutable
class OctoGap {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  const OctoGap({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  OctoGap copyWith({double? xs, double? sm, double? md, double? lg, double? xl}) => OctoGap(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
      );

  static OctoGap lerp(OctoGap a, OctoGap b, double t) => identical(a, b)
      ? a
      : OctoGap(
          xs: lerpDouble(a.xs, b.xs, t)!,
          sm: lerpDouble(a.sm, b.sm, t)!,
          md: lerpDouble(a.md, b.md, t)!,
          lg: lerpDouble(a.lg, b.lg, t)!,
          xl: lerpDouble(a.xl, b.xl, t)!,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoGap &&
          other.xs == xs &&
          other.sm == sm &&
          other.md == md &&
          other.lg == lg &&
          other.xl == xl;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl);
}

@immutable
class OctoInset {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  const OctoInset({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  OctoInset copyWith({double? xs, double? sm, double? md, double? lg, double? xl}) => OctoInset(
        xs: xs ?? this.xs,
        sm: sm ?? this.sm,
        md: md ?? this.md,
        lg: lg ?? this.lg,
        xl: xl ?? this.xl,
      );

  static OctoInset lerp(OctoInset a, OctoInset b, double t) => identical(a, b)
      ? a
      : OctoInset(
          xs: lerpDouble(a.xs, b.xs, t)!,
          sm: lerpDouble(a.sm, b.sm, t)!,
          md: lerpDouble(a.md, b.md, t)!,
          lg: lerpDouble(a.lg, b.lg, t)!,
          xl: lerpDouble(a.xl, b.xl, t)!,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoInset &&
          other.xs == xs &&
          other.sm == sm &&
          other.md == md &&
          other.lg == lg &&
          other.xl == xl;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl);
}
