# Changelog

All notable changes to this project will be documented in this file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0-dev.0] — 2026-05-26

Foundation release. API is unstable until `0.1.0`.

### Added

- **Design tokens** under `lib/src/tokens/`:
  - `OctoColorScheme` with `canvas` / `fg` / `border` / `neutral` / `accent` / `success` / `attention` / `danger` subschemes. `light()` and `dark()` factories with `OctoColorSchemeVariant` enum (standard implemented; `highContrast` and colour-blind variants reserved as enum slots).
  - `OctoSpacing` — indexed scale + semantic `gap` / `inset` aliases (`xs` / `sm` / `md` / `lg` / `xl`).
  - `OctoRadius`, `OctoTypography`, `OctoShadows`, `OctoBreakpoints`, `OctoAnimation`.
  - Every token class is `@immutable` with `copyWith` / `lerp` / `==` / `hashCode`.
- **Theme propagation** under `lib/src/theme/`:
  - `OctoThemeData` aggregates all token groups and implements `ThemeExtension<OctoThemeData>`.
  - `OctoTheme` extends `InheritedTheme` (theme flows into `Dialog` / `PopupMenu` / `Tooltip` via `InheritedTheme.captureAll`).
  - `OctoTheme.of` / `OctoTheme.maybeOf` / `debugCheckHasOctoTheme(context)`.
  - `OctoMaterialAdapter.toMaterialTheme()` returns Material 3 `ThemeData` with full `ColorScheme` mapping, `NoSplash` factory, and themed `Dialog` / `SnackBar` / `PopupMenu` / `Tooltip` subthemes. `OctoThemeData` is also registered in `ThemeData.extensions`.
- **Foundation widgets** under `lib/src/foundation/`:
  - `OctoBox`, `OctoText` (semantic kind picker), `OctoIcon` (size 12 / 16 / 24).
  - `OctoFocusRing` — keyboard-only outline via `CustomPaint`; watches `FocusManager.instance.highlightMode`.
  - `OctoStateLayer` — translucent overlay driven by Flutter's built-in `WidgetState` set.
- **Components** under `lib/src/components/`:
  - `OctoLabel` — pill tag, 5 variants.
  - `OctoButton` — 4 variants × 3 sizes, loading, leading / trailing icons, keyboard activation via `ActivateIntent` (Enter / Space / NumpadEnter).
  - `OctoIconButton` — composition over `OctoButton`; required `semanticLabel`.
  - `OctoFlash` — 4 variants; `liveRegion: true` semantics. **No dismiss button** — see omissions below.
  - `OctoTextField` — outlined input over Material `TextField`; full prop set (`controller`, `focusNode`, `inputFormatters`, `obscureText`, `autofillHints`, `keyboardType`, `textInputAction`, `min` / `maxLines`, `maxLength`, helper / error text, etc.).
- **Tests** — 114 widget / unit + 28 golden baselines via [`golden_matrix`](https://pub.dev/packages/golden_matrix). WCAG-AA contrast is checked on every standard palette.
- **Demo** — `example/` runs on macOS and web (`flutter run -d macos|chrome`).

### Architectural decisions

- Monolithic single-package layout under `lib/src/{tokens,theme,foundation,components,utils}/`. Multi-package / Melos split deferred until a concrete trigger.
- Uses Flutter's built-in `WidgetState` / `WidgetStatesController`. **No parallel `OctoWidgetState` enum.**
- Material is only touched at the integration boundary: `toMaterialTheme()` and the editing internals of `OctoTextField`. Component visuals contain no Material widgets (no `Icons.*`, no `InkWell`, no ripple).
- `dart format` runs at `page_width: 100`. Field order inside classes: `static` → `final` → constructor → methods → `copyWith` / `lerp` → `==` / `hashCode`. Lints `sort_constructors_first` and `sort_unnamed_constructors_first` are explicitly disabled.

### Known omissions (planned for 0.2 / 0.3)

- `OctoFocusRing.overlay` (clip-proof variant via `OverlayPortal`).
- High-contrast and colour-blind palette values (`OctoColorSchemeVariant` shape is in place but only `standard` is implemented; other variants throw `UnimplementedError`).
- `OctoCounterLabel`, `OctoActionList`, `OctoUnderlineNav`, overlay family.
- `OctoFlash` dismiss button — blocked until a non-Material close glyph ships with the icon wrapper.
- Token generator from Primer Primitives JSON.
- Widgetbook playground.
- Goldens for dynamic states (`hovered`, `pressed`, `focused`, `loading`).

[Unreleased]: https://github.com/Autocrab/flutter-octo-ui/compare/v0.1.0-dev.0...HEAD
[0.1.0-dev.0]: https://github.com/Autocrab/flutter-octo-ui/releases/tag/v0.1.0-dev.0
