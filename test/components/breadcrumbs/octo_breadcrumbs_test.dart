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
  group('OctoBreadcrumbs', () {
    testWidgets('renders every segment label', (tester) async {
      await _pump(
        tester,
        OctoBreadcrumbs(
          items: [
            OctoBreadcrumbItem(label: 'Autocrab', onPressed: () {}),
            OctoBreadcrumbItem(label: 'octo_ui', onPressed: () {}),
            const OctoBreadcrumbItem(label: 'main'),
          ],
        ),
      );
      expect(find.text('Autocrab'), findsOneWidget);
      expect(find.text('octo_ui'), findsOneWidget);
      expect(find.text('main'), findsOneWidget);
    });

    testWidgets('non-final items render as buttons; the last one is plain text', (tester) async {
      await _pump(
        tester,
        OctoBreadcrumbs(
          items: [
            OctoBreadcrumbItem(label: 'Autocrab', onPressed: () {}),
            OctoBreadcrumbItem(label: 'octo_ui', onPressed: () {}),
            const OctoBreadcrumbItem(label: 'main'),
          ],
        ),
      );
      expect(find.byType(OctoButton), findsNWidgets(2));
    });

    testWidgets('tapping a clickable crumb fires onPressed', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoBreadcrumbs(
          items: [
            OctoBreadcrumbItem(label: 'Autocrab', onPressed: () => taps++),
            const OctoBreadcrumbItem(label: 'octo_ui'),
          ],
        ),
      );
      await tester.tap(find.text('Autocrab'));
      expect(taps, 1);
    });

    testWidgets('chevron separators appear between adjacent items', (tester) async {
      await _pump(
        tester,
        OctoBreadcrumbs(
          items: [
            OctoBreadcrumbItem(label: 'A', onPressed: () {}),
            OctoBreadcrumbItem(label: 'B', onPressed: () {}),
            const OctoBreadcrumbItem(label: 'C'),
          ],
        ),
      );
      // Three items → two chevrons.
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      expect(icons.length, 2);
    });

    testWidgets('asserts on empty items', (tester) async {
      expect(() => OctoBreadcrumbs(items: const []), throwsAssertionError);
    });
  });
}
