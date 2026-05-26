import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child, {bool reduceMotion = false}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: OctoTheme(data: OctoThemeData.light(), child: Center(child: child)),
      ),
    ),
  );
}

void main() {
  group('OctoSkeleton', () {
    testWidgets('renders a block of the requested size', (tester) async {
      await _pump(tester, const OctoSkeleton(width: 120, height: 16));
      // SizedBox(0,0) wrappers are also present in the tree; filter to
      // ours by exact size.
      final sized = tester.widgetList<SizedBox>(find.byType(SizedBox)).firstWhere(
            (s) => s.width == 120 && s.height == 16,
          );
      expect(sized.width, 120);
      expect(sized.height, 16);
    });

    testWidgets('disableAnimations skips the animated rebuilds', (tester) async {
      await _pump(
        tester,
        const OctoSkeleton(height: 16),
        reduceMotion: true,
      );
      // With reduce-motion the static branch returns a plain DecoratedBox
      // (no AnimatedBuilder ancestor).
      expect(find.byType(AnimatedBuilder), findsNothing);
    });

    testWidgets('wraps content in ExcludeSemantics so it is invisible to a11y', (tester) async {
      await _pump(tester, const OctoSkeleton(height: 16));
      expect(find.byType(ExcludeSemantics), findsOneWidget);
    });
  });

  group('OctoSkeletonText', () {
    testWidgets('lines=N renders N skeleton blocks', (tester) async {
      await _pump(tester, const OctoSkeletonText(lines: 4, width: 200));
      expect(find.byType(OctoSkeleton), findsNWidgets(4));
    });

    testWidgets('rejects lines <= 0 via assertion', (tester) async {
      expect(() => OctoSkeletonText(lines: 0), throwsAssertionError);
    });
  });

  group('OctoSkeletonAvatar', () {
    testWidgets('produces a circular block matching size', (tester) async {
      await _pump(tester, const OctoSkeletonAvatar(size: 48));
      final inner = tester.widget<OctoSkeleton>(find.byType(OctoSkeleton));
      expect(inner.width, 48);
      expect(inner.height, 48);
    });
  });
}
