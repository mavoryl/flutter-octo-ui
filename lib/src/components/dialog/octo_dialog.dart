import 'package:flutter/material.dart' show Dialog, showDialog;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Themed modal dialog (Primer "Dialog").
///
/// Use the static [OctoDialog.show] helper to display one — it wraps
/// Flutter's `showDialog` and returns a `Future<T?>` that completes when
/// the dialog pops. Each action button wires its own
/// `Navigator.pop(context, value)` to surface a result.
///
/// Layout slots:
///   * [title] — heading row (`OctoTypography.heading`).
///   * [content] — body widget (typically text or a form).
///   * [actions] — right-aligned button row at the bottom; usually
///     `OctoButton`s.
///
/// `Escape` and an outside-tap on the scrim both dismiss the dialog
/// (return `null`). The dialog surface picks up `canvas.overlay`,
/// `border.defaultColor`, `radii.large`, and `shadows.large` from the
/// enclosing [OctoTheme].
class OctoDialog extends StatelessWidget {
  /// Heading content. Inherits [OctoTypography.heading].
  final Widget? title;

  /// Body content. Inherits [OctoTypography.body].
  final Widget? content;

  /// Right-aligned action buttons at the bottom of the dialog.
  final List<Widget>? actions;

  /// Caps the dialog width.
  final double maxWidth;

  /// Creates a dialog widget. Most callers use [OctoDialog.show] instead.
  const OctoDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.maxWidth = 480,
  });

  /// Shows an [OctoDialog] over the nearest [Navigator] and returns a
  /// future that completes with the value passed to `Navigator.pop`.
  ///
  /// [barrierDismissible] controls whether tapping the scrim closes the
  /// dialog (default `true`).
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    double maxWidth = 480,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => OctoDialog(
        title: title,
        content: content,
        actions: actions,
        maxWidth: maxWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              Navigator.of(context).maybePop();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          skipTraversal: true,
          child: Dialog(
            backgroundColor: theme.colors.canvas.overlay,
            surfaceTintColor: theme.colors.canvas.overlay,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(theme.radii.large)),
              side: BorderSide(color: theme.colors.border.defaultColor),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.gap.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title != null) ...[
                      DefaultTextStyle.merge(
                        style: theme.typography.heading.copyWith(
                          color: theme.colors.fg.defaultColor,
                        ),
                        child: title!,
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                    ],
                    if (content != null) ...[
                      DefaultTextStyle.merge(
                        style: theme.typography.body.copyWith(
                          color: theme.colors.fg.defaultColor,
                        ),
                        child: content!,
                      ),
                      SizedBox(height: theme.spacing.gap.xl),
                    ],
                    if (actions != null && actions!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (var i = 0; i < actions!.length; i++) ...[
                            if (i > 0) SizedBox(width: theme.spacing.gap.sm),
                            actions![i],
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sugar for a simple text title — `OctoDialog(title: OctoDialogTitle('…'))`.
class OctoDialogTitle extends StatelessWidget {
  /// Heading text.
  final String text;

  /// Wraps [text] in an [OctoText] using [OctoTextKind.heading].
  const OctoDialogTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => OctoText(text, kind: OctoTextKind.heading);
}
