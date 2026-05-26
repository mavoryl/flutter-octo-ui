import 'package:flutter/material.dart' show TextField, InputDecoration, OutlineInputBorder;
import 'package:flutter/services.dart' show TextInputType, TextInputAction, TextInputFormatter;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Themed single- or multi-line text input.
///
/// Wraps Material's [TextField] for the underlying input behaviour (edit
/// state, IME, selection toolbar). All theming — border, background,
/// foreground, focus ring — is overridden to match Primer; Material
/// affordances (ripple, floating label, underline) are suppressed.
///
/// All standard text-input parameters are exposed (`controller`, `focusNode`,
/// `inputFormatters`, `obscureText`, `autofillHints`, `keyboardType`,
/// `textInputAction`, `onChanged`, `onSubmitted`, `maxLines`, etc.) so the
/// component is usable for real forms without escape hatches.
class OctoTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? initialValue;
  final String? placeholder;
  final String? label;
  final String? helperText;
  final String? errorText;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  const OctoTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.placeholder,
    this.label,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  }) : assert(
          controller == null || initialValue == null,
          'Provide either a controller or initialValue, not both.',
        );

  @override
  State<OctoTextField> createState() => _OctoTextFieldState();
}

class _OctoTextFieldState extends State<OctoTextField> {
  TextEditingController? _ownedController;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_ownedController ??= TextEditingController(text: widget.initialValue));

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

  Color _borderColor(OctoThemeData theme) {
    if (_hasError) return theme.colors.danger.emphasis;
    if (!widget.enabled) return theme.colors.border.muted;
    return theme.colors.border.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.medium));
    final borderColor = _borderColor(theme);

    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor),
    );

    return Semantics(
      textField: true,
      label: widget.label,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            ExcludeSemantics(
              child: OctoText(
                widget.label!,
                kind: OctoTextKind.label,
                color: theme.colors.fg.defaultColor,
              ),
            ),
            SizedBox(height: theme.spacing.scale(2)),
          ],
          OctoFocusRing(
            borderRadius: radius,
            child: TextField(
              controller: _effectiveController,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
              style: theme.typography.body.copyWith(color: theme.colors.fg.defaultColor),
              cursorColor: theme.colors.accent.fg,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor:
                    widget.enabled ? theme.colors.canvas.defaultColor : theme.colors.canvas.subtle,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.gap.md,
                  vertical: theme.spacing.gap.sm,
                ),
                hintText: widget.placeholder,
                hintStyle: theme.typography.body.copyWith(color: theme.colors.fg.subtle),
                border: border,
                enabledBorder: border,
                focusedBorder: border,
                disabledBorder: border,
                errorBorder: border,
                focusedErrorBorder: border,
                counterText: '',
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
            ),
          ),
          if (widget.helperText != null || _hasError) ...[
            SizedBox(height: theme.spacing.scale(2)),
            OctoText(
              _hasError ? widget.errorText! : widget.helperText!,
              kind: OctoTextKind.labelSmall,
              color: _hasError ? theme.colors.danger.fg : theme.colors.fg.muted,
            ),
          ],
        ],
      ),
    );
  }
}
