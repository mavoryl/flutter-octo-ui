import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    OctoTheme(
      data: OctoThemeData.light(),
      child: MaterialApp(home: Scaffold(body: Center(child: child))),
    ),
  );
}

void main() {
  group('OctoDropdown', () {
    testWidgets('trigger shows selected label', (tester) async {
      await _pump(
        tester,
        OctoDropdown<String>(
          value: 'b',
          onChanged: (_) {},
          items: const [
            OctoDropdownItem(value: 'a', label: 'Apple'),
            OctoDropdownItem(value: 'b', label: 'Banana'),
            OctoDropdownItem(value: 'c', label: 'Cherry'),
          ],
        ),
      );
      // The trigger button label is "Banana" because value=='b'.
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('placeholder shown when value is null', (tester) async {
      await _pump(
        tester,
        OctoDropdown<String>(
          value: null,
          onChanged: (_) {},
          placeholder: 'Pick a fruit',
          items: const [
            OctoDropdownItem(value: 'a', label: 'Apple'),
          ],
        ),
      );
      expect(find.text('Pick a fruit'), findsOneWidget);
    });

    testWidgets('tapping trigger opens the menu', (tester) async {
      await _pump(
        tester,
        OctoDropdown<String>(
          value: 'a',
          onChanged: (_) {},
          items: const [
            OctoDropdownItem(value: 'a', label: 'Apple'),
            OctoDropdownItem(value: 'b', label: 'Banana'),
          ],
        ),
      );
      expect(find.text('Banana'), findsNothing);
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('picking an option fires onChanged with its value', (tester) async {
      String? picked;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (_, setState) => OctoDropdown<String>(
            value: picked ?? 'a',
            onChanged: (v) => setState(() => picked = v),
            items: const [
              OctoDropdownItem(value: 'a', label: 'Apple'),
              OctoDropdownItem(value: 'b', label: 'Banana'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(picked, 'b');
    });

    testWidgets('onChanged=null disables the trigger', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoDropdown<String>(
          value: 'a',
          onChanged: null,
          items: [OctoDropdownItem(value: 'a', label: 'Apple')],
        ),
      );
      final node = tester.getSemantics(find.byType(OctoButton));
      expect(node.getSemanticsData().flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });
  });
}
