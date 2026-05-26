import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

class _Probe extends StatelessWidget {
  final FocusNode node;

  const _Probe({required this.node});

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: node,
      child: const OctoFocusRing(
        child: SizedBox(width: 80, height: 32),
      ),
    );
  }
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: child),
    ),
  );
}

void main() {
  group('OctoFocusRing', () {
    testWidgets('does NOT show without focus', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(tester, _Probe(node: node));
      expect(find.byType(CustomPaint), findsNothing);
    });

    testWidgets('shows when focused under keyboard highlight mode', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(tester, _Probe(node: node));

      node.requestFocus();
      await tester.pumpAndSettle();

      expect(
        node.hasPrimaryFocus,
        isTrue,
        reason: 'precondition: node should have primary focus',
      );
      expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('hides when highlight mode is touch', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTouch;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(tester, _Probe(node: node));

      node.requestFocus();
      await tester.pump();

      expect(find.byType(CustomPaint), findsNothing);
    });

    testWidgets('hides when enabled=false even with focus', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
      });
      final node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        Focus(
          focusNode: node,
          child: const OctoFocusRing(
            enabled: false,
            child: SizedBox(width: 80, height: 32),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      expect(find.byType(CustomPaint), findsNothing);
    });
  });
}
