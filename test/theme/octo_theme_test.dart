import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

void main() {
  group('OctoTheme', () {
    testWidgets('of returns the nearest theme', (tester) async {
      final theme = OctoThemeData.light();
      OctoThemeData? captured;
      await tester.pumpWidget(
        OctoTheme(
          data: theme,
          child: Builder(
            builder: (context) {
              captured = OctoTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, same(theme));
    });

    testWidgets('maybeOf returns null when absent', (tester) async {
      OctoThemeData? captured;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            captured = OctoTheme.maybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(captured, isNull);
    });

    testWidgets('debugCheckHasOctoTheme throws when no ancestor', (tester) async {
      late FlutterError thrown;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            try {
              debugCheckHasOctoTheme(context);
            } on FlutterError catch (e) {
              thrown = e;
            }
            return const SizedBox.shrink();
          },
        ),
      );
      expect(thrown.message, contains('No OctoTheme widget ancestor found'));
    });

    test('updateShouldNotify only fires on data value change', () {
      final light = OctoThemeData.light();
      final dark = OctoThemeData.dark();
      final widgetLight = OctoTheme(data: light, child: const SizedBox.shrink());
      final widgetLightCopy = OctoTheme(data: light, child: const SizedBox.shrink());
      final widgetDark = OctoTheme(data: dark, child: const SizedBox.shrink());

      expect(widgetLight.updateShouldNotify(widgetLightCopy), isFalse);
      expect(widgetLight.updateShouldNotify(widgetDark), isTrue);
    });

    testWidgets('theme propagates into pushed routes via captureAll', (tester) async {
      final theme = OctoThemeData.light();
      OctoThemeData? capturedInRoute;
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        OctoTheme(
          data: theme,
          child: MaterialApp(
            navigatorKey: navKey,
            home: const Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      // Push a route from a context that does NOT include the OctoTheme
      // ancestor — the route should still see the theme because Flutter
      // captures all InheritedThemes from the launch context.
      unawaited(
        navKey.currentState!.push<void>(
          MaterialPageRoute<void>(
            builder: (ctx) {
              capturedInRoute = OctoTheme.of(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(capturedInRoute, same(theme));
    });
  });
}

void unawaited(Future<void> _) {}
