import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:flutter/foundation.dart';

@immutable
class OctoAnimation {
  final Duration instant;
  final Duration fast;
  final Duration medium;
  final Duration slow;
  final Curve standardCurve;
  final Curve enterCurve;
  final Curve exitCurve;

  const OctoAnimation({
    this.instant = Duration.zero,
    this.fast = const Duration(milliseconds: 100),
    this.medium = const Duration(milliseconds: 200),
    this.slow = const Duration(milliseconds: 400),
    this.standardCurve = Curves.easeInOut,
    this.enterCurve = Curves.easeOut,
    this.exitCurve = Curves.easeIn,
  });

  factory OctoAnimation.standard() => const OctoAnimation();

  OctoAnimation copyWith({
    Duration? instant,
    Duration? fast,
    Duration? medium,
    Duration? slow,
    Curve? standardCurve,
    Curve? enterCurve,
    Curve? exitCurve,
  }) =>
      OctoAnimation(
        instant: instant ?? this.instant,
        fast: fast ?? this.fast,
        medium: medium ?? this.medium,
        slow: slow ?? this.slow,
        standardCurve: standardCurve ?? this.standardCurve,
        enterCurve: enterCurve ?? this.enterCurve,
        exitCurve: exitCurve ?? this.exitCurve,
      );

  /// Durations and curves do not interpolate continuously — step at t=0.5.
  static OctoAnimation lerp(OctoAnimation a, OctoAnimation b, double t) =>
      identical(a, b) ? a : (t < 0.5 ? a : b);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctoAnimation &&
          other.instant == instant &&
          other.fast == fast &&
          other.medium == medium &&
          other.slow == slow &&
          other.standardCurve == standardCurve &&
          other.enterCurve == enterCurve &&
          other.exitCurve == exitCurve;

  @override
  int get hashCode => Object.hash(
        instant,
        fast,
        medium,
        slow,
        standardCurve,
        enterCurve,
        exitCurve,
      );
}
