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

Widget _popover(
  OctoOverlayController controller, {
  OctoPopoverPlacement placement = OctoPopoverPlacement.bottomStart,
  double gap = 8,
  double maxWidth = 320,
  String? semanticLabel,
  Widget content = const OctoText('Filter by author'),
}) =>
    OctoPopover(
      controller: controller,
      placement: placement,
      gap: gap,
      maxWidth: maxWidth,
      semanticLabel: semanticLabel,
      content: content,
      child: OctoButton.label('Author', onPressed: controller.toggle),
    );

void main() {
  group('OctoPopover', () {
    testWidgets('starts closed', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(tester, _popover(controller));

      expect(find.text('Filter by author'), findsNothing);
    });

    testWidgets('controller.open() shows the content', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(tester, _popover(controller));
      controller.open();
      await tester.pumpAndSettle();

      expect(find.text('Filter by author'), findsOneWidget);
    });

    testWidgets('tapping the trigger toggles the popover', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(tester, _popover(controller));

      await tester.tap(find.text('Author'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by author'), findsOneWidget);

      await tester.tap(find.text('Author'));
      await tester.pumpAndSettle();
      expect(find.text('Filter by author'), findsNothing);
    });

    testWidgets('controller.close() hides the content', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(tester, _popover(controller));
      controller.open();
      await tester.pumpAndSettle();
      controller.close();
      await tester.pumpAndSettle();

      expect(find.text('Filter by author'), findsNothing);
    });

    testWidgets('Escape closes the popover', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(tester, _popover(controller));
      controller.open();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(controller.isOpen, isFalse);
    });

    testWidgets('tapping outside closes the popover', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        Stack(
          children: [
            const Positioned(
              left: 0,
              top: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(color: Color(0xFFEFEFEF)),
            ),
            Center(child: _popover(controller)),
          ],
        ),
      );

      controller.open();
      await tester.pumpAndSettle();
      expect(controller.isOpen, isTrue);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(controller.isOpen, isFalse);
    });

    testWidgets('interactive content inside the popover stays tappable', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);
      var taps = 0;

      await _pump(
        tester,
        _popover(
          controller,
          content: OctoButton.label('Apply', onPressed: () => taps++),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(taps, 1);
      // A popover is not a menu: selecting inside it does not dismiss it.
      expect(controller.isOpen, isTrue);
    });

    testWidgets('surface reads overlay canvas, default border and medium shadow', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(tester, _popover(controller));
      controller.open();
      await tester.pumpAndSettle();

      final theme = OctoThemeData.light();
      final dec = tester
          .widget<DecoratedBox>(
            find
                .ancestor(
                  of: find.text('Filter by author'),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .decoration as BoxDecoration;

      expect(dec.color, theme.colors.canvas.overlay);
      expect((dec.border! as Border).top.color, theme.colors.border.defaultColor);
      expect(dec.boxShadow, theme.shadows.medium);
      expect(dec.borderRadius, BorderRadius.all(Radius.circular(theme.radii.medium)));
    });

    testWidgets('content is capped at maxWidth', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        _popover(
          controller,
          maxWidth: 120,
          content: const OctoText(
            'A description long enough that it has to wrap inside the popover '
            'instead of stretching it across the whole viewport.',
          ),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      final width = tester
          .getSize(
            find
                .ancestor(
                  of: find.byType(OctoText),
                  matching: find.byType(ConstrainedBox),
                )
                .first,
          )
          .width;
      expect(width, lessThanOrEqualTo(120));
    });

    testWidgets('bottomStart places the popover below the trigger', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(tester, _popover(controller));
      controller.open();
      await tester.pumpAndSettle();

      final trigger = tester.getRect(find.text('Author'));
      final content = tester.getRect(find.text('Filter by author'));
      expect(content.top, greaterThan(trigger.bottom));
    });

    testWidgets('topStart places the popover above the trigger', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        _popover(controller, placement: OctoPopoverPlacement.topStart),
      );
      controller.open();
      await tester.pumpAndSettle();

      final trigger = tester.getRect(find.text('Author'));
      final content = tester.getRect(find.text('Filter by author'));
      expect(content.bottom, lessThan(trigger.top));
    });

    testWidgets('end placements align the popover to the trigger right edge', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        _popover(
          controller,
          placement: OctoPopoverPlacement.bottomEnd,
          content: const SizedBox(width: 200, height: 40, child: OctoText('wide')),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      final trigger = tester.getRect(find.byType(OctoButton));
      final surface = tester.getRect(find.text('wide'));
      // Right edges line up; the surface therefore extends to the LEFT of
      // the trigger, which is the point of an `end` placement.
      expect(surface.left, lessThan(trigger.left));
    });

    testWidgets('topEnd opens above the trigger and aligns to its right edge', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);

      await _pump(
        tester,
        _popover(
          controller,
          placement: OctoPopoverPlacement.topEnd,
          content: const SizedBox(width: 200, height: 40, child: OctoText('wide')),
        ),
      );
      controller.open();
      await tester.pumpAndSettle();

      final trigger = tester.getRect(find.byType(OctoButton));
      final surface = tester.getRect(find.text('wide'));
      expect(surface.bottom, lessThan(trigger.top));
      expect(surface.left, lessThan(trigger.left));
    });

    testWidgets('semanticLabel labels the overlay surface', (tester) async {
      final controller = OctoOverlayController();
      addTearDown(controller.dispose);
      final handle = tester.ensureSemantics();

      await _pump(tester, _popover(controller, semanticLabel: 'Author filter'));
      controller.open();
      await tester.pumpAndSettle();

      // The labelled node lives in the overlay subtree, not under the
      // OctoPopover element itself — the portal reparents it to the root.
      expect(
        tester
            .getSemantics(
              find.byWidgetPredicate(
                (w) => w is Semantics && w.properties.label == 'Author filter',
              ),
            )
            .label,
        contains('Author filter'),
      );
      handle.dispose();
    });

    testWidgets('swapping the controller re-subscribes without leaking', (tester) async {
      final first = OctoOverlayController();
      final second = OctoOverlayController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      await _pump(tester, _popover(first));
      await _pump(tester, _popover(second));

      second.open();
      await tester.pumpAndSettle();
      expect(find.text('Filter by author'), findsOneWidget);

      // The abandoned controller must no longer drive the widget.
      second.close();
      await tester.pumpAndSettle();
      first.open();
      await tester.pumpAndSettle();
      expect(find.text('Filter by author'), findsNothing);
    });
  });
}
