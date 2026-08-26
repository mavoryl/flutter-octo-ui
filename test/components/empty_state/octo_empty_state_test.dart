import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(data: OctoThemeData.light(), child: Center(child: child)),
    ),
  );
}

void main() {
  group('OctoEmptyState', () {
    testWidgets('renders the title', (tester) async {
      await _pump(tester, const OctoEmptyState(title: 'No issues yet'));
      expect(find.text('No issues yet'), findsOneWidget);
    });

    testWidgets('renders the description when provided', (tester) async {
      await _pump(
        tester,
        const OctoEmptyState(
          title: 'No issues yet',
          description: 'Issues let you track work on this repository.',
        ),
      );
      expect(find.text('Issues let you track work on this repository.'), findsOneWidget);
    });

    testWidgets('omits the description node when null', (tester) async {
      await _pump(tester, const OctoEmptyState(title: 'Empty'));
      expect(find.byType(OctoText), findsOneWidget);
    });

    testWidgets('description uses the muted foreground token', (tester) async {
      await _pump(
        tester,
        const OctoEmptyState(title: 'Empty', description: 'Nothing here'),
      );
      final theme = OctoThemeData.light();
      final description = tester.widget<OctoText>(
        find.byWidgetPredicate((w) => w is OctoText && w.data == 'Nothing here'),
      );
      expect(description.color, theme.colors.fg.muted);
    });

    testWidgets('renders the icon when provided and hides it from semantics', (tester) async {
      await _pump(
        tester,
        const OctoEmptyState(title: 'Empty', icon: OctIcons.issue_opened_24),
      );
      expect(find.byType(OctoIcon), findsOneWidget);
      expect(
        find.ancestor(of: find.byType(OctoIcon), matching: find.byType(ExcludeSemantics)),
        findsOneWidget,
      );
    });

    testWidgets('omits the icon node when null', (tester) async {
      await _pump(tester, const OctoEmptyState(title: 'Empty'));
      expect(find.byType(OctoIcon), findsNothing);
    });

    testWidgets('renders every action', (tester) async {
      await _pump(
        tester,
        OctoEmptyState(
          title: 'Empty',
          actions: [
            OctoButton.label('New issue', onPressed: () {}),
            OctoButton.label('Learn more', onPressed: () {}),
          ],
        ),
      );
      expect(find.text('New issue'), findsOneWidget);
      expect(find.text('Learn more'), findsOneWidget);
    });

    testWidgets('actions stay tappable', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        OctoEmptyState(
          title: 'Empty',
          actions: [OctoButton.label('New issue', onPressed: () => taps++)],
        ),
      );
      await tester.tap(find.text('New issue'));
      expect(taps, 1);
    });

    testWidgets('title is announced as a header', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const OctoEmptyState(title: 'No issues yet'));
      final node = tester.getSemantics(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.header == true),
      );
      expect(node.label, contains('No issues yet'));
      handle.dispose();
    });

    testWidgets('content is centred', (tester) async {
      await _pump(tester, const OctoEmptyState(title: 'Empty'));
      final column = tester.widget<Column>(
        find.descendant(of: find.byType(OctoEmptyState), matching: find.byType(Column)).first,
      );
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
    });
  });
}
