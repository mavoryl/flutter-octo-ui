# octo_ui

A Flutter UI kit inspired by [GitHub Primer](https://primer.style/), tuned for **web, desktop, devtools, dashboards, and admin panels** — not mobile-first Material.

> **Not affiliated with, endorsed by, or sponsored by GitHub.** The name `octo_ui` is deliberate; this is an independent project that takes design inspiration from Primer but does not redistribute its source.

## Status

**`0.1.0-dev`** — foundation release. API may change before `0.1.0` stable. Pre-release; not yet on pub.dev.

## What's in 0.1.0-dev

- **Design tokens** — colours (light + dark, Primer-like), spacing (indexed scale + semantic aliases), radius, typography, shadows, breakpoints, animation. Every token group is value-typed (`==` / `hashCode`) with `copyWith` and `lerp`.
- **Theme propagation** — `OctoTheme` is an `InheritedTheme` (propagates through `Dialog` / `PopupMenu` / `Tooltip` via `InheritedTheme.captureAll`) and is also registered as a `ThemeExtension<OctoThemeData>`.
- **Material adapter** — `octoTheme.toMaterialTheme()` returns Material 3 `ThemeData` with correct semantic mapping, `NoSplash` factory, and theming for `Dialog` / `SnackBar` / `PopupMenu` / `Tooltip`.
- **Foundation widgets** — `OctoBox`, `OctoText`, `OctoIcon`, `OctoFocusRing` (keyboard-only, watches `FocusManager.highlightMode`), `OctoStateLayer` (built on Flutter's `WidgetState`).
- **Components** — `OctoLabel`, `OctoButton`, `OctoIconButton`, `OctoFlash`, `OctoTextField`. Full state machine via `FocusableActionDetector` + `WidgetStatesController`; keyboard activation (Enter / Space / NumpadEnter); `Semantics` flags everywhere; required `semanticLabel` on icon-only buttons.
- **Tests** — 114 widget/unit + 28 golden baselines (via [`golden_matrix`](https://pub.dev/packages/golden_matrix)).
- **Demo** — `example/` runs on macOS and web.

## What's NOT in 0.1.0-dev (planned for 0.2 / 0.3)

- `OctoFocusRing.overlay` (clip-proof variant via `OverlayPortal`)
- High-contrast and colour-blind palette variants (shape reserved)
- `OctoCounterLabel`, `OctoActionList`, `OctoUnderlineNav`, overlay family
- `OctoFlash` dismiss button (blocked on a non-Material close glyph)
- Token generator from Primer Primitives JSON
- Widgetbook playground

## Installation

```yaml
# pubspec.yaml — pub.dev publish pending; use git for now
dependencies:
  octo_ui:
    git:
      url: https://github.com/Autocrab/flutter-octo-ui
```

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
        // Material adapter so Dialog / SnackBar / PopupMenu inherit Octo colours.
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
        const OctoLabel('Feature', variant: OctoLabelVariant.accent),
        const SizedBox(height: 16),
        OctoButton.label('Save', onPressed: () {}, variant: OctoButtonVariant.primary),
      ],
    );
  }
}
```

A complete kitchen sink lives in `example/lib/main.dart`:

```bash
cd example
flutter run -d macos   # or: flutter run -d chrome
```

## Architecture

```
lib/
  octo_ui.dart                   # public barrel — only export surface
  src/
    tokens/                      # OctoColorScheme, OctoSpacing, OctoRadius,
                                 # OctoTypography, OctoShadows, OctoBreakpoints, OctoAnimation
    theme/                       # OctoThemeData, OctoTheme (InheritedTheme + ThemeExtension),
                                 # toMaterialTheme()
    foundation/                  # OctoBox, OctoText, OctoIcon, OctoFocusRing, OctoStateLayer
    components/                  # button, icon_button, label, flash, text_field
```

Public API is reachable only through `package:octo_ui/octo_ui.dart`. Internal paths under `lib/src/` may move without breaking changes.

### Design principles

1. **Tokens first.** Widgets read semantic tokens (`theme.colors.fg.defaultColor`, `theme.colors.accent.emphasis`) — no hardcoded colours or sizes.
2. **All interactive states are mandatory.** Default, hover, focus, pressed, selected, disabled, loading.
3. **`WidgetState` from Flutter, not a parallel enum.** Components compose `FocusableActionDetector` + `WidgetStatesController` so Octo widgets cooperate with the rest of the Flutter ecosystem.
4. **No Material in widget visuals.** Material is touched only at the integration boundary (`toMaterialTheme()`, `TextField` editing internals).
5. **A11y is shipped, not added later.** `Semantics` flags, `liveRegion` on Flash, `MergeSemantics` on Label, required `semanticLabel` on `OctoIconButton`. WCAG-AA contrast is verified by automated tests.

## Testing

```bash
flutter analyze
flutter test                                   # widget + unit
flutter test test/goldens/                     # golden regression
flutter test test/goldens/ --update-goldens    # regenerate baselines
```

Goldens are reproducible on **a single fixed OS** — currently macOS, matching the development environment. Cross-OS runs will produce sub-pixel diffs; run goldens only on macOS in CI.

## License

[MIT](LICENSE). Octicons (planned for use in future versions) are © GitHub, Inc., distributed under MIT — attribution will land in `NOTICE` when the icon wrapper ships.
