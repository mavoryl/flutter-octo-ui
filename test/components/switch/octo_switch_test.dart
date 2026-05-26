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
  group('OctoSwitch', () {
    testWidgets('tap toggles value', (tester) async {
      var v = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) => OctoSwitch(
            value: v,
            onChanged: (nv) => setState(() => v = nv),
          ),
        ),
      );
      await tester.tap(find.byType(OctoSwitch));
      await tester.pumpAndSettle();
      expect(v, isTrue);
      await tester.tap(find.byType(OctoSwitch));
      await tester.pumpAndSettle();
      expect(v, isFalse);
    });

    testWidgets('Space activates the focused switch', (tester) async {
      var v = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) => OctoSwitch(
            value: v,
            autofocus: true,
            onChanged: (nv) => setState(() => v = nv),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(v, isTrue);
    });

    testWidgets('onChanged=null renders disabled and ignores taps', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoSwitch(value: false, onChanged: null));
      await tester.tap(find.byType(OctoSwitch));
      final node = tester.getSemantics(find.byType(OctoSwitch));
      expect(node.getSemanticsData().flagsCollection.isEnabled, isFalse);
      handle.dispose();
    });

    testWidgets('Semantics carries hasToggledState + correct isToggled', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, OctoSwitch(value: true, onChanged: (_) {}));
      final node = tester.getSemantics(find.byType(OctoSwitch));
      final flags = node.getSemanticsData().flagsCollection;
      expect(flags.hasToggledState, isTrue);
      expect(flags.isToggled, isTrue);
      handle.dispose();
    });
  });
}
