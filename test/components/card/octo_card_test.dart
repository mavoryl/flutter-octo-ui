import 'package:flutter/gestures.dart' show PointerDeviceKind;
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

BoxDecoration _decorationOf(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: find.byType(OctoCard), matching: find.byType(DecoratedBox)).first,
  );
  return box.decoration as BoxDecoration;
}

void main() {
  group('OctoCard', () {
    testWidgets('renders its child', (tester) async {
      await _pump(tester, const OctoCard(child: OctoText('Repository')));
      expect(find.text('Repository'), findsOneWidget);
    });

    testWidgets('outlined variant draws a border and no shadow', (tester) async {
      await _pump(tester, const OctoCard(child: OctoText('x')));
      final theme = OctoThemeData.light();
      final dec = _decorationOf(tester);

      expect(dec.color, theme.colors.canvas.defaultColor);
      expect((dec.border! as Border).top.color, theme.colors.border.defaultColor);
      expect(dec.boxShadow, isNull);
      expect(dec.borderRadius, BorderRadius.all(Radius.circular(theme.radii.medium)));
    });

    testWidgets('elevated variant draws a shadow and no border', (tester) async {
      await _pump(
        tester,
        const OctoCard(variant: OctoCardVariant.elevated, child: OctoText('x')),
      );
      final theme = OctoThemeData.light();
      final dec = _decorationOf(tester);

      expect(dec.boxShadow, theme.shadows.small);
      expect(dec.border, isNull);
    });

    testWidgets('default padding is inset.lg on every side', (tester) async {
      await _pump(tester, const OctoCard(child: OctoText('x')));
      final theme = OctoThemeData.light();
      final padding = tester.widget<Padding>(
        find.descendant(of: find.byType(OctoCard), matching: find.byType(Padding)).first,
      );
      expect(padding.padding, EdgeInsets.all(theme.spacing.inset.lg));
    });

    testWidgets('explicit padding overrides the default', (tester) async {
      await _pump(
        tester,
        const OctoCard(padding: EdgeInsets.all(3), child: OctoText('x')),
      );
      final padding = tester.widget<Padding>(
        find.descendant(of: find.byType(OctoCard), matching: find.byType(Padding)).first,
      );
      expect(padding.padding, const EdgeInsets.all(3));
    });

    testWidgets('presentational card is not a semantic button', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoCard(child: OctoText('x')));
      final data = tester.getSemantics(find.byType(OctoCard)).getSemanticsData();
      expect(data.flagsCollection.isButton, isFalse);
      handle.dispose();
    });

    testWidgets('presentational card ignores taps without crashing', (tester) async {
      await _pump(tester, const OctoCard(child: OctoText('x')));
      await tester.tap(find.byType(OctoCard));
      expect(tester.takeException(), isNull);
    });

    testWidgets('onPressed fires on tap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoCard(onPressed: () => taps++, child: const OctoText('x')),
      );
      await tester.tap(find.byType(OctoCard));
      expect(taps, 1);
    });

    testWidgets('interactive card exposes a semantic button with its label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoCard(
          onPressed: () {},
          semanticLabel: 'Open repository',
          child: const OctoText('x'),
        ),
      );
      final node = tester.getSemantics(find.byType(OctoCard));
      expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(node.label, contains('Open repository'));
      handle.dispose();
    });

    testWidgets('selected card reports selected to the state layer', (tester) async {
      await _pump(
        tester,
        OctoCard(onPressed: () {}, selected: true, child: const OctoText('x')),
      );
      final layer = tester.widget<OctoStateLayer>(find.byType(OctoStateLayer));
      expect(layer.states, contains(WidgetState.selected));
    });

    testWidgets('selected is honoured on a presentational card too', (tester) async {
      await _pump(tester, const OctoCard(selected: true, child: OctoText('x')));
      final layer = tester.widget<OctoStateLayer>(find.byType(OctoStateLayer));
      expect(layer.states, contains(WidgetState.selected));
    });

    testWidgets('hovering an interactive card adds the hovered state', (tester) async {
      await _pump(
        tester,
        OctoCard(onPressed: () {}, child: const OctoText('x')),
      );
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.byType(OctoCard))),
      );
      await tester.pump();

      final layer = tester.widget<OctoStateLayer>(find.byType(OctoStateLayer));
      expect(layer.states, contains(WidgetState.hovered));
    });

    testWidgets('pressing an interactive card adds the pressed state', (tester) async {
      await _pump(
        tester,
        OctoCard(onPressed: () {}, child: const OctoText('x')),
      );
      final gesture = await tester.startGesture(tester.getCenter(find.byType(OctoCard)));
      await tester.pump();

      final layer = tester.widget<OctoStateLayer>(find.byType(OctoStateLayer));
      expect(layer.states, contains(WidgetState.pressed));

      await gesture.up();
    });

    testWidgets('Enter activates a focused interactive card', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoCard(onPressed: () => taps++, autofocus: true, child: const OctoText('x')),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 1);
    });

    testWidgets('toggling selected on an already-mounted card updates the overlay', (tester) async {
      await _pump(tester, const OctoCard(child: OctoText('x')));
      expect(
        tester.widget<OctoStateLayer>(find.byType(OctoStateLayer)).states,
        isNot(contains(WidgetState.selected)),
      );

      await _pump(tester, const OctoCard(selected: true, child: OctoText('x')));
      expect(
        tester.widget<OctoStateLayer>(find.byType(OctoStateLayer)).states,
        contains(WidgetState.selected),
      );
    });

    testWidgets('a cancelled press clears the pressed state', (tester) async {
      await _pump(
        tester,
        OctoCard(onPressed: () {}, child: const OctoText('x')),
      );
      final gesture = await tester.startGesture(tester.getCenter(find.byType(OctoCard)));
      await tester.pump();
      expect(
        tester.widget<OctoStateLayer>(find.byType(OctoStateLayer)).states,
        contains(WidgetState.pressed),
      );

      // Dragging far enough turns the tap into a pan, cancelling it.
      await gesture.moveBy(const Offset(0, 400));
      await gesture.up();
      await tester.pump();
      expect(
        tester.widget<OctoStateLayer>(find.byType(OctoStateLayer)).states,
        isNot(contains(WidgetState.pressed)),
      );
    });

    testWidgets('leaving an interactive card clears the hovered state', (tester) async {
      await _pump(
        tester,
        OctoCard(onPressed: () {}, child: const OctoText('x')),
      );
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.byType(OctoCard))),
      );
      await tester.pump();
      await tester.sendEventToBinding(pointer.hover(const Offset(1, 1)));
      await tester.pump();

      expect(
        tester.widget<OctoStateLayer>(find.byType(OctoStateLayer)).states,
        isNot(contains(WidgetState.hovered)),
      );
    });

    testWidgets('debugStates overrides the live state set for goldens', (tester) async {
      await _pump(
        tester,
        OctoCard(
          onPressed: () {},
          debugStates: const {WidgetState.hovered},
          child: const OctoText('x'),
        ),
      );
      final layer = tester.widget<OctoStateLayer>(find.byType(OctoStateLayer));
      expect(layer.states, const {WidgetState.hovered});
    });
  });
}
