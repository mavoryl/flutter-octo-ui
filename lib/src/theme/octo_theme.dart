import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/theme/theme_data.dart';

/// Propagates [OctoThemeData] through the widget tree.
///
/// Implemented as an [InheritedTheme] (ADR-0007) so the theme automatically
/// flows into overlay routes (`Dialog`, `PopupMenu`, `Tooltip`) via
/// `InheritedTheme.captureAll`, which would not work with a plain
/// `InheritedWidget`.
class OctoTheme extends InheritedTheme {
  /// Tokens exposed to descendant widgets.
  final OctoThemeData data;

  /// Creates a theme scope that exposes [data] to its subtree.
  const OctoTheme({required this.data, required super.child, super.key});

  /// Returns the [OctoThemeData] from the closest enclosing [OctoTheme].
  ///
  /// Asserts a theme is present in debug. Use [maybeOf] when the theme may
  /// legitimately be absent (e.g. at app boot or in widget previews).
  static OctoThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<OctoTheme>();
    assert(theme != null, 'No OctoTheme found in context. Wrap your app in OctoTheme.');
    return theme!.data;
  }

  /// Returns the [OctoThemeData] from the closest enclosing [OctoTheme],
  /// or `null` if none is present.
  static OctoThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OctoTheme>()?.data;
  }

  @override
  bool updateShouldNotify(covariant OctoTheme oldWidget) => oldWidget.data != data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return OctoTheme(data: data, child: child);
  }
}

/// Asserts that [context] is hosted under an [OctoTheme]. Use in widget
/// implementations whose contract demands an enclosing theme.
///
/// Throws in debug only — has no runtime cost in release builds.
bool debugCheckHasOctoTheme(BuildContext context) {
  assert(() {
    if (context.widget is! OctoTheme &&
        context.getElementForInheritedWidgetOfExactType<OctoTheme>() == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No OctoTheme widget ancestor found.'),
        ErrorDescription(
          '${context.widget.runtimeType} widgets require an OctoTheme widget ancestor.',
        ),
        ErrorHint(
          'To introduce an OctoTheme, wrap the relevant subtree in an OctoTheme '
          'widget with a configured OctoThemeData.',
        ),
        context.describeWidget('The specific widget that could not find an OctoTheme ancestor was'),
        context.describeOwnershipChain('The ownership chain for the affected widget is'),
      ]);
    }
    return true;
  }());
  return true;
}
