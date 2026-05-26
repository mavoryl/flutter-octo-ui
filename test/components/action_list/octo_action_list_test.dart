import 'package:flutter/services.dart' show LogicalKeyboardKey;
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
  group('OctoActionList', () {
    testWidgets('renders every item label', (tester) async {
      await _pump(
        tester,
        OctoActionList(
          items: [
            OctoActionListItem(label: 'New issue', onPressed: () {}),
            OctoActionListItem(label: 'New pull request', onPressed: () {}),
            OctoActionListItem(label: 'Settings', onPressed: () {}),
          ],
        ),
      );
      expect(find.text('New issue'), findsOneWidget);
      expect(find.text('New pull request'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('invokes onPressed on tap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoActionList(
          items: [OctoActionListItem(label: 'Tap me', onPressed: () => taps++)],
        ),
      );
      await tester.tap(find.text('Tap me'));
      expect(taps, 1);
    });

    testWidgets('null onPressed renders disabled and ignores taps', (tester) async {
      const taps = 0;
      await _pump(
        tester,
        const OctoActionList(
          items: [OctoActionListItem(label: 'Disabled')],
        ),
      );
      await tester.tap(find.text('Disabled'));
      expect(taps, 0);
      final node = tester.getSemantics(find.text('Disabled'));
      expect(node.getSemanticsData().flagsCollection.isEnabled, isFalse);
    });

    testWidgets('selected exposes selected flag in Semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoActionList(
          items: [
            OctoActionListItem(label: 'Picked', selected: true, onPressed: () {}),
          ],
        ),
      );
      final node = tester.getSemantics(find.text('Picked'));
      expect(node.getSemanticsData().flagsCollection.isSelected, isTrue);
      handle.dispose();
    });

    testWidgets('danger variant tints label with danger.fg', (tester) async {
      await _pump(
        tester,
        OctoActionList(
          items: [
            OctoActionListItem(
              label: 'Delete repository',
              variant: OctoActionListItemVariant.danger,
              onPressed: () {},
            ),
          ],
        ),
      );
      final text = tester.widget<Text>(find.text('Delete repository'));
      expect(text.style!.color, OctoThemeData.light().colors.danger.fg);
    });

    testWidgets('description renders below label when present', (tester) async {
      await _pump(
        tester,
        OctoActionList(
          items: [
            OctoActionListItem(
              label: 'Archive',
              description: 'Hide from default search results',
              onPressed: () {},
            ),
          ],
        ),
      );
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Hide from default search results'), findsOneWidget);
    });

    testWidgets('autofocus moves primary focus to the first item', (tester) async {
      final firstNode = FocusNode();
      addTearDown(firstNode.dispose);
      // We don't have direct access to the row's FocusNode, but we can
      // assert *some* primary focus exists inside the OctoActionList
      // subtree after a settle.
      await _pump(
        tester,
        OctoActionList(
          autofocus: true,
          items: [
            OctoActionListItem(label: 'First', onPressed: () {}),
            OctoActionListItem(label: 'Second', onPressed: () {}),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, isNotNull);
      expect(FocusManager.instance.primaryFocus!.debugLabel, contains('First'));
    });

    testWidgets('ArrowDown / ArrowUp move focus across rows', (tester) async {
      await _pump(
        tester,
        OctoActionList(
          autofocus: true,
          items: [
            OctoActionListItem(label: 'Alpha', onPressed: () {}),
            OctoActionListItem(label: 'Beta', onPressed: () {}),
            OctoActionListItem(label: 'Gamma', onPressed: () {}),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus!.debugLabel, contains('Alpha'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus!.debugLabel, contains('Beta'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus!.debugLabel, contains('Gamma'));

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus!.debugLabel, contains('Beta'));
    });

    testWidgets('Enter activates the focused row', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoActionList(
          autofocus: true,
          items: [
            OctoActionListItem(label: 'Run', onPressed: () => taps++),
            OctoActionListItem(label: 'Skip', onPressed: () {}),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('.builder builds the right number of rows', (tester) async {
      await _pump(
        tester,
        SizedBox(
          height: 200,
          child: OctoActionList.builder(
            shrinkWrap: false,
            itemCount: 5,
            itemBuilder: (_, i) => OctoActionListItem(label: 'Item $i', onPressed: () {}),
          ),
        ),
      );
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });
  });
}
