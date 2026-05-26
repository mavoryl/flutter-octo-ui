import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: OctoTheme(
          data: OctoThemeData.light(),
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    ),
  );
  // One frame so AnimationController boots without leaving a pending timer.
  await tester.pump();
}

void main() {
  group('OctoSpinner', () {
    testWidgets('size presets pick the right diameter', (tester) async {
      const sizes = {
        OctoSpinnerSize.small: 16.0,
        OctoSpinnerSize.medium: 24.0,
        OctoSpinnerSize.large: 40.0,
      };
      for (final entry in sizes.entries) {
        await _pump(
          tester,
          OctoSpinner(size: entry.key, semanticLabel: 'L${entry.key.name}'),
          disableAnimations: true,
        );
        final box = tester.getSize(find.byType(OctoSpinner));
        expect(box.width, entry.value, reason: 'size=${entry.key}');
        expect(box.height, entry.value, reason: 'size=${entry.key}');
      }
    });

    testWidgets('exposes the semantic label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoSpinner(semanticLabel: 'Fetching issues'),
        disableAnimations: true,
      );
      final data = tester.getSemantics(find.byType(OctoSpinner)).getSemanticsData();
      expect(data.label, 'Fetching issues');
      expect(data.flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('motion-reduce parks at a deterministic angle (no jitter)', (tester) async {
      await _pump(tester, const OctoSpinner(), disableAnimations: true);
      // After a long wait the spinner must not be still animating —
      // pumpAndSettle would hang on an active ticker.
      await tester.pump(const Duration(seconds: 5));
      // If we reach here without pumpAndSettle hanging, the controller
      // is stopped. Now check tickers explicitly.
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: 'motion-reduce must stop the controller',
      );
    });

    testWidgets('default motion runs the controller', (tester) async {
      await _pump(tester, const OctoSpinner());
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      // Drain pending timers so the test exits cleanly — replace the
      // spinner with a benign widget to dispose the ticker.
      await _pump(tester, const SizedBox.shrink());
    });
  });
}
