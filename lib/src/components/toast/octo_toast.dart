import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Semantic colour family of an [OctoToast]. Drives the leading-icon tint
/// and the announcement assertiveness.
enum OctoToastVariant {
  /// Neutral message (accent-tinted icon).
  info,

  /// Positive confirmation (green icon).
  success,

  /// Caution / warning (yellow icon).
  attention,

  /// Failure / error (red icon, assertive announcement).
  danger,
}

/// Optional trailing action attached to an [OctoToast].
class OctoToastAction {
  /// Visible button label.
  final String label;

  /// Tap handler. The toast auto-dismisses after the action fires.
  final VoidCallback onPressed;

  /// Creates an action button descriptor.
  const OctoToastAction({required this.label, required this.onPressed});
}

/// Handle returned by [OctoToast.show]. Call [dismiss] to remove the
/// toast before its auto-timer fires.
class OctoToastController {
  void Function()? _dismiss;
  bool _isDismissed = false;

  OctoToastController._();

  /// `true` once the toast has been removed from the overlay.
  bool get isDismissed => _isDismissed;

  /// Removes the toast from the overlay immediately.
  void dismiss() {
    if (_isDismissed) return;
    _isDismissed = true;
    _dismiss?.call();
  }
}

/// Transient floating status pill (Primer "Toast"). Designed to be shown
/// over the current screen and dismissed automatically after a few
/// seconds — for "saved", "copied", "failed to upload" style feedback.
///
/// Construct directly only when embedding inside a custom layout
/// (snapshots, demos). For ad-hoc usage prefer [OctoToast.show], which
/// pushes the toast through the nearest [Overlay], slides it in from
/// the bottom-center, schedules auto-dismiss, and returns an
/// [OctoToastController] for manual control.
class OctoToast extends StatefulWidget {
  /// Body text.
  final String message;

  /// Status family. Drives the leading-icon colour and the live-region
  /// assertiveness.
  final OctoToastVariant variant;

  /// Optional action button.
  final OctoToastAction? action;

  /// When `true`, renders a trailing `x_16` dismiss button.
  final bool dismissible;

  /// Fires when the user hits the dismiss button.
  final VoidCallback? onDismiss;

  /// Accessibility label for the dismiss button.
  final String dismissSemanticLabel;

  /// Creates a self-contained toast pill. Animation and lifecycle must
  /// be handled by the caller — use [OctoToast.show] for the common
  /// "show + auto-dismiss" flow.
  const OctoToast({
    super.key,
    required this.message,
    this.variant = OctoToastVariant.info,
    this.action,
    this.dismissible = false,
    this.onDismiss,
    this.dismissSemanticLabel = 'Dismiss',
  });

  /// Shows a toast through the nearest [Overlay].
  ///
  /// The returned [OctoToastController] can be used to dismiss the
  /// toast before its [duration] elapses. Passing `Duration.zero`
  /// disables the auto-dismiss timer — the toast stays until the user
  /// dismisses it manually or the controller is fired.
  static OctoToastController show(
    BuildContext context, {
    required String message,
    OctoToastVariant variant = OctoToastVariant.info,
    Duration duration = const Duration(seconds: 4),
    OctoToastAction? action,
    bool dismissible = true,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    // The root Overlay sits above the OctoTheme inherited at [context],
    // so we re-inject it (and the ambient Directionality) into the entry
    // subtree — otherwise OctoTheme.of inside the toast pill throws.
    final themeData = OctoTheme.of(context);
    final direction = Directionality.of(context);
    final controller = OctoToastController._();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Directionality(
        textDirection: direction,
        child: OctoTheme(
          data: themeData,
          // OverlayEntry mounts ABOVE the MaterialApp's DefaultTextStyle.
          // Without an explicit one here, `Text` falls back to the framework
          // "missing-style" sentinel — the well-known double-yellow
          // underline. Seed it with the theme's body style.
          child: DefaultTextStyle(
            style: themeData.typography.body.copyWith(
              color: themeData.colors.fg.defaultColor,
            ),
            child: _OctoToastEntry(
              message: message,
              variant: variant,
              duration: duration,
              action: action,
              dismissible: dismissible,
              onRemoved: () {
                if (entry.mounted) entry.remove();
                controller._isDismissed = true;
              },
              registerDismiss: (cb) => controller._dismiss = cb,
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    return controller;
  }

  @override
  State<OctoToast> createState() => _OctoToastState();
}

class _OctoToastState extends State<OctoToast> {
  IconData get _icon {
    switch (widget.variant) {
      case OctoToastVariant.info:
        return OctIcons.info_16;
      case OctoToastVariant.success:
        return OctIcons.check_circle_16;
      case OctoToastVariant.attention:
        return OctIcons.alert_16;
      case OctoToastVariant.danger:
        return OctIcons.x_circle_16;
    }
  }

  Color _iconColor(OctoThemeData theme) {
    switch (widget.variant) {
      case OctoToastVariant.info:
        return theme.colors.accent.emphasis;
      case OctoToastVariant.success:
        return theme.colors.success.emphasis;
      case OctoToastVariant.attention:
        return theme.colors.attention.emphasis;
      case OctoToastVariant.danger:
        return theme.colors.danger.emphasis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));
    final iconColor = _iconColor(theme);
    final fg = theme.colors.fg.onEmphasis;

    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.neutral.emphasis,
          borderRadius: radius,
          boxShadow: theme.shadows.large,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.gap.md,
            vertical: theme.spacing.gap.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 16, color: iconColor),
              SizedBox(width: theme.spacing.gap.sm),
              Flexible(
                child: OctoText(widget.message, color: fg),
              ),
              if (widget.action != null) ...[
                SizedBox(width: theme.spacing.gap.md),
                _ToastTextButton(
                  label: widget.action!.label,
                  color: fg,
                  onPressed: widget.action!.onPressed,
                ),
              ],
              if (widget.dismissible) ...[
                SizedBox(width: theme.spacing.gap.sm),
                _ToastIconButton(
                  icon: OctIcons.x_16,
                  semanticLabel: widget.dismissSemanticLabel,
                  color: fg,
                  onPressed: widget.onDismiss ?? () {},
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastTextButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ToastTextButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: OctoText(label, kind: OctoTextKind.bodyEmphasis, color: color),
        ),
      ),
    );
  }
}

class _ToastIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final Color color;
  final VoidCallback onPressed;

  const _ToastIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox(
            width: 20,
            height: 20,
            child: Center(child: Icon(icon, size: 14, color: color)),
          ),
        ),
      ),
    );
  }
}

class _OctoToastEntry extends StatefulWidget {
  final String message;
  final OctoToastVariant variant;
  final Duration duration;
  final OctoToastAction? action;
  final bool dismissible;
  final VoidCallback onRemoved;
  final void Function(VoidCallback dismiss) registerDismiss;

  const _OctoToastEntry({
    required this.message,
    required this.variant,
    required this.duration,
    required this.action,
    required this.dismissible,
    required this.onRemoved,
    required this.registerDismiss,
  });

  @override
  State<_OctoToastEntry> createState() => _OctoToastEntryState();
}

class _OctoToastEntryState extends State<_OctoToastEntry> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _autoDismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_controller);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    widget.registerDismiss(_beginDismiss);
    _controller.forward();
    if (widget.duration > Duration.zero) {
      _autoDismissTimer = Timer(widget.duration, _beginDismiss);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnims = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnims) {
      _controller.duration = Duration.zero;
      // Snap to fully visible if we hadn't already.
      if (_controller.value < 1 && !_dismissed) _controller.value = 1;
    }
  }

  void _beginDismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _autoDismissTimer?.cancel();
    _controller.reverse().whenComplete(() {
      if (mounted) widget.onRemoved();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: mq.padding.bottom + 24,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: OctoToast(
                message: widget.message,
                variant: widget.variant,
                action: widget.action != null
                    ? OctoToastAction(
                        label: widget.action!.label,
                        onPressed: () {
                          widget.action!.onPressed();
                          _beginDismiss();
                        },
                      )
                    : null,
                dismissible: widget.dismissible,
                onDismiss: _beginDismiss,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
