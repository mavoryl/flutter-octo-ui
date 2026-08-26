/// The mapping from `octo_ui` token fields to Primer Primitives token names.
///
/// This table is the reviewable core of the generator: it lives in Dart, not
/// JSON, so every non-obvious choice carries a comment explaining itself and
/// shows up in code review like any other decision.
library;

/// One sub-object of `OctoColorScheme` (`canvas`, `fg`, `accent`, …) together
/// with the Primer token that fills each of its fields.
class OctoColorGroup {
  /// Field name on `OctoColorScheme` — e.g. `canvas`.
  final String field;

  /// Dart class backing the group — e.g. `OctoCanvasColors`.
  final String className;

  /// Group field name → Primer token name. Insertion order is the emission
  /// order, so the generated constructor arguments stay stable.
  final Map<String, String> leaves;

  /// Describes one colour group.
  const OctoColorGroup({
    required this.field,
    required this.className,
    required this.leaves,
  });
}

/// One generated `OctoColorScheme` constant.
class OctoPaletteTarget {
  /// Name of the emitted top-level constant.
  final String constantName;

  /// Primer theme this palette reads — a key under `themes` in the snapshot.
  final String primerTheme;

  /// `Brightness` enum value for the palette.
  final String brightness;

  /// `OctoColorSchemeVariant` enum value for the palette.
  final String variant;

  /// Describes one generated palette.
  const OctoPaletteTarget({
    required this.constantName,
    required this.primerTheme,
    required this.brightness,
    required this.variant,
  });
}

/// Status families share one shape: `fg` is text, `emphasis` is a solid
/// background, `muted` is a border, `subtle` is a tinted background. Primer
/// spells the same four roles as `fgColor-X`, `bgColor-X-emphasis`,
/// `borderColor-X-muted` and `bgColor-X-muted`.
Map<String, String> _statusLeaves(String family) => <String, String>{
      'fg': 'fgColor-$family',
      'emphasis': 'bgColor-$family-emphasis',
      'muted': 'borderColor-$family-muted',
      'subtle': 'bgColor-$family-muted',
    };

/// Every colour group, in `OctoColorScheme` constructor order.
final List<OctoColorGroup> kPrimerColorGroups = <OctoColorGroup>[
  const OctoColorGroup(
    field: 'canvas',
    className: 'OctoCanvasColors',
    leaves: <String, String>{
      'defaultColor': 'bgColor-default',
      'overlay': 'overlay-bgColor',
      'inset': 'bgColor-inset',
      'subtle': 'bgColor-muted',
    },
  ),
  const OctoColorGroup(
    field: 'fg',
    className: 'OctoForegroundColors',
    leaves: <String, String>{
      'defaultColor': 'fgColor-default',
      'muted': 'fgColor-muted',
      // Primer removed `fgColor-subtle`. `fgColor-disabled` occupies the same
      // visual tier one step below `muted`, and it matches how octo_ui
      // actually spends this slot: OctoPagination uses `fg.subtle` for
      // disabled page links, OctoUnderlineNav for disabled tabs, and
      // OctoTextField for placeholder text.
      'subtle': 'fgColor-disabled',
      'onEmphasis': 'fgColor-onEmphasis',
    },
  ),
  const OctoColorGroup(
    field: 'border',
    className: 'OctoBorderColors',
    leaves: <String, String>{
      'defaultColor': 'borderColor-default',
      'muted': 'borderColor-muted',
      // `borderColor-translucent` is Primer's alpha-based hairline — the same
      // role our `subtle` plays (a divider that reads on any canvas).
      'subtle': 'borderColor-translucent',
    },
  ),
  const OctoColorGroup(
    field: 'neutral',
    className: 'OctoNeutralColors',
    leaves: <String, String>{
      'fg': 'fgColor-neutral',
      'emphasis': 'bgColor-neutral-emphasis',
      // Primer has no `emphasisPlus`. `bgColor-inverse` carries the same
      // semantics — dark in light themes, light in dark ones — which is
      // exactly how octo_ui uses this slot (tooltip surfaces via the
      // Material adapter).
      'emphasisPlus': 'bgColor-inverse',
      'muted': 'borderColor-neutral-muted',
      'subtle': 'bgColor-neutral-muted',
    },
  ),
  OctoColorGroup(
    field: 'accent',
    className: 'OctoAccentColors',
    leaves: _statusLeaves('accent'),
  ),
  OctoColorGroup(
    field: 'success',
    className: 'OctoSuccessColors',
    leaves: _statusLeaves('success'),
  ),
  OctoColorGroup(
    field: 'attention',
    className: 'OctoAttentionColors',
    leaves: _statusLeaves('attention'),
  ),
  OctoColorGroup(
    field: 'danger',
    className: 'OctoDangerColors',
    leaves: _statusLeaves('danger'),
  ),
];

/// The four palettes octo_ui ships. The colour-blind variants of ADR-0005 are
/// enum slots without values, so they are not generated.
const List<OctoPaletteTarget> kPrimerPalettes = <OctoPaletteTarget>[
  OctoPaletteTarget(
    constantName: 'kOctoLightStandard',
    primerTheme: 'light',
    brightness: 'light',
    variant: 'standard',
  ),
  OctoPaletteTarget(
    constantName: 'kOctoLightHighContrast',
    primerTheme: 'light-high-contrast',
    brightness: 'light',
    variant: 'highContrast',
  ),
  OctoPaletteTarget(
    constantName: 'kOctoDarkStandard',
    primerTheme: 'dark',
    brightness: 'dark',
    variant: 'standard',
  ),
  OctoPaletteTarget(
    constantName: 'kOctoDarkHighContrast',
    primerTheme: 'dark-high-contrast',
    brightness: 'dark',
    variant: 'highContrast',
  ),
];

/// `OctoBreakpoints` field → Primer breakpoint token. These already agree with
/// the hand-written values 1:1, so generating them is a provenance change
/// rather than a value change.
const Map<String, String> kPrimerBreakpointTokens = <String, String>{
  'xs': 'breakpoint-xsmall',
  'sm': 'breakpoint-small',
  'md': 'breakpoint-medium',
  'lg': 'breakpoint-large',
  'xl': 'breakpoint-xlarge',
  'xxl': 'breakpoint-xxlarge',
};

/// Every Primer colour token the generator reads, deduplicated. Used by
/// `fetch` to trim the upstream snapshot down to what we actually consume.
Set<String> get kPrimerColorTokens => kPrimerColorGroups.expand((g) => g.leaves.values).toSet();
