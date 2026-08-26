import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

/// Pumps [child] with the viewport forced to [width] logical pixels.
Future<void> _pumpAtWidth(WidgetTester tester, double width, Widget child) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OctoTheme(data: OctoThemeData.light(), child: child),
      ),
    ),
  );
}

/// Reads `context.octoBreakpoint` from inside the tree.
Widget _probe(void Function(OctoBreakpoint) onBuild) => Builder(
      builder: (context) {
        onBuild(context.octoBreakpoint);
        return const SizedBox.shrink();
      },
    );

void main() {
  group('OctoBreakpoint', () {
    test('isAtLeast compares by width order', () {
      expect(OctoBreakpoint.lg.isAtLeast(OctoBreakpoint.md), isTrue);
      expect(OctoBreakpoint.lg.isAtLeast(OctoBreakpoint.lg), isTrue);
      expect(OctoBreakpoint.sm.isAtLeast(OctoBreakpoint.lg), isFalse);
    });

    test('isAtMost compares by width order', () {
      expect(OctoBreakpoint.sm.isAtMost(OctoBreakpoint.md), isTrue);
      expect(OctoBreakpoint.md.isAtMost(OctoBreakpoint.md), isTrue);
      expect(OctoBreakpoint.xl.isAtMost(OctoBreakpoint.md), isFalse);
    });
  });

  group('context.octoBreakpoint', () {
    // Primer viewport thresholds: xs 320, sm 544, md 768, lg 1012, xl 1280,
    // xxl 1400.
    const cases = <({double width, OctoBreakpoint expected})>[
      (width: 1500, expected: OctoBreakpoint.xxl),
      (width: 1400, expected: OctoBreakpoint.xxl),
      (width: 1399, expected: OctoBreakpoint.xl),
      (width: 1280, expected: OctoBreakpoint.xl),
      (width: 1279, expected: OctoBreakpoint.lg),
      (width: 1012, expected: OctoBreakpoint.lg),
      (width: 1011, expected: OctoBreakpoint.md),
      (width: 768, expected: OctoBreakpoint.md),
      (width: 767, expected: OctoBreakpoint.sm),
      (width: 544, expected: OctoBreakpoint.sm),
      (width: 543, expected: OctoBreakpoint.xs),
      (width: 320, expected: OctoBreakpoint.xs),
    ];

    for (final c in cases) {
      testWidgets('${c.width} px resolves to ${c.expected.name}', (tester) async {
        late OctoBreakpoint seen;
        await _pumpAtWidth(tester, c.width, _probe((bp) => seen = bp));
        expect(seen, c.expected);
      });
    }

    testWidgets('a viewport narrower than the xs threshold still resolves to xs', (tester) async {
      // 280 px is below every threshold; clamping to the narrowest class beats
      // returning null and forcing every caller to handle it.
      late OctoBreakpoint seen;
      await _pumpAtWidth(tester, 280, _probe((bp) => seen = bp));
      expect(seen, OctoBreakpoint.xs);
    });

    testWidgets('thresholds come from the theme, not from constants', (tester) async {
      late OctoBreakpoint seen;
      final theme = OctoThemeData.light();
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(700, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: OctoTheme(
              // Push `md` below 700 so the same width lands one class higher.
              data: theme.copyWith(breakpoints: theme.breakpoints.copyWith(md: 640)),
              child: _probe((bp) => seen = bp),
            ),
          ),
        ),
      );
      expect(seen, OctoBreakpoint.md);
    });
  });

  group('context.isAtLeast', () {
    testWidgets('is true for the current class and everything narrower', (tester) async {
      late BuildContext ctx;
      await _pumpAtWidth(
        tester,
        1012,
        Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          },
        ),
      );
      expect(ctx.isAtLeast(OctoBreakpoint.md), isTrue);
      expect(ctx.isAtLeast(OctoBreakpoint.lg), isTrue);
      expect(ctx.isAtLeast(OctoBreakpoint.xl), isFalse);
    });
  });

  group('OctoResponsiveBuilder', () {
    testWidgets('resolves against the parent constraints, not the window', (tester) async {
      late OctoBreakpoint seen;
      await _pumpAtWidth(
        tester,
        1400, // window is xxl…
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 700, // …but the builder only gets 700 px, which is sm.
            child: OctoResponsiveBuilder(
              builder: (context, bp) {
                seen = bp;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(seen, OctoBreakpoint.sm);
    });

    testWidgets('rebuilds when the available width changes', (tester) async {
      final seen = <OctoBreakpoint>[];
      Widget tree(double width) => Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: OctoResponsiveBuilder(
                builder: (context, bp) {
                  seen.add(bp);
                  return const SizedBox.shrink();
                },
              ),
            ),
          );

      // The test surface is 800 px wide, so widths stay inside it — a wider
      // SizedBox would just be squeezed back to 800 and prove nothing.
      await _pumpAtWidth(tester, 1400, tree(780));
      await _pumpAtWidth(tester, 1400, tree(400));

      expect(seen.first, OctoBreakpoint.md);
      expect(seen.last, OctoBreakpoint.xs);
    });

    testWidgets('passes the resolved breakpoint to the child widget', (tester) async {
      await _pumpAtWidth(
        tester,
        1400,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 800,
            child: OctoResponsiveBuilder(
              builder: (context, bp) => OctoText('class: ${bp.name}'),
            ),
          ),
        ),
      );
      expect(find.text('class: md'), findsOneWidget);
    });
  });
}
