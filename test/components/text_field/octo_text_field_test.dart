import 'package:flutter/material.dart' show MaterialApp, Scaffold;
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter/widgets.dart';
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
  group('OctoTextField', () {
    testWidgets('renders placeholder', (tester) async {
      await _pump(tester, const OctoTextField(placeholder: 'Search...'));
      expect(find.text('Search...'), findsOneWidget);
    });

    testWidgets('renders label above input', (tester) async {
      await _pump(tester, const OctoTextField(label: 'Email'));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('onChanged fires on input', (tester) async {
      var captured = '';
      await _pump(tester, OctoTextField(onChanged: (v) => captured = v));
      await tester.enterText(find.byType(OctoTextField), 'hello');
      expect(captured, 'hello');
    });

    testWidgets('controller drives text and disposal does not crash', (tester) async {
      final c = TextEditingController(text: 'initial');
      addTearDown(c.dispose);
      await _pump(tester, OctoTextField(controller: c));
      expect(find.text('initial'), findsOneWidget);
      c.text = 'changed';
      await tester.pump();
      expect(find.text('changed'), findsOneWidget);
    });

    testWidgets('inputFormatters restrict input', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await _pump(
        tester,
        OctoTextField(
          controller: c,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      );
      await tester.enterText(find.byType(OctoTextField), 'abc123def');
      expect(c.text, '123');
    });

    testWidgets('errorText overrides helperText and uses danger.fg', (tester) async {
      await _pump(
        tester,
        const OctoTextField(helperText: 'Helper', errorText: 'Required'),
      );
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Helper'), findsNothing);
      final text = tester.widget<Text>(find.text('Required'));
      expect(text.style!.color, OctoThemeData.light().colors.danger.fg);
    });

    testWidgets('exposes textField flag in Semantics with label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoTextField(label: 'Email'));
      final node = tester.getSemantics(find.byType(OctoTextField));
      expect(node.getSemanticsData().flagsCollection.isTextField, isTrue);
      expect(node.label, contains('Email'));
      handle.dispose();
    });
  });
}
