import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        // Snap transitions so we don't need pumpAndSettle on every assert.
        data: const MediaQueryData(disableAnimations: true),
        child: OctoTheme(
          data: OctoThemeData.light(),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 480, height: 240, child: child),
          ),
        ),
      ),
    ),
  );
}

const _tabs = [
  OctoUnderlineNavItem(label: 'Overview'),
  OctoUnderlineNavItem(label: 'Issues'),
  OctoUnderlineNavItem(label: 'Pull requests'),
];

const _bodies = [
  Text('Overview body'),
  Text('Issues body'),
  Text('Pulls body'),
];

void main() {
  group('OctoTabs', () {
    testWidgets('shows the initial panel at boot', (tester) async {
      await _pump(tester, OctoTabs(tabs: _tabs, children: _bodies));
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Overview body'), findsOneWidget);
      expect(find.text('Issues body'), findsNothing);
    });

    testWidgets('tapping a tab swaps the visible panel + fires the callback', (tester) async {
      final picks = <int>[];
      await _pump(
        tester,
        OctoTabs(tabs: _tabs, onTabChanged: picks.add, children: _bodies),
      );
      await tester.tap(find.text('Issues'));
      await tester.pumpAndSettle();
      expect(picks, [1]);
      expect(find.text('Issues body'), findsOneWidget);
      expect(find.text('Overview body'), findsNothing);
    });

    testWidgets('controlled — internal index never moves', (tester) async {
      final picks = <int>[];
      await _pump(
        tester,
        OctoTabs(
          tabs: _tabs,
          selectedIndex: 0,
          onTabChanged: picks.add,
          children: _bodies,
        ),
      );
      await tester.tap(find.text('Issues'));
      await tester.pumpAndSettle();
      // Parent owns the state — body must stay on the parent-picked index.
      expect(picks, [1]);
      expect(find.text('Overview body'), findsOneWidget);
    });

    testWidgets('tapping the active tab is a no-op', (tester) async {
      final picks = <int>[];
      await _pump(
        tester,
        OctoTabs(tabs: _tabs, onTabChanged: picks.add, children: _bodies),
      );
      await tester.tap(find.text('Overview'));
      await tester.pumpAndSettle();
      expect(picks, isEmpty);
    });

    testWidgets('initialIndex picks the right starting tab', (tester) async {
      await _pump(
        tester,
        OctoTabs(tabs: _tabs, initialIndex: 2, children: _bodies),
      );
      expect(find.text('Pulls body'), findsOneWidget);
    });

    test('asserts on mismatched tabs / children lengths', () {
      expect(
        () => OctoTabs(tabs: _tabs, children: const [Text('only one')]),
        throwsAssertionError,
      );
    });
  });
}
