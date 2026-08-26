import 'package:flutter/foundation.dart';

/// Drives the open / closed state of an anchored overlay — [OctoMenu],
/// [OctoPopover], and anything else that shows a transient surface next to
/// a trigger widget.
///
/// Hold one instance per overlay in your `State`, dispose it in `dispose()`,
/// and wire trigger gestures (button tap, keyboard shortcut) to
/// [open] / [close] / [toggle]. The overlay listens via `addListener` and
/// shows or hides itself accordingly.
class OctoOverlayController extends ChangeNotifier {
  bool _isOpen = false;

  /// `true` while the overlay is shown.
  bool get isOpen => _isOpen;

  /// Shows the overlay. No-op if already open.
  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Hides the overlay. No-op if already closed.
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Flips the open state.
  void toggle() => _isOpen ? close() : open();
}
