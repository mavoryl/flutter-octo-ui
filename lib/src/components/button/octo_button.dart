import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_focus_ring.dart';
import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Visual emphasis of an [OctoButton].
///
/// `primary`   — solid accent emphasis. Use sparingly: one per surface.
/// `standard`  — outlined, neutral background. Default action button.
/// `danger`    — solid danger emphasis. Destructive operations.
/// `invisible` — no chrome until hovered. Toolbar / inline actions.
enum OctoButtonVariant { primary, standard, danger, invisible }

/// Compact sizing — Primer ships small / medium / large.
enum OctoButtonSize { small, medium, large }

/// Resolved color set for one (variant, state) pair.
class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color? border;

  const _ButtonColors({required this.background, required this.foreground, this.border});
}

/// Primer-style action button.
///
/// Composes [OctoFocusRing] (ADR-0006) and [OctoStateLayer] (ADR-0001) and
/// tracks state through a [WidgetStatesController] driven by a
/// [FocusableActionDetector]. Reads colours and metrics from the enclosing
/// [OctoTheme].
class OctoButton extends StatefulWidget {
  /// Visible child — typically text. Use [OctoButton.label] for the common
  /// string case so the semantic label is auto-populated.
  final Widget child;

  /// Called on tap. When `null`, the button renders disabled and ignores
  /// pointer / keyboard input.
  final VoidCallback? onPressed;

  final OctoButtonVariant variant;
  final OctoButtonSize size;

  /// When `true`, displays a spinner in place of the leading content and
  /// disables interaction. The button keeps its width to avoid layout
  /// shift mid-action.
  final bool loading;

  final Widget? leadingIcon;
  final Widget? trailingIcon;

  /// Accessibility label. Defaults to `child`'s text when [OctoButton.label]
  /// is used.
  final String? semanticLabel;

  final FocusNode? focusNode;
  final bool autofocus;

  const OctoButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = OctoButtonVariant.standard,
    this.size = OctoButtonSize.medium,
    this.loading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  /// Convenience for text-only buttons. The string is rendered with
  /// [OctoText] and also used as the semantic label.
  OctoButton.label(
    String label, {
    super.key,
    required this.onPressed,
    this.variant = OctoButtonVariant.standard,
    this.size = OctoButtonSize.medium,
    this.loading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.focusNode,
    this.autofocus = false,
  })  : child = OctoText(label, kind: OctoTextKind.bodyEmphasis),
        semanticLabel = label;

  @override
  State<OctoButton> createState() => _OctoButtonState();
}

class _OctoButtonState extends State<OctoButton> {
  late final WidgetStatesController _states;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController();
    _syncEnabled();
  }

  @override
  void didUpdateWidget(OctoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncEnabled();
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _syncEnabled() {
    _states.update(WidgetState.disabled, !_enabled);
    if (!_enabled) {
      _states.update(WidgetState.hovered, false);
      _states.update(WidgetState.pressed, false);
    }
  }

  void _handleTapDown(TapDownDetails _) {
    if (_enabled) _states.update(WidgetState.pressed, true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (_enabled) _states.update(WidgetState.pressed, false);
  }

  void _handleTapCancel() {
    if (_enabled) _states.update(WidgetState.pressed, false);
  }

  void _handleTap() {
    if (_enabled) widget.onPressed!();
  }

  void _handleHover(bool hovered) {
    if (_enabled) _states.update(WidgetState.hovered, hovered);
  }

  void _handleFocusChange(bool focused) {
    _states.update(WidgetState.focused, focused);
  }

  EdgeInsetsGeometry _padding(OctoThemeData theme) => switch (widget.size) {
        OctoButtonSize.small => EdgeInsets.symmetric(
            horizontal: theme.spacing.gap.md,
            vertical: theme.spacing.scale(2),
          ),
        OctoButtonSize.medium => EdgeInsets.symmetric(
            horizontal: theme.spacing.gap.lg,
            vertical: theme.spacing.gap.sm,
          ),
        OctoButtonSize.large => EdgeInsets.symmetric(
            horizontal: theme.spacing.gap.xl,
            vertical: theme.spacing.gap.md,
          ),
      };

  double _minHeight() => switch (widget.size) {
        OctoButtonSize.small => 28,
        OctoButtonSize.medium => 32,
        OctoButtonSize.large => 40,
      };

  _ButtonColors _resolveColors(OctoThemeData theme, Set<WidgetState> states) {
    final disabled = states.contains(WidgetState.disabled);
    switch (widget.variant) {
      case OctoButtonVariant.primary:
        return _ButtonColors(
          background: disabled ? theme.colors.neutral.muted : theme.colors.accent.emphasis,
          foreground: disabled ? theme.colors.fg.muted : theme.colors.fg.onEmphasis,
        );
      case OctoButtonVariant.standard:
        return _ButtonColors(
          background: disabled ? theme.colors.canvas.subtle : theme.colors.canvas.defaultColor,
          foreground: disabled ? theme.colors.fg.muted : theme.colors.fg.defaultColor,
          border: theme.colors.border.defaultColor,
        );
      case OctoButtonVariant.danger:
        return _ButtonColors(
          background: disabled ? theme.colors.neutral.muted : theme.colors.danger.emphasis,
          foreground: disabled ? theme.colors.fg.muted : theme.colors.fg.onEmphasis,
        );
      case OctoButtonVariant.invisible:
        return _ButtonColors(
          background: const Color(0x00000000),
          foreground: disabled ? theme.colors.fg.muted : theme.colors.fg.defaultColor,
        );
    }
  }

  double _spinnerSize() => switch (widget.size) {
        OctoButtonSize.small => 12,
        OctoButtonSize.medium => 14,
        OctoButtonSize.large => 16,
      };

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final borderRadius = BorderRadius.all(Radius.circular(theme.radii.medium));

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _enabled ? _handleTap : null,
          child: FocusableActionDetector(
            enabled: _enabled,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            onFocusChange: _handleFocusChange,
            shortcuts: const <ShortcutActivator, Intent>{
              SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
              SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
            },
            actions: <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  _handleTap();
                  return null;
                },
              ),
            },
            child: ListenableBuilder(
              listenable: _states,
              builder: (context, _) {
                final states = _states.value;
                final colors = _resolveColors(theme, states);
                return OctoFocusRing(
                  borderRadius: borderRadius,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: _minHeight()),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: borderRadius,
                        border: colors.border != null ? Border.all(color: colors.border!) : null,
                      ),
                      child: OctoStateLayer(
                        states: states,
                        borderRadius: borderRadius,
                        child: Padding(
                          padding: _padding(theme),
                          child: _buildContent(theme, colors.foreground),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(OctoThemeData theme, Color fg) {
    final gap = SizedBox(width: theme.spacing.gap.sm);
    final children = <Widget>[];

    if (widget.loading) {
      children.add(
        SizedBox(
          width: _spinnerSize(),
          height: _spinnerSize(),
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        ),
      );
      children.add(gap);
    } else if (widget.leadingIcon != null) {
      children.add(IconTheme(data: IconThemeData(color: fg, size: 16), child: widget.leadingIcon!));
      children.add(gap);
    }

    children.add(
      DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: widget.child,
      ),
    );

    if (widget.trailingIcon != null && !widget.loading) {
      children.add(gap);
      children.add(
        IconTheme(data: IconThemeData(color: fg, size: 16), child: widget.trailingIcon!),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
