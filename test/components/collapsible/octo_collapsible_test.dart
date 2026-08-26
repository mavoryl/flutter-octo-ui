import 'dart:ui' show Tristate;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Size _bodySize(WidgetTester tester) => tester.getSize(find.byType(ClipRect).last);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        // Snap transitions so we can settle synchronously.
        data: const MediaQueryData(disableAnimations: true),
        child: OctoTheme(
          data: OctoThemeData.light(),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 320, child: child),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('OctoCollapsible', () {
    testWidgets('renders the title and starts collapsed by default', (tester) async {
      await _pump(
        tester,
        const OctoCollapsible(title: 'Details', child: Text('Hidden body')),
      );
      expect(find.text('Details'), findsOneWidget);
      // Body is laid out via Align with heightFactor 0; the text widget
      // exists in the tree but is clipped to zero height.
      final body = _bodySize(tester);
      expect(body.height, 0);
    });

    testWidgets('initiallyExpanded — body is visible from the start', (tester) async {
      await _pump(
        tester,
        const OctoCollapsible(
          title: 'Details',
          initiallyExpanded: true,
          child: Text('Visible body'),
        ),
      );
      expect(_bodySize(tester).height, greaterThan(0));
    });

    testWidgets('tap on header toggles expansion and fires the callback', (tester) async {
      final requested = <bool>[];
      await _pump(
        tester,
        OctoCollapsible(
          title: 'Details',
          onExpansionChanged: requested.add,
          child: const Text('body'),
        ),
      );
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(requested, [true]);
      expect(_bodySize(tester).height, greaterThan(0));
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(requested, [true, false]);
      expect(_bodySize(tester).height, 0);
    });

    testWidgets('controlled mode — internal flag is ignored', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoCollapsible(
          title: 'Details',
          expanded: false,
          onExpansionChanged: (_) => taps++,
          child: const Text('body'),
        ),
      );
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      // expanded=false from the parent — body must remain collapsed
      // regardless of taps; only the callback fires.
      expect(taps, 1);
      expect(_bodySize(tester).height, 0);
    });

    testWidgets('Space activates the focused header', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final requested = <bool>[];
      await _pump(
        tester,
        OctoCollapsible(
          title: 'Details',
          focusNode: focusNode,
          onExpansionChanged: requested.add,
          child: const Text('body'),
        ),
      );
      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(requested, [true]);
    });

    testWidgets('semantics expose button + expanded state', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoCollapsible(
          title: 'Details',
          initiallyExpanded: true,
          child: Text('body'),
        ),
      );
      // The button + expanded semantics live on the header subtree; the
      // Text widget itself sits inside that Semantics scope.
      final flags = tester.getSemantics(find.text('Details')).getSemanticsData().flagsCollection;
      expect(flags.isButton, isTrue);
      expect(flags.isExpanded, Tristate.isTrue);
      handle.dispose();
    });
  });
}
