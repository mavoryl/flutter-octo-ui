import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: child),
    ),
  );
}

void main() {
  group('OctoLabel', () {
    testWidgets('renders text', (tester) async {
      await _pump(tester, const OctoLabel('Bug'));
      expect(find.text('Bug'), findsOneWidget);
    });

    testWidgets('standard variant uses border.default + fg.muted', (tester) async {
      await _pump(tester, const OctoLabel('Bug'));
      final theme = OctoThemeData.light();
      final container = tester.widget<Container>(find.byType(Container));
      final dec = container.decoration! as BoxDecoration;
      expect((dec.border! as Border).top.color, theme.colors.border.defaultColor);
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.color, theme.colors.fg.muted);
    });

    testWidgets('danger variant uses danger colors', (tester) async {
      await _pump(tester, const OctoLabel('Critical', variant: OctoLabelVariant.danger));
      final theme = OctoThemeData.light();
      final container = tester.widget<Container>(find.byType(Container));
      final dec = container.decoration! as BoxDecoration;
      expect((dec.border! as Border).top.color, theme.colors.danger.muted);
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.color, theme.colors.danger.fg);
    });

    testWidgets('exposes text via Semantics (single label, no duplication)', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoLabel('Bug'));
      // The inner Text carries the semantic label. There is no wrapping
      // Semantics, so the label is "Bug" — not "Bug\nBug".
      final semantics = tester.getSemantics(find.byType(OctoLabel));
      expect(semantics.label, 'Bug');
      handle.dispose();
    });
  });
}
