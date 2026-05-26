import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(
        data: OctoThemeData.light(),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 220, child: child),
        ),
      ),
    ),
  );
}

const _items = [
  OctoSideNavItem(label: 'Repositories'),
  OctoSideNavItem(label: 'Projects'),
  OctoSideNavItem(label: 'Discussions'),
];

void main() {
  group('OctoSideNav', () {
    testWidgets('renders all rows in order', (tester) async {
      await _pump(
        tester,
        const OctoSideNav(items: _items, selectedIndex: 0),
      );
      expect(find.text('Repositories'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Discussions'), findsOneWidget);
    });

    testWidgets('tapping a row fires onChanged with its index', (tester) async {
      final picks = <int>[];
      await _pump(
        tester,
        OctoSideNav(items: _items, selectedIndex: 0, onChanged: picks.add),
      );
      await tester.tap(find.text('Projects'));
      expect(picks, [1]);
    });

    testWidgets('tapping the selected row is a no-op', (tester) async {
      final picks = <int>[];
      await _pump(
        tester,
        OctoSideNav(items: _items, selectedIndex: 1, onChanged: picks.add),
      );
      await tester.tap(find.text('Projects'));
      expect(picks, isEmpty);
    });

    testWidgets('selected row carries Semantics(selected: true)', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoSideNav(items: _items, selectedIndex: 2),
      );
      final flags =
          tester.getSemantics(find.text('Discussions')).getSemanticsData().flagsCollection;
      expect(flags.isSelected, isTrue);
      handle.dispose();
    });

    testWidgets('-1 selectedIndex highlights nothing', (tester) async {
      final picks = <int>[];
      await _pump(
        tester,
        OctoSideNav(items: _items, selectedIndex: -1, onChanged: picks.add),
      );
      await tester.tap(find.text('Repositories'));
      expect(picks, [0]);
    });
  });
}
