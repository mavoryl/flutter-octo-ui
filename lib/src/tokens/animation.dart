import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:flutter/foundation.dart';

/// Duration and curve tokens for transitions.
@immutable
class OctoAnimation {
  /// Zero-duration token — used to bypass animation explicitly.
  final Duration instant;

  /// 100 ms — micro-interactions (hover/press feedback).
  final Duration fast;

  /// 200 ms — default transition.
  final Duration medium;

  /// 400 ms — page-level and large surface changes.
  final Duration slow;

  /// Default ease for symmetric transitions.
  final Curve standardCurve;

  /// Ease used when content enters the screen.
  final Curve enterCurve;

  /// Ease used when content leaves the screen.
  final Curve exitCurve;

  /// Creates an animation token set. Defaults match Primer.
  const OctoAnimation({
    this.instant = Duration.zero,
    this.fast = const Duration(milliseconds: 100),
    this.medium = const Duration(milliseconds: 200),
    this.slow = const Duration(milliseconds: 400),
    this.standardCurve = Curves.easeInOut,
    this.enterCurve = Curves.easeOut,
    this.exitCurve = Curves.easeIn,
  });

  /// Default Primer-aligned animation tokens.
  factory OctoAnimation.standard() => const OctoAnimation();

  /// Returns a copy with the given fields overridden.
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
