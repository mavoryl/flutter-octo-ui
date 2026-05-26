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
  group('OctoCheckbox', () {
    testWidgets('tap cycles false → true → false (non-tristate)', (tester) async {
      bool? v = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) => OctoCheckbox(
            value: v,
            onChanged: (nv) => setState(() => v = nv),
          ),
        ),
      );
      await tester.tap(find.byType(OctoCheckbox));
      await tester.pump();
      expect(v, isTrue);
      await tester.tap(find.byType(OctoCheckbox));
      await tester.pump();
      expect(v, isFalse);
    });

    testWidgets('tristate cycles false → true → null → false', (tester) async {
      bool? v = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) => OctoCheckbox(
            value: v,
            tristate: true,
            onChanged: (nv) => setState(() => v = nv),
          ),
        ),
      );
      await tester.tap(find.byType(OctoCheckbox));
      await tester.pump();
      expect(v, isTrue);
      await tester.tap(find.byType(OctoCheckbox));
      await tester.pump();
      expect(v, isNull);
      await tester.tap(find.byType(OctoCheckbox));
      await tester.pump();
      expect(v, isFalse);
    });

    testWidgets('Space activates the focused checkbox', (tester) async {
      bool? v = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) => OctoCheckbox(
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

    testWidgets('Semantics exposes hasCheckedState + correct isChecked / mixed', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoCheckbox(value: null, tristate: true, onChanged: (_) {}),
      );
      final flags =
          tester.getSemantics(find.byType(OctoCheckbox)).getSemanticsData().flagsCollection;
      expect(flags.hasCheckedState, isTrue);
      expect(flags.isChecked, isFalse);
      expect(flags.isCheckStateMixed, isTrue);
      handle.dispose();
    });

    testWidgets('non-tristate with null value triggers assertion', (tester) async {
      expect(
        // ignore: prefer_const_constructors
        () => OctoCheckbox(value: null, onChanged: null),
        throwsAssertionError,
      );
    });
  });
}
