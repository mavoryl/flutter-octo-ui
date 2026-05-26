import 'dart:ui' show Color, Offset;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show BoxShadow;

/// Elevation tokens — Primer uses three: small, medium, large.
@immutable
class OctoShadows {
  final List<BoxShadow> small;
  final List<BoxShadow> medium;
  final List<BoxShadow> large;

  const OctoShadows({
    required this.small,
    required this.medium,
    required this.large,
  });

  factory OctoShadows.standard() => const OctoShadows(
        small: <BoxShadow>[
          BoxShadow(
            color: Color(0x0F1F2328),
            offset: Offset(0, 1),
          ),
        ],
        medium: <BoxShadow>[
          BoxShadow(
            color: Color(0x141F2328),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
        large: <BoxShadow>[
          BoxShadow(
            color: Color(0x1F1F2328),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      );

  factory OctoShadows.standardDark() => const OctoShadows(
        small: <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 1),
          ),
        ],
        medium: <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
        large: <BoxShadow>[
          BoxShadow(
            color: Color(0x80000000),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      );

  OctoShadows copyWith({
    List<BoxShadow>? small,
    List<BoxShadow>? medium,
    List<BoxShadow>? large,
  }) =>
      OctoShadows(
        small: small ?? this.small,
        medium: medium ?? this.medium,
        large: large ?? this.large,
      );

  static OctoShadows lerp(OctoShadows a, OctoShadows b, double t) {
    if (identical(a, b)) return a;
    return OctoShadows(
      small: BoxShadow.lerpList(a.small, b.small, t) ?? const <BoxShadow>[],
      medium: BoxShadow.lerpList(a.medium, b.medium, t) ?? const <BoxShadow>[],
      large: BoxShadow.lerpList(a.large, b.large, t) ?? const <BoxShadow>[],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoShadows &&
          listEquals(other.small, small) &&
          listEquals(other.medium, medium) &&
          listEquals(other.large, large);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(small),
        Object.hashAll(medium),
        Object.hashAll(large),
      );
}
