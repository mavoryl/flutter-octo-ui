import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: Center(child: child)),
    ),
  );
}

void main() {
  group('OctoButton', () {
    testWidgets('renders child text', (tester) async {
      await _pump(tester, OctoButton.label('Click me', onPressed: () {}));
      expect(find.text('Click me'), findsOneWidget);
    });

    testWidgets('invokes onPressed on tap', (tester) async {
      var taps = 0;
      await _pump(tester, OctoButton.label('Go', onPressed: () => taps++));
      await tester.tap(find.byType(OctoButton));
      expect(taps, 1);
    });

    testWidgets('disabled (onPressed=null) ignores taps and is reported in semantics',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, OctoButton.label('Disabled', onPressed: null));
      await tester.tap(find.byType(OctoButton));
      final semantics = tester.getSemantics(find.byType(OctoButton));
      expect(semantics.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(semantics.getSemanticsData().flagsCollection.isEnabled, isFalse);
      handle.dispose();
    });

    testWidgets('loading=true shows spinner and disables tap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoButton.label('Saving', onPressed: () => taps++, loading: true),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(OctoButton));
      expect(taps, 0);
    });

    testWidgets('primary variant uses accent.emphasis background', (tester) async {
      await _pump(
        tester,
        OctoButton.label('Save', onPressed: () {}, variant: OctoButtonVariant.primary),
      );
      final theme = OctoThemeData.light();
      final dec = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => b.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.color == theme.colors.accent.emphasis);
      expect(dec.color, theme.colors.accent.emphasis);
    });

    testWidgets('danger variant uses danger.emphasis background', (tester) async {
      await _pump(
        tester,
        OctoButton.label('Delete', onPressed: () {}, variant: OctoButtonVariant.danger),
      );
      final theme = OctoThemeData.light();
      final dec = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => b.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.color == theme.colors.danger.emphasis);
      expect(dec.color, theme.colors.danger.emphasis);
    });

    testWidgets('keyboard activation: Enter triggers onPressed', (tester) async {
      var taps = 0;
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        OctoButton.label('Go', onPressed: () => taps++, focusNode: node, autofocus: true),
      );
      await tester.pumpAndSettle();
      expect(node.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });
  });
}
