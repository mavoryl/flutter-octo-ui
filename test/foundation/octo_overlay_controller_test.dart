import 'package:flutter_test/flutter_test.dart';
import 'package:octo_ui/octo_ui.dart';

void main() {
  group('OctoOverlayController', () {
    test('starts closed', () {
      expect(OctoOverlayController().isOpen, isFalse);
    });

    test('open() flips isOpen and notifies once', () {
      final controller = OctoOverlayController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.open();

      expect(controller.isOpen, isTrue);
      expect(notifications, 1);
    });

    test('open() on an open controller is a no-op', () {
      final controller = OctoOverlayController()..open();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.open();

      expect(controller.isOpen, isTrue);
      expect(notifications, 0);
    });

    test('close() flips isOpen and notifies once', () {
      final controller = OctoOverlayController()..open();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.close();

      expect(controller.isOpen, isFalse);
      expect(notifications, 1);
    });

    test('close() on a closed controller is a no-op', () {
      final controller = OctoOverlayController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.close();

      expect(controller.isOpen, isFalse);
      expect(notifications, 0);
    });

    test('toggle() alternates between open and closed', () {
      final controller = OctoOverlayController();

      controller.toggle();
      expect(controller.isOpen, isTrue);

      controller.toggle();
      expect(controller.isOpen, isFalse);
    });

    test('OctoMenuController is an alias of OctoOverlayController', () {
      // Existing callers type their fields as OctoMenuController; the alias
      // keeps that code compiling after the rename.
      final OctoMenuController legacy = OctoOverlayController();
      expect(legacy, isA<OctoOverlayController>());

      final OctoOverlayController current = OctoMenuController();
      expect(current, isA<OctoMenuController>());
    });
  });
}
