import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    OctoTheme(
      data: OctoThemeData.light(),
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  group('OctoFilterBar', () {
    testWidgets('renders a search field with the default placeholder', (tester) async {
      await _pump(tester, const OctoFilterBar());
      expect(find.byType(OctoTextField), findsOneWidget);
      expect(find.text('Filter…'), findsOneWidget);
    });

    testWidgets('placeholder is customisable', (tester) async {
      await _pump(tester, const OctoFilterBar(searchPlaceholder: 'Find a service'));
      expect(find.text('Find a service'), findsOneWidget);
    });

    testWidgets('typing reports the query through onSearchChanged', (tester) async {
      final seen = <String>[];
      await _pump(tester, OctoFilterBar(onSearchChanged: seen.add));

      await tester.enterText(find.byType(OctoTextField), 'checkout');

      expect(seen, ['checkout']);
    });

    testWidgets('an external controller drives the field', (tester) async {
      final controller = TextEditingController(text: 'api');
      addTearDown(controller.dispose);

      await _pump(tester, OctoFilterBar(searchController: controller));

      expect(find.text('api'), findsOneWidget);
    });

    testWidgets('renders every filter widget passed in', (tester) async {
      await _pump(
        tester,
        OctoFilterBar(
          filters: [
            OctoChip(label: 'severity: high', onPressed: () {}),
            OctoChip(label: 'env: prod', onPressed: () {}),
          ],
        ),
      );
      expect(find.text('severity: high'), findsOneWidget);
      expect(find.text('env: prod'), findsOneWidget);
    });

    testWidgets('filters are laid out in a Wrap so narrow bars reflow', (tester) async {
      await _pump(
        tester,
        OctoFilterBar(filters: [OctoChip(label: 'env: prod', onPressed: () {})]),
      );
      expect(
        find.descendant(of: find.byType(OctoFilterBar), matching: find.byType(Wrap)),
        findsOneWidget,
      );
    });

    testWidgets('no clear affordance when onClear is null', (tester) async {
      await _pump(tester, const OctoFilterBar());
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('onClear renders a clear button and fires on tap', (tester) async {
      var cleared = 0;
      await _pump(tester, OctoFilterBar(onClear: () => cleared++));

      await tester.tap(find.text('Clear'));

      expect(cleared, 1);
    });

    testWidgets('activeFilterCount shows a counter next to the clear button', (tester) async {
      await _pump(tester, OctoFilterBar(onClear: () {}, activeFilterCount: 3));
      expect(find.byType(OctoCounterLabel), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('no counter when activeFilterCount is zero', (tester) async {
      await _pump(tester, OctoFilterBar(onClear: () {}));
      expect(find.byType(OctoCounterLabel), findsNothing);
    });

    testWidgets('counter appears without a clear button too', (tester) async {
      await _pump(tester, const OctoFilterBar(activeFilterCount: 2));
      expect(find.byType(OctoCounterLabel), findsOneWidget);
      expect(find.text('Clear'), findsNothing);
    });

    testWidgets('the bar is one semantic container labelled as a filter region', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoFilterBar(semanticLabel: 'Service filters'));
      expect(
        tester.getSemantics(find.byType(OctoFilterBar)).label,
        contains('Service filters'),
      );
      handle.dispose();
    });

    testWidgets('negative activeFilterCount is rejected', (tester) async {
      expect(() => OctoFilterBar(activeFilterCount: -1), throwsAssertionError);
    });
  });
}
