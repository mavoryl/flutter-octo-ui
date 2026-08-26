import 'dart:ui' show Tristate;
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
  group('OctoSegmentedControl', () {
    testWidgets('renders every label', (tester) async {
      await _pump(
        tester,
        OctoSegmentedControl<String>(
          value: 'all',
          onChanged: (_) {},
          items: const [
            OctoSegmentedControlItem(value: 'all', label: 'All'),
            OctoSegmentedControlItem(value: 'open', label: 'Open'),
            OctoSegmentedControlItem(value: 'closed', label: 'Closed'),
          ],
        ),
      );
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('tapping an unselected segment fires onChanged', (tester) async {
      String? changed;
      await _pump(
        tester,
        OctoSegmentedControl<String>(
          value: 'all',
          onChanged: (v) => changed = v,
          items: const [
            OctoSegmentedControlItem(value: 'all', label: 'All'),
            OctoSegmentedControlItem(value: 'open', label: 'Open'),
          ],
        ),
      );
      await tester.tap(find.text('Open'));
      expect(changed, 'open');
    });

    testWidgets('tapping the already-selected segment is a no-op', (tester) async {
      var calls = 0;
      await _pump(
        tester,
        OctoSegmentedControl<String>(
          value: 'all',
          onChanged: (_) => calls++,
          items: const [
            OctoSegmentedControlItem(value: 'all', label: 'All'),
            OctoSegmentedControlItem(value: 'open', label: 'Open'),
          ],
        ),
      );
      await tester.tap(find.text('All'));
      expect(calls, 0);
    });

    testWidgets('selected segment label uses bodyEmphasis weight', (tester) async {
      await _pump(
        tester,
        OctoSegmentedControl<String>(
          value: 'open',
          onChanged: (_) {},
          items: const [
            OctoSegmentedControlItem(value: 'all', label: 'All'),
            OctoSegmentedControlItem(value: 'open', label: 'Open'),
          ],
        ),
      );
      final theme = OctoThemeData.light();
      final selected = tester.widget<Text>(find.text('Open'));
      expect(selected.style!.fontWeight, theme.typography.bodyEmphasis.fontWeight);
      final unselected = tester.widget<Text>(find.text('All'));
      expect(unselected.style!.fontWeight, theme.typography.body.fontWeight);
    });

    testWidgets('onChanged=null disables every segment', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoSegmentedControl<String>(
          value: 'all',
          onChanged: null,
          items: const [
            OctoSegmentedControlItem(value: 'all', label: 'All'),
            OctoSegmentedControlItem(value: 'open', label: 'Open'),
          ],
        ),
      );
      final node = tester.getSemantics(find.text('Open'));
      expect(node.getSemanticsData().flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('selected segment carries isSelected in Semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoSegmentedControl<String>(
          value: 'open',
          onChanged: (_) {},
          items: const [
            OctoSegmentedControlItem(value: 'all', label: 'All'),
            OctoSegmentedControlItem(value: 'open', label: 'Open'),
          ],
        ),
      );
      final open = tester.getSemantics(find.text('Open'));
      expect(open.getSemanticsData().flagsCollection.isSelected, Tristate.isTrue);
      final all = tester.getSemantics(find.text('All'));
      expect(all.getSemanticsData().flagsCollection.isSelected, Tristate.isFalse);
      handle.dispose();
    });
  });
}
