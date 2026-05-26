import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(
        data: OctoThemeData.light(),
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  group('computeSlots', () {
    test('returns the full range when it fits in maxVisible', () {
      expect(
        OctoPagination.computeSlots(currentPage: 1, pageCount: 5, maxVisible: 7),
        [1, 2, 3, 4, 5],
      );
    });

    test('inserts an ellipsis when there is a gap > 1', () {
      // 20 pages, current = 10, max = 7 → 1 … 9 10 11 … 20
      expect(
        OctoPagination.computeSlots(
          currentPage: 10,
          pageCount: 20,
          maxVisible: 7,
        ),
        [1, null, 9, 10, 11, null, 20],
      );
    });

    test('keeps first + last visible at the range edges', () {
      // current = 1: 1 2 … 20 (under maxVisible 5 ⇒ wider)
      final start = OctoPagination.computeSlots(
        currentPage: 1,
        pageCount: 20,
        maxVisible: 5,
      );
      expect(start.first, 1);
      expect(start.last, 20);
      expect(start.contains(null), isTrue);

      final end = OctoPagination.computeSlots(
        currentPage: 20,
        pageCount: 20,
        maxVisible: 5,
      );
      expect(end.first, 1);
      expect(end.last, 20);
      expect(end.contains(null), isTrue);
    });
  });

  group('OctoPagination', () {
    testWidgets('tapping a page button fires onPageChanged with that page', (tester) async {
      final requested = <int>[];
      await _pump(
        tester,
        OctoPagination(
          currentPage: 1,
          pageCount: 5,
          onPageChanged: requested.add,
        ),
      );
      await tester.tap(find.text('3'));
      expect(requested, [3]);
    });

    testWidgets('tapping the selected page is a no-op (callback skipped)', (tester) async {
      final requested = <int>[];
      await _pump(
        tester,
        OctoPagination(
          currentPage: 3,
          pageCount: 5,
          onPageChanged: requested.add,
        ),
      );
      await tester.tap(find.text('3'));
      expect(requested, isEmpty);
    });

    testWidgets('prev / next buttons step by 1', (tester) async {
      final requested = <int>[];
      await _pump(
        tester,
        OctoPagination(
          currentPage: 3,
          pageCount: 5,
          onPageChanged: requested.add,
        ),
      );
      await tester.tap(find.byIcon(OctIcons.chevron_left_16));
      await tester.tap(find.byIcon(OctIcons.chevron_right_16));
      expect(requested, [2, 4]);
    });

    testWidgets('prev is disabled on page 1, next on the last page', (tester) async {
      await _pump(
        tester,
        OctoPagination(currentPage: 1, pageCount: 5, onPageChanged: (_) {}),
      );
      // Disabled tiles don't have a tappable GestureDetector — taps go
      // through to the background. Verify by the Semantics enabled flag.
      final prev = tester.getSemantics(find.bySemanticsLabel('Previous page')).getSemanticsData();
      expect(prev.flagsCollection.isEnabled, isFalse);

      await _pump(
        tester,
        OctoPagination(currentPage: 5, pageCount: 5, onPageChanged: (_) {}),
      );
      final next = tester.getSemantics(find.bySemanticsLabel('Next page')).getSemanticsData();
      expect(next.flagsCollection.isEnabled, isFalse);
    });

    testWidgets('ellipsis renders for wide ranges', (tester) async {
      await _pump(
        tester,
        OctoPagination(
          currentPage: 10,
          pageCount: 20,
          onPageChanged: (_) {},
        ),
      );
      expect(find.text('…'), findsAtLeastNWidgets(1));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('selected tile carries the Semantics selected flag', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        OctoPagination(
          currentPage: 2,
          pageCount: 5,
          onPageChanged: (_) {},
        ),
      );
      final data = tester.getSemantics(find.bySemanticsLabel('Page 2')).getSemanticsData();
      expect(data.flagsCollection.isSelected, isTrue);
      handle.dispose();
    });
  });
}
