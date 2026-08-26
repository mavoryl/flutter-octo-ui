import 'package:octo_ui/src/foundation/octo_overlay_controller.dart';

/// Legacy name for [OctoOverlayController], kept so existing call sites
/// that type their fields as `OctoMenuController` keep compiling.
///
/// The driver is shared by every anchored overlay in the kit — prefer
/// [OctoOverlayController] in new code.
typedef OctoMenuController = OctoOverlayController;
