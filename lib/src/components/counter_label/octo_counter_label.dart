import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';
import 'package:octo_ui/src/theme/theme_data.dart';

/// Visual emphasis of an [OctoCounterLabel] pill.
///
/// `standard` is the neutral grey count; `primary` tints with accent
/// (used for the currently-selected tab's counter); `secondary` uses the
/// neutral muted fill but with a transparent background to sit on busy
/// surfaces.
enum OctoCounterLabelVariant {
  /// Neutral filled pill — generic count.
  standard,

  /// Accent-tinted pill — highlights the active tab / section.
  primary,

  /// Transparent pill with neutral text — sits inside busy surfaces.
  secondary,
}

/// Compact numeric counter (Primer "CounterLabel"). Used next to tab
/// titles, list section headers, navigation items — anything that needs a
/// glanceable count.
///
/// Renders [count] with [OctoTextKind.labelSmall] inside a filled pill;
/// the background is full-radius so single-digit counts look like circles.
/// When [maxDisplayed] is non-null and [count] exceeds it, the visible
/// value is clamped and a `+` suffix is appended ("99+", "999+").
///
/// ```dart
/// const OctoCounterLabel(128, maxDisplayed: 99)
/// ```
///
/// **Variants** — [OctoCounterLabelVariant]: `standard` (quiet, beside a nav
/// item) · `primary` · `secondary`.
///
/// **Sizes** — one size only; the pill takes its metrics from the theme's small
/// label typography so it aligns with the text it annotates.
///
/// **States** — none; the counter is descriptive.
///
/// **Accessibility** — exposes the rendered number as its accessible name.
/// [maxDisplayed] caps the digits at, say, `99+`, and the accessible name follows
/// the visible text, so a screen reader never announces a count the user cannot
/// see. Pass [semanticLabel] to say what is being counted — `128 open issues`
/// reads better than a bare `128`.
///
/// See also:
///
///  * [OctoLabel], for a word instead of a number.
class OctoCounterLabel extends StatelessWidget {
  /// Numeric value displayed inside the pill.
  final int count;

  /// Visual emphasis tier. See [OctoCounterLabelVariant].
  final OctoCounterLabelVariant variant;

  /// When set, counts above this value display as `"$maxDisplayed+"`.
  final int? maxDisplayed;

  /// Optional accessibility label. Defaults to the displayed text — set
  /// e.g. `'42 unread notifications'` to spell out what the count counts.
  final String? semanticLabel;

  /// Creates a counter pill.
  const OctoCounterLabel(
    this.count, {
    super.key,
    this.variant = OctoCounterLabelVariant.standard,
    this.maxDisplayed,
    this.semanticLabel,
  });

  String get _display {
    if (maxDisplayed != null && count > maxDisplayed!) {
      return '$maxDisplayed+';
    }
    return '$count';
  }

  ({Color background, Color foreground}) _resolveColors(OctoThemeData theme) {
    switch (variant) {
      case OctoCounterLabelVariant.standard:
        return (background: theme.colors.neutral.muted, foreground: theme.colors.fg.defaultColor);
      case OctoCounterLabelVariant.primary:
        return (background: theme.colors.accent.muted, foreground: theme.colors.accent.fg);
      case OctoCounterLabelVariant.secondary:
        return (
          background: const Color(0x00000000),
          foreground: theme.colors.fg.muted,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final colors = _resolveColors(theme);
    final text = _display;
    return MergeSemantics(
      child: Semantics(
        label: semanticLabel ?? text,
        excludeSemantics: semanticLabel != null,
        // Avoid `Container.alignment` — it wraps the child in an `Align`,
        // which expands to its parent's loose constraints and turns the
        // pill into a full-height bar when the surrounding Row gives
        // unbounded cross-axis space (e.g. inside OctoUnderlineNav).
        // `DecoratedBox + Padding` hugs the text on both axes.
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.all(Radius.circular(theme.radii.full)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            // Override labelSmall's inherited `height: 1.5` so the line
            // box hugs the glyphs and the pill stays proportional.
            child: OctoText.styled(
              text,
              style: theme.typography.labelSmall.copyWith(height: 1),
              color: colors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
