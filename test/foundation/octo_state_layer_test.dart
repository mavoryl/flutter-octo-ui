import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<DecoratedBox?> _findOverlay(WidgetTester tester) async {
  final boxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
  for (final b in boxes) {
    if (b.decoration is BoxDecoration) return b;
  }
  return null;
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: child),
    ),
  );
}

void main() {
  group('OctoStateLayer', () {
    testWidgets('empty state set → no overlay rendered', (tester) async {
      await _pump(
        tester,
        const OctoStateLayer(
          states: <WidgetState>{},
          child: SizedBox(width: 40, height: 40),
        ),
      );
      expect(find.byType(DecoratedBox), findsNothing);
    });

    testWidgets('disabled suppresses overlay even if hovered also set', (tester) async {
      await _pump(
        tester,
        const OctoStateLayer(
          states: <WidgetState>{WidgetState.disabled, WidgetState.hovered},
          child: SizedBox(width: 40, height: 40),
        ),
      );
      expect(find.byType(DecoratedBox), findsNothing);
    });

    testWidgets('hovered → neutral.subtle overlay', (tester) async {
      await _pump(
        tester,
        const OctoStateLayer(
          states: <WidgetState>{WidgetState.hovered},
          child: SizedBox(width: 40, height: 40),
        ),
      );
      final box = await _findOverlay(tester);
      expect(box, isNotNull);
      final dec = box!.decoration as BoxDecoration;
      expect(dec.color, OctoThemeData.light().colors.neutral.subtle);
    });

    testWidgets('pressed takes priority over hovered', (tester) async {
      await _pump(
        tester,
        const OctoStateLayer(
          states: <WidgetState>{WidgetState.pressed, WidgetState.hovered},
          child: SizedBox(width: 40, height: 40),
        ),
      );
      final box = await _findOverlay(tester);
      final dec = box!.decoration as BoxDecoration;
      expect(dec.color, OctoThemeData.light().colors.neutral.muted);
    });

    testWidgets('explicit overlayColor overrides theme', (tester) async {
      const purple = Color(0xFFAA00FF);
      await _pump(
        tester,
        const OctoStateLayer(
          states: <WidgetState>{WidgetState.hovered},
          overlayColor: purple,
          child: SizedBox(width: 40, height: 40),
        ),
      );
      final box = await _findOverlay(tester);
      final dec = box!.decoration as BoxDecoration;
      expect(dec.color, purple);
    });
  });
}
