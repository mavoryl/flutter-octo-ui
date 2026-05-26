import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show BorderRadius, Radius;

@immutable
class OctoRadius {
  final double none;
  final double small;
  final double medium;
  final double large;
  final double full;

  const OctoRadius({
    this.none = 0,
    this.small = 4,
    this.medium = 6,
    this.large = 8,
    this.full = 9999,
  });

  factory OctoRadius.standard() => const OctoRadius();

  BorderRadius get smallBorder => BorderRadius.all(Radius.circular(small));
  BorderRadius get mediumBorder => BorderRadius.all(Radius.circular(medium));
  BorderRadius get largeBorder => BorderRadius.all(Radius.circular(large));
  BorderRadius get fullBorder => BorderRadius.all(Radius.circular(full));

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
