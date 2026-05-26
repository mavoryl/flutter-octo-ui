import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show BorderRadius, Radius;

/// Corner-radius tokens. Mirrors Primer Primitives `borderRadius.*`.
@immutable
class OctoRadius {
  /// Sharp corners — 0 px.
  final double none;

  /// 4 px — chips, dense inputs.
  final double small;

  /// 6 px — buttons, inputs, cards.
  final double medium;

  /// 8 px — surfaces, dialogs.
  final double large;

  /// Pill — used for fully rounded shapes.
  final double full;

  /// Creates a radius set. Defaults match Primer.
  const OctoRadius({
    this.none = 0,
    this.small = 4,
    this.medium = 6,
    this.large = 8,
    this.full = 9999,
  });

  /// Default Primer-aligned radius set.
  factory OctoRadius.standard() => const OctoRadius();

  /// [BorderRadius] for [small].
  BorderRadius get smallBorder => BorderRadius.all(Radius.circular(small));

  /// [BorderRadius] for [medium].
  BorderRadius get mediumBorder => BorderRadius.all(Radius.circular(medium));

  /// [BorderRadius] for [large].
  BorderRadius get largeBorder => BorderRadius.all(Radius.circular(large));

  /// [BorderRadius] for [full] — pill shape.
  BorderRadius get fullBorder => BorderRadius.all(Radius.circular(full));

  /// Returns a copy with the given fields overridden.
  OctoRadius copyWith({
    double? none,
    double? small,
    double? medium,
    double? large,
    double? full,
  }) =>
      OctoRadius(
        none: none ?? this.none,
        small: small ?? this.small,
        medium: medium ?? this.medium,
        large: large ?? this.large,
        full: full ?? this.full,
      );

  /// Linear interpolation between two radius sets.
  static OctoRadius lerp(OctoRadius a, OctoRadius b, double t) => identical(a, b)
      ? a
      : OctoRadius(
          none: lerpDouble(a.none, b.none, t)!,
          small: lerpDouble(a.small, b.small, t)!,
          medium: lerpDouble(a.medium, b.medium, t)!,
          large: lerpDouble(a.large, b.large, t)!,
          full: lerpDouble(a.full, b.full, t)!,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoRadius &&
          other.none == none &&
          other.small == small &&
          other.medium == medium &&
          other.large == large &&
          other.full == full;

  @override
  int get hashCode => Object.hash(none, small, medium, large, full);
}
