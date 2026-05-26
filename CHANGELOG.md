# Changelog

All notable changes to this project will be documented in this file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- **`OctoDialog`** + `OctoDialog.show<T>()` — themed modal dialog. Wraps
  Material's `Dialog` with Primer chrome (`canvas.overlay`,
  `border.defaultColor`, `radii.large`, `shadows.large`); `title` /
  `content` / `actions` slots. `Escape` and outside-tap on the scrim
  both dismiss. Action buttons wire their own `Navigator.pop(ctx,
  value)` to surface a `Future<T?>` from `show`. `OctoDialogTitle` is
  sugar for the common heading text case.
- **`OctoSkeleton`** + `OctoSkeletonText` + `OctoSkeletonAvatar` —
  loading placeholders that pulse between `neutral.muted` and
  `neutral.subtle`. Wrapped in `ExcludeSemantics` so the placeholder is
  invisible to screen readers. Honours `MediaQuery.disableAnimationsOf`
  (ADR-0008) by suspending the controller — for golden tests, pass
  `freezeAnimations: true` to `matrixGolden`.
- **`OctoAvatar`** — user avatar with image-then-initials fallback.
  `imageUrl` (default `NetworkImage`) OR `imageProvider` (asset / memory
  / custom); `initials` for the fallback. 5 sizes (`xs`/`sm`/`md`/`lg`/
  `xl` = 16/20/32/48/64 dp) and 2 shapes (`circle` / `square`). Required
  `semanticLabel` + `Semantics(image: true)`.
- **`OctoBreadcrumbs`** + `OctoBreadcrumbItem` — horizontal navigation
  trail. Clickable segments render as `invisible`-variant
  `OctoButton`s; the final segment (`onPressed: null`) becomes plain
  text — the "current page" convention. Octicons `chevron_right_16`
  separates pairs.
- **`OctoSwitch`** — pill-shaped on/off toggle. Controlled
  (`value` + `onChanged`); `onChanged: null` disables. Animated thumb
  (`theme.animation.fast` + `standardCurve`). `Space` activates the
  focused switch via `ActivateIntent`. `Semantics(toggled, enabled,
  label)`.
- **`OctoCheckbox`** — 16×16 box with the Octicons `check_16` / `dash_16`
  glyph. Supports `tristate: true` for indeterminate (cycle
  `false → true → null → false`); a non-tristate checkbox with a `null`
  value triggers an assertion. `Semantics(checked, mixed, enabled,
  label)`.
- **`OctoRadio<T>`** — generic radio with `value` / `groupValue` /
  `onChanged`. Tapping the already-selected radio is a no-op; tapping a
  sibling sends its value. `Semantics(inMutuallyExclusiveGroup, checked,
  enabled, label)`.
- Shared golden suite `octo_form_controls` covers Switch / Checkbox /
  Radio across off / on / disabled / indeterminate states. Tests 13
  widget cases (4 + 5 + 4) across the three components.
- Kitchen-sink demo grows a "Form controls" section: a notifications
  switch, a tri-state terms checkbox, and a 3-radio priority group.

- **Octicons integration** — `flutter_octicons ^1.71.0` is now a direct
  dependency, and `package:octo_ui/octo_ui.dart` re-exports the
  `OctIcons` class so apps can write `Icon(OctIcons.code_16)` without an
  extra import. Sample / golden / demo code throughout the package is
  re-imaged with Octicons; no Material `Icons.*` glyphs remain in the
  visual layer.
- `OctoFlash` finally ships its dismiss button. Pass `onDismiss` to
  render a trailing close affordance (Octicons `x_16`); the optional
  `dismissSemanticLabel` (default `'Dismiss'`) overrides the screen
  reader announcement. The "deferred until octo_icons" stop-gap is
  retired.
- `NOTICE` file at the repository root carries the MIT attribution for
  Octicons (© GitHub, Inc.) and the BSD-3-Clause attribution for the
  `flutter_octicons` Flutter wrapper, plus the standard "not affiliated
  with GitHub" disclaimer.

- `OctoUnderlineNav` + `OctoUnderlineNavItem` — horizontal section-tab
  strip with an underline indicator under the selected tab (Primer
  "UnderlineNav"). Items take optional `icon` and `trailing` widgets
  (counter labels fit there naturally). Controlled API: pass
  `selectedIndex` + `onChanged`. Selected label uses
  `OctoTextKind.bodyEmphasis`; each tab is independently focusable and
  carries `Semantics(button: true, selected: ...)`. The component itself
  does not handle horizontal overflow — wrap in a `SingleChildScrollView`
  when the tab strip is wider than the available room.

## [0.2.0-dev.0] — 2026-05-26

### Added

- `OctoFocusRing.overlay` — clip-proof named constructor that renders the
  ring through `OverlayPortal` in the root `Overlay`. Survives ancestor
  clips (`ClipRect`, `ListView` items, dialog containers); same visibility
  rules as the inline variant (focus + `FocusHighlightMode.traditional`).
  Requires an enclosing `Overlay` (provided by `MaterialApp` /
  `WidgetsApp`). See ADR-0006.
- `OctoCounterLabel` — compact numeric counter pill (Primer
  "CounterLabel"). 3 variants (standard / primary / secondary); optional
  `maxDisplayed` clamps oversized counts with a `+` suffix
  (`OctoCounterLabel(150, maxDisplayed: 99)` → "99+"). Optional
  `semanticLabel` to spell out what the count counts.
- `OctoCommandPalette` + `OctoCommandPaletteController` — modal command
  palette rendered through `OverlayPortal` on top of the host app. The
  modal contains an autofocused search field that filters items by
  case-insensitive substring match on `label + description`; `Enter`
  activates the first enabled match, `Escape` and outside-scrim taps
  dismiss. Optional `openShortcut: ShortcutActivator?` (e.g.
  `SingleActivator(LogicalKeyboardKey.keyK, meta: true)` for `Cmd+K`)
  installs a global key handler that opens the palette. The modal body
  wraps in a transparent `Material` so the embedded `OctoTextField`
  (which delegates to Material's `TextField`) finds an ancestor outside
  the host route.
- **Arrow-key navigation in `OctoActionList`** — each row is a focusable
  node; the list wraps in `Shortcuts({Up: PreviousFocusIntent, Down:
  NextFocusIntent})` + `Actions(NextFocusAction, PreviousFocusAction)` +
  `FocusTraversalGroup(ReadingOrderTraversalPolicy)`, so arrow keys
  traverse rows without requiring a `WidgetsApp`. `Enter` / `Space` /
  `NumpadEnter` activate the focused row. New `autofocus: bool` parameter
  requests focus on the first row at mount — `OctoMenu` now passes
  `autofocus: true` so menus are keyboard-ready on open.
- **`OctoStateLayer.focused`** now paints the `neutral.subtle` overlay,
  matching `hovered` — focused rows / buttons are visible during keyboard
  traversal without a pointer hover.
- `OctoMenu` + `OctoMenuController` — popover-style menu anchored to a
  trigger widget. Composes `OctoActionList` inside an `OverlayPortal`
  tracked to the trigger via `LayerLink` + `CompositedTransformFollower`.
  Dismisses on outside tap (`TapRegion`), `Escape` key
  (`Shortcuts`/`Actions` → `DismissIntent`), and (by default) on item
  selection. `closeOnSelect: false` keeps the menu open for multi-select
  filter patterns. Width snaps to the trigger's measured width via
  `IntrinsicWidth` + minimum-width constraint; override with `minWidth`.
- `OctoTooltip` — thin wrapper over Material's `Tooltip`. Visuals (padding,
  radius, colours, typography) come from the `TooltipThemeData` installed
  by `toMaterialTheme()`; behaviour (hover-after-delay, long-press, smart
  edge-flip, a11y announcement) is delegated.
- `OctoActionList` + `OctoActionListItem` — vertical list of action rows,
  used standalone or as the body of an overlay menu / palette. Each row
  has its own hover / pressed / selected / disabled state machine on
  Flutter's built-in `WidgetState`. `danger` variant tints label and icon
  via `danger.fg`. Default constructor takes an eager
  `List<OctoActionListItem>`; `OctoActionList.builder` is the lazy variant
  for long lists (filter dropdowns, command palette). Keyboard
  arrow-traversal deferred to a later milestone.
- **Dynamic-state golden coverage** — `hovered`, `pressed`, `focused`
  scenarios for `OctoButton` and `OctoIconButton`. A new
  `@visibleForTesting` `debugStates: Set<WidgetState>?` parameter on both
  components lets goldens inject hover / pressed without driving real
  pointer events; `focused` uses `autofocus: true` plus a
  `GoldenFocusScope` helper that pins `FocusManager.highlightStrategy` to
  `alwaysTraditional` for the duration of the scenario. Total goldens grow
  from 28 to 40.
- **High-contrast palette** — `OctoColorScheme.light(variant: highContrast)`
  and `.dark(variant: highContrast)` now return concrete values (Primer-
  aligned). The shape was reserved in 0.1.0-dev.0; only colour-blind
  variants (`protanopia` / `deuteranopia` / `tritanopia`) still throw
  `UnimplementedError`. In hi-contrast dark, `fg.onEmphasis` flips to a
  near-black because emphasis backgrounds are bright. All four palettes
  (light, dark, light-hc, dark-hc) pass the WCAG-AA contrast assertions.
  See ADR-0005.

### Documentation

- All public members under `lib/src/` now carry `///` doc comments; lint
  `public_member_api_docs` is enabled at warning level and reports zero
  issues.

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

[Unreleased]: https://github.com/Autocrab/flutter-octo-ui/compare/v0.2.0-dev.0...HEAD
[0.2.0-dev.0]: https://github.com/Autocrab/flutter-octo-ui/compare/v0.1.0-dev.0...v0.2.0-dev.0
[0.1.0-dev.0]: https://github.com/Autocrab/flutter-octo-ui/releases/tag/v0.1.0-dev.0
