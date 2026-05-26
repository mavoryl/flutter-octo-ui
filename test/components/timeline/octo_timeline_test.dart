import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OctoTheme(
        data: OctoThemeData.light(),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 360, child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('OctoTimeline', () {
    testWidgets('renders title + subtitle for every entry', (tester) async {
      await _pump(
        tester,
        const OctoTimeline(
          items: [
            OctoTimelineItem(
              icon: OctIcons.git_commit_16,
              title: 'Created branch feature/foo',
              subtitle: '2 hours ago',
            ),
            OctoTimelineItem(
              icon: OctIcons.git_pull_request_16,
              title: 'Opened pull request #42',
              variant: OctoTimelineVariant.success,
            ),
          ],
        ),
      );
      expect(find.text('Created branch feature/foo'), findsOneWidget);
      expect(find.text('2 hours ago'), findsOneWidget);
      expect(find.text('Opened pull request #42'), findsOneWidget);
    });

    testWidgets('renders the body widget when supplied', (tester) async {
      await _pump(
        tester,
        const OctoTimeline(
          items: [
            OctoTimelineItem(
              icon: OctIcons.comment_16,
              title: 'Commented',
              body: Text('LGTM — ship it.'),
            ),
          ],
        ),
      );
      expect(find.text('LGTM — ship it.'), findsOneWidget);
    });

    testWidgets('marker variant maps to the right theme colour', (tester) async {
      final theme = OctoThemeData.light();
      await _pump(
        tester,
        const OctoTimeline(
          items: [
            OctoTimelineItem(
              icon: OctIcons.x_circle_16,
              title: 'Failed deploy',
              variant: OctoTimelineVariant.danger,
            ),
          ],
        ),
      );
      // The marker disc is a Container(decoration: BoxDecoration(color, shape: circle)).
      final disc = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(OctoTimeline),
              matching: find.byWidgetPredicate((w) {
                if (w is! Container) return false;
                final d = w.decoration;
                return d is BoxDecoration && d.shape == BoxShape.circle;
              }),
            )
            .first,
      );
      expect(
        (disc.decoration as BoxDecoration).color,
        theme.colors.danger.emphasis,
      );
    });

    testWidgets('semanticLabel override sits on the entry', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const OctoTimeline(
          items: [
            OctoTimelineItem(
              icon: OctIcons.git_commit_16,
              title: 'Pushed 3 commits',
              semanticLabel: 'Anna pushed 3 commits to main',
            ),
          ],
        ),
      );
      final data = tester.getSemantics(find.text('Pushed 3 commits')).getSemanticsData();
      expect(data.label, contains('Anna pushed 3 commits to main'));
      handle.dispose();
    });

    testWidgets('empty items list builds without throwing', (tester) async {
      await _pump(tester, const OctoTimeline(items: []));
      expect(find.byType(OctoTimeline), findsOneWidget);
    });
  });
}
