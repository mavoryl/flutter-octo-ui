import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    OctoTheme(
      data: OctoThemeData.light(),
      child: MaterialApp(
        theme: OctoThemeData.light().toMaterialTheme(),
        home: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}

void main() {
  group('OctoDialog', () {
    testWidgets('show renders title + content + actions', (tester) async {
      late BuildContext capturedCtx;
      await _pump(
        tester,
        Builder(
          builder: (ctx) {
            capturedCtx = ctx;
            return const SizedBox.shrink();
          },
        ),
      );

      unawaited(
        OctoDialog.show<void>(
          context: capturedCtx,
          title: const OctoDialogTitle('Delete repository?'),
          content: const OctoText('This action cannot be undone.'),
          actions: [
            OctoButton.label('Cancel', onPressed: () => Navigator.pop(capturedCtx)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete repository?'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('action button pops with its value', (tester) async {
      late BuildContext capturedCtx;
      await _pump(
        tester,
        Builder(
          builder: (ctx) {
            capturedCtx = ctx;
            return const SizedBox.shrink();
          },
        ),
      );

      final future = OctoDialog.show<String>(
        context: capturedCtx,
        title: const OctoDialogTitle('Pick'),
        actions: [
          Builder(
            builder: (ctx) => OctoButton.label(
              'OK',
              onPressed: () => Navigator.pop(ctx, 'ok'),
              variant: OctoButtonVariant.primary,
            ),
          ),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await future, 'ok');
    });

    testWidgets('Escape dismisses the dialog with null', (tester) async {
      late BuildContext capturedCtx;
      await _pump(
        tester,
        Builder(
          builder: (ctx) {
            capturedCtx = ctx;
            return const SizedBox.shrink();
          },
        ),
      );

      final future = OctoDialog.show<String>(
        context: capturedCtx,
        title: const OctoDialogTitle('Confirm'),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });

    testWidgets('outside tap dismisses when barrierDismissible (default)', (tester) async {
      late BuildContext capturedCtx;
      await _pump(
        tester,
        Builder(
          builder: (ctx) {
            capturedCtx = ctx;
            return const SizedBox.shrink();
          },
        ),
      );

      final future = OctoDialog.show<String>(
        context: capturedCtx,
        title: const OctoDialogTitle('Confirm'),
      );
      await tester.pumpAndSettle();
      // Tap top-left of the viewport — that's the scrim, outside the
      // centered dialog content.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });
  });
}
