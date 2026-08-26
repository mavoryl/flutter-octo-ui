import 'dart:ui' show Tristate;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: child),
    ),
  );
}

void main() {
  group('OctoUnderlineNav', () {
    testWidgets('renders every tab label', (tester) async {
      await _pump(
        tester,
        OctoUnderlineNav(
          selectedIndex: 0,
          onChanged: (_) {},
          items: const [
            OctoUnderlineNavItem(label: 'Code'),
            OctoUnderlineNavItem(label: 'Issues'),
            OctoUnderlineNavItem(label: 'Pull requests'),
          ],
        ),
      );
      expect(find.text('Code'), findsOneWidget);
      expect(find.text('Issues'), findsOneWidget);
      expect(find.text('Pull requests'), findsOneWidget);
    });

    testWidgets('tapping a tab fires onChanged with its index', (tester) async {
      int? changed;
      await _pump(
        tester,
        OctoUnderlineNav(
          selectedIndex: 0,
          onChanged: (i) => changed = i,
          items: const [
            OctoUnderlineNavItem(label: 'Code'),
            OctoUnderlineNavItem(label: 'Issues'),
            OctoUnderlineNavItem(label: 'Pull requests'),
          ],
        ),
      );
      await tester.tap(find.text('Issues'));
      expect(changed, 1);
    });

    testWidgets('selected tab gets isSelected semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoUnderlineNav(
          selectedIndex: 1,
          onChanged: (_) {},
          items: const [
            OctoUnderlineNavItem(label: 'Code'),
            OctoUnderlineNavItem(label: 'Issues'),
          ],
        ),
      );
      final issuesNode = tester.getSemantics(find.text('Issues'));
      expect(issuesNode.getSemanticsData().flagsCollection.isSelected, Tristate.isTrue);
      final codeNode = tester.getSemantics(find.text('Code'));
      expect(codeNode.getSemanticsData().flagsCollection.isSelected, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('onChanged=null makes the nav inert', (tester) async {
      await _pump(
        tester,
        const OctoUnderlineNav(
          selectedIndex: 0,
          onChanged: null,
          items: [
            OctoUnderlineNavItem(label: 'Code'),
            OctoUnderlineNavItem(label: 'Issues'),
          ],
        ),
      );
      // No onChanged means no tap registers — and the test passes by virtue
      // of not crashing. Also verify enabled flag is off.
      final handle = tester.ensureSemantics();
      final node = tester.getSemantics(find.text('Issues'));
      expect(node.getSemanticsData().flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('selected label uses bodyEmphasis (semibold) typography', (tester) async {
      await _pump(
        tester,
        OctoUnderlineNav(
          selectedIndex: 1,
          onChanged: (_) {},
          items: const [
            OctoUnderlineNavItem(label: 'Code'),
            OctoUnderlineNavItem(label: 'Issues'),
          ],
        ),
      );
      final theme = OctoThemeData.light();
      final selectedText = tester.widget<Text>(find.text('Issues'));
      expect(selectedText.style!.fontWeight, theme.typography.bodyEmphasis.fontWeight);
      final unselectedText = tester.widget<Text>(find.text('Code'));
      expect(unselectedText.style!.fontWeight, theme.typography.body.fontWeight);
    });
  });
}
