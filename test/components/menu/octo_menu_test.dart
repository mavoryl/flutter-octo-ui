import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget body) async {
  await tester.pumpWidget(
    OctoTheme(
      data: OctoThemeData.light(),
      child: MaterialApp(
        home: Scaffold(body: Center(child: body)),
      ),
    ),
  );
}

void main() {
  group('OctoMenu', () {
    testWidgets('starts closed; controller.open() shows items', (tester) async {
      final controller = OctoMenuController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        OctoMenu(
          controller: controller,
          items: [
            OctoActionListItem(label: 'New issue', onPressed: () {}),
            OctoActionListItem(label: 'New pull request', onPressed: () {}),
          ],
          child: OctoButton.label('More', onPressed: controller.toggle),
        ),
      );

      expect(find.text('New issue'), findsNothing);

      controller.open();
      await tester.pumpAndSettle();
      expect(find.text('New issue'), findsOneWidget);
      expect(find.text('New pull request'), findsOneWidget);
    });

    testWidgets('tapping an item invokes onPressed and closes the menu', (tester) async {
      final controller = OctoMenuController();
      addTearDown(controller.dispose);
      var taps = 0;

      await _pump(
        tester,
        OctoMenu(
          controller: controller,
          items: [
            OctoActionListItem(label: 'New issue', onPressed: () => taps++),
          ],
          child: OctoButton.label('More', onPressed: controller.toggle),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();
      await tester.tap(find.text('New issue'));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(controller.isOpen, isFalse);
      expect(find.text('New issue'), findsNothing);
    });

    testWidgets('closeOnSelect=false keeps the menu open across selections', (tester) async {
      final controller = OctoMenuController();
      addTearDown(controller.dispose);
      var taps = 0;

      await _pump(
        tester,
        OctoMenu(
          controller: controller,
          closeOnSelect: false,
          items: [
            OctoActionListItem(label: 'Multi', onPressed: () => taps++),
          ],
          child: OctoButton.label('More', onPressed: controller.toggle),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Multi'));
      await tester.pumpAndSettle();

      expect(taps, 1);
      expect(controller.isOpen, isTrue);
      expect(find.text('Multi'), findsOneWidget);
    });

    testWidgets('tapping the trigger of an open menu closes it', (tester) async {
      final controller = OctoMenuController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        OctoMenu(
          controller: controller,
          items: [OctoActionListItem(label: 'Item', onPressed: () {})],
          child: OctoButton.label('More', onPressed: controller.toggle),
        ),
      );

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);

      // Without a shared TapRegion group, this tap first fires
      // `onTapOutside` (closing the menu) and then the trigger's own
      // `toggle` (reopening it), so the menu never closes.
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isFalse);
    });

    testWidgets('Escape closes the menu', (tester) async {
      final controller = OctoMenuController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        OctoMenu(
          controller: controller,
          items: [OctoActionListItem(label: 'Item', onPressed: () {})],
          child: OctoButton.label('More', onPressed: controller.toggle),
        ),
      );

      controller.open();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(controller.isOpen, isFalse);
    });

    testWidgets('tapping outside closes the menu', (tester) async {
      final controller = OctoMenuController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        Stack(
          children: [
            // Outside-tap target lives below the menu but outside its body.
            const Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(color: Color(0xFFEFEFEF)),
            ),
            Center(
              child: OctoMenu(
                controller: controller,
                items: [OctoActionListItem(label: 'Item', onPressed: () {})],
                child: OctoButton.label('More', onPressed: controller.toggle),
              ),
            ),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);

      // Tap the top-left corner — outside the menu and the anchor.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isFalse);
    });
  });
}
