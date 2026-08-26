import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/tokens/breakpoints.dart';

/// Viewport size class resolved from [OctoBreakpoints].
///
/// Declared narrowest-first, so the enum's own ordering doubles as the width
/// ordering used by [isAtLeast] / [isAtMost].
enum OctoBreakpoint {
  /// Phones in portrait.
  xs,

  /// Large phones, phones in landscape.
  sm,

  /// Tablets in portrait.
  md,

  /// Tablets in landscape, small laptops.
  lg,

  /// Desktops.
  xl,

  /// Wide desktops and large monitors.
  xxl;

  /// `true` when this class is [other] or wider.
  bool isAtLeast(OctoBreakpoint other) => index >= other.index;

  /// `true` when this class is [other] or narrower.
  bool isAtMost(OctoBreakpoint other) => index <= other.index;

  /// The size class [width] falls into, given [breakpoints].
  ///
  /// Widths below the narrowest threshold resolve to [xs] rather than to
  /// `null` — a 280 px window is still the narrowest layout, and returning
  /// null would push that judgement onto every caller.
  static OctoBreakpoint resolve(double width, OctoBreakpoints breakpoints) {
    if (width >= breakpoints.xxl) return OctoBreakpoint.xxl;
    if (width >= breakpoints.xl) return OctoBreakpoint.xl;
    if (width >= breakpoints.lg) return OctoBreakpoint.lg;
    if (width >= breakpoints.md) return OctoBreakpoint.md;
    if (width >= breakpoints.sm) return OctoBreakpoint.sm;
    return OctoBreakpoint.xs;
  }
}

/// Window-size helpers on [BuildContext].
///
/// These read [MediaQuery], so they describe the *window*. When the decision
/// depends on the space a widget actually got — content beside a sidebar, a
/// panel inside a split view — use [OctoResponsiveBuilder] instead.
extension OctoBreakpointContext on BuildContext {
  /// Size class of the current window.
  OctoBreakpoint get octoBreakpoint => OctoBreakpoint.resolve(
        MediaQuery.sizeOf(this).width,
        OctoTheme.of(this).breakpoints,
      );

  /// `true` when the window is [breakpoint] or wider.
  bool isAtLeast(OctoBreakpoint breakpoint) => octoBreakpoint.isAtLeast(breakpoint);
}

/// Builds a subtree against the size class of the space it was given.
///
/// Wraps [LayoutBuilder], so the breakpoint comes from the incoming
/// constraints rather than from the window — the distinction that matters
/// for dashboard content sitting next to a sidebar.
///
/// ```dart
/// OctoResponsiveBuilder(
///   builder: (context, breakpoint) => GridView.count(
///     crossAxisCount: breakpoint.isAtLeast(OctoBreakpoint.lg) ? 4 : 2,
///     children: tiles,
///   ),
/// )
/// ```
class OctoResponsiveBuilder extends StatelessWidget {
  /// Called with the size class resolved from the incoming constraints.
  final Widget Function(BuildContext context, OctoBreakpoint breakpoint) builder;

  /// Creates a constraint-driven responsive builder.
  const OctoResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final breakpoints = OctoTheme.of(context).breakpoints;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Unbounded width (inside a horizontal scroll view) has no size class
        // to speak of; fall back to the window so the caller still gets a
        // sensible answer instead of xxl-by-infinity.
        final width =
            constraints.hasBoundedWidth ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
        return builder(context, OctoBreakpoint.resolve(width, breakpoints));
      },
    );
  }
}
