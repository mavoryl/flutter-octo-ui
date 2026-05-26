import 'package:flutter/widgets.dart';
import 'package:flutter_octicons/flutter_octicons.dart' show OctIcons;

import 'package:octo_ui/src/foundation/octo_state_layer.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Semantic colour family of a chip.
enum OctoChipVariant {
  /// Neutral filled chip — generic tag / filter pill.
  standard,

  /// Accent-tinted chip — active filter, mentioned user.
  accent,

  /// Positive-state chip — green-toned classification.
  success,

  /// Warning-state chip — yellow-toned classification.
  attention,

  /// Destructive-state chip — red-toned classification.
  danger,
}

/// Compact interactive pill (Primer "Chip").
///
/// Distinguished from [OctoLabel] in two ways: chips are interactive
/// (tap and / or dismiss), and they ship filled (subtle background)
/// rather than outlined. Common uses are filter chips, recipient chips
/// in an email field, and selected-tag previews.
class OctoChip extends StatefulWidget {
  /// Visible label text.
  final String label;

  /// Optional leading widget (typically a small icon or avatar).
  final Widget? leading;

  /// Tap handler — `null` for a non-clickable display chip.
  final VoidCallback? onPressed;

  /// Dismiss handler — when non-null, a trailing `x_16` close button is
  /// rendered.
  final VoidCallback? onDismiss;

  /// Colour family. See [OctoChipVariant].
  final OctoChipVariant variant;

  /// Accessibility label for the chip. Defaults to [label].
  final String? semanticLabel;

  /// Accessibility label for the dismiss button. Defaults to
  /// `'Remove $label'`.
  final String? dismissSemanticLabel;

  /// Creates an interactive chip.
  const OctoChip({
    super.key,
    required this.label,
    this.leading,
    this.onPressed,
    this.onDismiss,
    this.variant = OctoChipVariant.standard,
    this.semanticLabel,
    this.dismissSemanticLabel,
  });

  @override
  State<OctoChip> createState() => _OctoChipState();
}

class _OctoChipState extends State<OctoChip> {
  late final WidgetStatesController _states;

  @override
  void initState() {
    super.initState();
    _states = WidgetStatesController(<WidgetState>{
      if (widget.onPressed == null) WidgetState.disabled,
    });
  }

  @override
  void didUpdateWidget(OctoChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _states.update(WidgetState.disabled, widget.onPressed == null);
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  bool get _interactive => widget.onPressed != null;

  ({Color background, Color foreground}) _resolveColors(OctoThemeData theme) {
    switch (widget.variant) {
      case OctoChipVariant.standard:
        return (background: theme.colors.neutral.subtle, foreground: theme.colors.fg.defaultColor);
      case OctoChipVariant.accent:
        return (background: theme.colors.accent.subtle, foreground: theme.colors.accent.fg);
      case OctoChipVariant.success:
        return (background: theme.colors.success.subtle, foreground: theme.colors.success.fg);
      case OctoChipVariant.attention:
        return (background: theme.colors.attention.subtle, foreground: theme.colors.attention.fg);
      case OctoChipVariant.danger:
        return (background: theme.colors.danger.subtle, foreground: theme.colors.danger.fg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final colors = _resolveColors(theme);
    final radius = BorderRadius.all(Radius.circular(theme.radii.full));

    final body = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.gap.sm,
        vertical: theme.spacing.scale(1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leading != null) ...[
            IconTheme(
              data: IconThemeData(color: colors.foreground, size: 12),
              child: widget.leading!,
            ),
            SizedBox(width: theme.spacing.gap.xs),
          ],
          OctoText(
            widget.label,
            kind: OctoTextKind.labelSmall,
            color: colors.foreground,
          ),
          if (widget.onDismiss != null) ...[
            SizedBox(width: theme.spacing.gap.xs),
            _ChipDismissButton(
              onPressed: widget.onDismiss!,
              color: colors.foreground,
              semanticLabel: widget.dismissSemanticLabel ?? 'Remove ${widget.label}',
            ),
          ],
        ],
      ),
    );

    final pill = MergeSemantics(
      child: Semantics(
        button: _interactive,
        enabled: _interactive,
        label: widget.semanticLabel ?? widget.label,
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.background, borderRadius: radius),
          child: _interactive
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => _states.update(WidgetState.hovered, true),
                  onExit: (_) => _states.update(WidgetState.hovered, false),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onPressed,
                    onTapDown: (_) => _states.update(WidgetState.pressed, true),
                    onTapUp: (_) => _states.update(WidgetState.pressed, false),
                    onTapCancel: () => _states.update(WidgetState.pressed, false),
                    child: ListenableBuilder(
                      listenable: _states,
                      builder: (context, _) => OctoStateLayer(
                        states: _states.value,
                        borderRadius: radius,
                        child: body,
                      ),
                    ),
                  ),
                )
              : body,
        ),
      ),
    );

    return pill;
  }
}

/// Compact 16×16 X-button used only inside [OctoChip]. We don't reuse
/// [OctoIconButton] here — that component carries a 28 px minimum height
/// from [OctoButtonSize.small], which would inflate the chip whenever a
/// dismiss is attached and create the visual size mismatch between
/// chips with and without an `X`.
class _ChipDismissButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final String semanticLabel;

  const _ChipDismissButton({
    required this.onPressed,
    required this.color,
    required this.semanticLabel,
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
            width: 16,
            height: 16,
            child: Center(child: Icon(OctIcons.x_16, size: 12, color: color)),
          ),
        ),
      ),
    );
  }
}
