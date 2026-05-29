# octo_ui

[![pub package](https://img.shields.io/pub/v/octo_ui.svg)](https://pub.dev/packages/octo_ui)
[![CI](https://github.com/Autocrab/flutter-octo-ui/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Autocrab/flutter-octo-ui/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/Autocrab/flutter-octo-ui/branch/main/graph/badge.svg)](https://codecov.io/gh/Autocrab/flutter-octo-ui)

🎮 **Live demo:** <https://autocrab.github.io/flutter-octo-ui/> — the kitchen sink running in your browser. Updated on every push to `main`.

A cross-platform Flutter UI kit inspired by [Primer](https://primer.style/). Optimised for **devtools, dashboards, admin panels, and dense data-heavy interfaces** — but every widget shares the same theme tokens, focus model, and accessibility baseline regardless of platform, so it runs cleanly on mobile too.

## Why another UI kit

Material is mobile-first and design-opinionated; Cupertino is iOS-locked; most boutique kits hard-code colours and skip keyboard navigation. `octo_ui` fills the gap in between:

- **Tokens first**, not components first — colours, spacing, radii, typography, shadows, breakpoints, and animation curves live in `OctoThemeData`. Widgets read semantic tokens (`theme.colors.fg.defaultColor`, `theme.colors.accent.emphasis`) — never hardcoded values.
- **Every interactive state is mandatory** — default, hover, focus, pressed, selected, disabled, loading. Web/desktop UIs without hover/focus look like stretched mobile apps; `octo_ui` widgets all wire `FocusableActionDetector` + `WidgetStatesController` so they cooperate with the rest of the Flutter ecosystem.
- **A11y is shipped, not added later** — `Semantics` flags on every interactive surface, `liveRegion` on flash / toast, required `semanticLabel` on icon-only buttons. WCAG-AA contrast is verified by automated tests across light / dark / high-contrast palettes.
- **Material adapter included** — `octoTheme.toMaterialTheme()` returns Material 3 `ThemeData` so dialogs, snackbars, popup menus, tooltips, and editing internals inherit Octo colours without you wiring them up.

## Status

Pre-1.0 — APIs may evolve between `0.x` releases. The current published version is **`0.8.5`**.

## Component catalogue

25 components across 6 categories. Each one has a [golden snapshot](test/goldens) and unit / widget tests.

**Form & input**
&nbsp;&nbsp;`OctoButton` · `OctoIconButton` · `OctoTextField` · `OctoSwitch` · `OctoCheckbox` · `OctoRadio` · `OctoSegmentedControl` · `OctoDropdown`

**Display & labels**
&nbsp;&nbsp;`OctoLabel` · `OctoCounterLabel` · `OctoStateLabel` · `OctoChip` · `OctoAvatar` · `OctoFlash` · `OctoSkeleton`

**Navigation**
&nbsp;&nbsp;`OctoUnderlineNav` · `OctoSideNav` · `OctoTabs` · `OctoBreadcrumbs` · `OctoPagination`

**Overlays**
&nbsp;&nbsp;`OctoDialog` · `OctoTooltip` · `OctoMenu` · `OctoToast` · `OctoCommandPalette` (⌘K-style picker) · `OctoActionList`

**Data & feedback**
&nbsp;&nbsp;`OctoDataTable<T>` · `OctoTimeline` · `OctoProgressBar` · `OctoSpinner`

**Layout primitives**
&nbsp;&nbsp;`OctoCollapsible` · `OctoDivider`

## Installation

```yaml
dependencies:
  octo_ui: ^0.8.5
```

Or `flutter pub add octo_ui`.

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:octo_ui/octo_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final octo = OctoThemeData.light();
    return OctoTheme(
      data: octo,
      child: MaterialApp(
        theme: octo.toMaterialTheme(),
        home: const Scaffold(body: Center(child: _Example())),
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const OctoStateLabel(
          label: 'Open',
          variant: OctoStateLabelVariant.open,
        ),
        const SizedBox(height: 16),
        OctoButton.label(
          'Save changes',
          onPressed: () {},
          variant: OctoButtonVariant.primary,
        ),
      ],
    );
  }
}
```

A full kitchen sink — every component with controlled state, hover / focus / pressed showcases, dark-mode + high-contrast toggles, and a ⌘K command palette — lives in [`example/`](example/lib/main.dart):

```bash
cd example
flutter run -d macos   # or -d chrome, -d linux, -d windows, -d ios, -d android
```

## Theming

`OctoTheme` is both an `InheritedTheme` (propagates through `Dialog` / `PopupMenu` / `Tooltip` via `InheritedTheme.captureAll`) and a `ThemeExtension<OctoThemeData>` (so `Theme.of(context).extension<OctoThemeData>()` works in Material descendants).

```dart
final theme = OctoTheme.of(context);
final paragraphColor = theme.colors.fg.defaultColor;
final cardPadding   = theme.spacing.gap.md;
final radius        = BorderRadius.all(Radius.circular(theme.radii.medium));
```

Three built-in variants: `OctoThemeData.light()`, `.dark()`, and `OctoColorSchemeVariant.highContrast` for either brightness — WCAG-AA verified by tests.

## Architecture

```
lib/
  octo_ui.dart                       # public barrel — only export surface
  src/
    tokens/                          # OctoColorScheme, OctoSpacing, OctoRadius,
                                     # OctoTypography, OctoShadows, OctoBreakpoints,
                                     # OctoAnimation
    theme/                           # OctoThemeData, OctoTheme, toMaterialTheme()
    foundation/                      # OctoBox, OctoText, OctoIcon,
                                     # OctoFocusRing, OctoStateLayer
    components/<name>/               # one folder per component, internals private
```

The public API is reachable only through `package:octo_ui/octo_ui.dart`. Internal paths under `lib/src/` are private and may move without a breaking-change bump.

The package re-exports `OctIcons` from [`flutter_octicons`](https://pub.dev/packages/flutter_octicons) so callers can paint Octicons without an extra dependency.

## Accessibility

- Every interactive widget exposes `Semantics(button|toggled|selected|enabled|expanded, label)` matching its current state.
- Keyboard activation (Enter / Space / NumpadEnter) is wired via `FocusableActionDetector`; arrow-key navigation is supported on `OctoActionList`, `OctoCommandPalette`, and `OctoMenu`.
- The focus ring (`OctoFocusRing`) only paints in keyboard mode — `FocusManager.highlightMode` watches for real keyboard events.
- Live regions on `OctoFlash` and `OctoToast` announce status changes to screen readers.
- Motion is respected: components with infinite animations (`OctoSpinner`, `OctoSkeleton`, `OctoProgressBar` indeterminate) honour `MediaQuery.disableAnimationsOf` and fall back to a static frame.
- Colour-pair contrast (foreground on canvas, foreground-on-emphasis on every status colour) is enforced by automated WCAG-AA tests across `light`, `dark`, `light-hc`, and `dark-hc` palettes.

## Testing

```bash
flutter analyze
flutter test                                   # widget + unit
flutter test test/goldens/                     # golden regression
flutter test test/goldens/ --update-goldens    # regenerate baselines
```

Goldens are built with [`golden_matrix`](https://pub.dev/packages/golden_matrix). Small components use `componentMatrixGolden` (widget-sized PNGs); scaffold-positioned components use `matrixGolden`. Baselines are deterministic on **a single fixed OS** — currently macOS, matching the development environment. Cross-OS runs produce sub-pixel diffs; run goldens only on macOS in CI.

CI runs `dart format` + `flutter analyze` + `flutter test` on every push; the JUnit report from `golden_matrix` is published inline on the PR.

## License

[MIT](LICENSE). See [`NOTICE`](NOTICE) for third-party attributions — Octicons are © GitHub, Inc. (MIT) and ship through [`flutter_octicons`](https://pub.dev/packages/flutter_octicons) (BSD-3-Clause).
