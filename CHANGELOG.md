# Changelog

All notable changes to this project will be documented in this file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.8.3] — 2026-05-26

### Added

- Live demo on GitHub Pages — the kitchen-sink runs in-browser at
  <https://autocrab.github.io/flutter-octo-ui/>, redeployed on every
  push to `main`. Built with `flutter build web --release --wasm` so
  the Skwasm renderer is used on modern Chromium / Firefox with
  automatic CanvasKit fallback for older browsers.
- README now opens with a link to the live demo right under the
  badges.

## [0.8.2] — 2026-05-26

### Added

- Five pub.dev topics for discovery: `design-system`, `ui`, `widgets`,
  `theme`, `dashboard`.
- Codecov badge in the README; `flutter test --coverage` now uploads
  `coverage/lcov.info` to codecov from CI.

### Changed

- CI gates `lib/` line coverage at **>= 90%** — a regression that
  drops below the threshold fails the workflow. Current coverage
  sits at 92.4%, leaving headroom for the next round of features.

## [0.8.1] — 2026-05-26

### Changed

- Minor fixes — README now ships pub.dev + CI badges and the install
  snippet drops the git-ref fallback now that the package is live.

## [0.8.0] — 2026-05-26

First stable release on pub.dev. Promotes the `0.7.0-dev.0` component
surface (25 components across form / display / navigation / overlay /
data / layout categories) without API changes.

### Changed

- Repository / issue-tracker URLs in `pubspec.yaml` point at the
  canonical `github.com/Autocrab/flutter-octo-ui` location.
- Package description, library doc comment, and README reframe the
  positioning as *cross-platform, optimised for devtools / dashboards
  / dense data*. No platform restrictions in `pubspec.yaml` — the kit
  runs anywhere Flutter does; mobile just isn't the design target.
- `README.md` rewritten to cover the current component catalogue,
  theming model, accessibility baseline, and the golden-test split
  between `matrixGolden` and `componentMatrixGolden`.
- `NOTICE` keeps the upstream MIT / BSD-3 attributions for Octicons +
  `flutter_octicons` and drops the standalone disclaimer paragraph.
- New `.pubignore` shaves the published archive from ~15 MB to ~88 KB
  by excluding test goldens, example platform scaffolding, CI
  plumbing, and dev tooling configs. Mirrors `.gitignore` patterns so
  the two files stay in sync.

## [0.7.0-dev.0] — 2026-05-23

### Changed

- Upgraded `golden_matrix` 0.18.1 → 0.19.0 to pick up the new
  `componentMatrixGolden` API. Migrated 11 small-component golden
  tests (button, icon_button, label, counter_label, spinner,
  state_label, divider, progress_bar, flash, collapsible, pagination)
  off `matrixGolden` so the captured PNGs are widget-sized instead of
  swimming inside a phone viewport — file names drop the device
  segment (`<theme>_<locale>_<dir>_<scale>.png`). Bigger / overlay /
  scaffold-positioned components stay on `matrixGolden` where the
  viewport context still matters.
- New `octoComponentWrap(child)` helper in `test/goldens/_octo_matrix
  .dart` — `componentMatrixGolden` does not expose a `wrapApp` hook,
  so the helper pulls `OctoThemeData` out of the inherited Material
  theme (it sits there as a `ThemeExtension` via
  `OctoThemeData.toMaterialTheme`) and installs `OctoTheme` above the
  scenario subtree.

### Added

- **`OctoDataTable<T>`** + `OctoDataColumn<T>` + `OctoDataColumnAlignment`
  + `OctoSortDirection` + `OctoDataTableDensity` — tabular presenter
  generic over the row type, built on Flutter's `Table` widget so
  columns size by `IntrinsicColumnWidth` by default — each column hugs
  the widest of its header and cells, no hand-tuned widths required.
  Override with `OctoDataColumn.width` (fixed pixels) or
  `OctoDataColumn.flex` (the column that should soak up leftover
  horizontal space — typically the title / subject column). Columns
  expose either a `text: T → String` accessor or a
  `cell: (BuildContext, T) → Widget` builder (cell wins when both are
  present); columns can opt into `sortable` to render a tappable
  header that cycles asc → desc → none and reports via `onSortChanged`.
  The table is presentation only — the parent owns the sorted list.
  Optional `onRowTap`, `zebra` striping, `density` (comfortable /
  compact), an `emptyMessage` empty state, and an optional `header`
  widget override per column (e.g. an icon for tight numeric columns).
  The rounded border + per-row dividers come from `border.muted`; the
  header sits on `canvas.subtle`.
- Golden coverage: `octo_data_table/{default,sorted_desc,compact,empty}`
  (light + dark) — the scenario file uses `MatrixDevice.tabletLandscape`
  so the wide cells render at their native size instead of being crushed
  into the phoneSmall viewport.
- Demo: a new "Data table" section in the kitchen sink wired to a
  controlled sort state.

## [0.6.0-dev.0] — 2026-05-19

### Added

- **`OctoTimeline`** + `OctoTimelineItem` + `OctoTimelineVariant` —
  vertical activity feed (Primer "Timeline"). Each entry pairs a 24 px
  variant-tinted marker disc with a title / subtitle / optional `body`
  widget; a 2 px `border.muted` rail runs through the entries to give
  the feed a continuous chronological spine (the rail uses
  `Clip.none` on its Stack so it extends through the per-row bottom
  padding into the next entry). Five marker variants — standard /
  accent / success / attention / danger.
- **`OctoSideNav`** + `OctoSideNavItem` — vertical sidebar navigation
  (Primer "SideNav"). Renders a stretched column of tappable rows
  bounded on the right by a `border.muted` divider. The selected row
  paints a 2 px accent bar flush against its leading edge over a
  `neutral.subtle` background; its label switches to
  `OctoTextKind.bodyEmphasis`. Tapping the already-selected row is a
  no-op; `selectedIndex: -1` highlights nothing. Per-row a11y carries
  `Semantics(button, selected, enabled, label)`; the focus ring and
  state layer behave the same as elsewhere.
- **`OctoTabs`** — content-switching tab group built on top of
  `OctoUnderlineNav`. Pairs a list of `OctoUnderlineNavItem` tabs with
  an equal-length list of body widgets and swaps the visible body via
  `AnimatedSwitcher` (180 ms cross-fade by default) when the user picks
  a different tab. *Uncontrolled* via `initialIndex` or *controlled*
  via `selectedIndex` + `onTabChanged`. Motion-reduce
  (`MediaQuery.disableAnimationsOf`) drops the switch duration to zero
  so transitions snap. Tapping the already-active tab is a no-op.
- **`OctoPagination`** — paged navigator (Primer "Pagination"). 1-based
  `currentPage` + `pageCount`, fires `onPageChanged(int)` when the user
  picks a different page (the already-selected tile silently ignores
  taps). Prev / Next chevrons step by one and disable at the range
  edges. Numbered slots are bounded by `maxVisible` (default 7) and
  collapse with `…` ellipsis tokens when the gap exceeds one — the
  slot-computation helper is exposed as `OctoPagination.computeSlots`
  for callers that need to predict the rendered sequence.
  `Semantics(button, selected, enabled, label: 'Page N')` per tile;
  Prev / Next carry their own a11y labels.
- **`OctoStateLabel`** + `OctoStateLabelVariant` +
  `OctoStateLabelEmphasis` — Primer-style PR / issue lifecycle pill.
  Five variants (`open`, `closed`, `merged`, `draft`, `attention`) with
  variant-implied default icons (`git_pull_request_16` /
  `issue_closed_16` / `git_merge_16` / `git_pull_request_draft_16` /
  `git_pull_request_16`); pass `icon` to override. Two emphasis tiers:
  *high* = filled `.emphasis` background (header look) / *low* = subtle
  `.subtle` background (dense list look). `merged` reuses the accent
  palette until a `done` (purple) family lands. `ExcludeSemantics`
  inside silences the inner icon + text, so screen readers read the
  `Semantics(label:)` once — pass `semanticLabel` to override the
  visible text.
- **`OctoSpinner`** + `OctoSpinnerSize` — circular indeterminate loading
  indicator. A 270° arc rotates continuously over a configurable
  `duration` (default 900 ms). Three size presets (16 / 24 / 40 px);
  default colour is `theme.colors.fg.muted`. Under motion-reduce
  (`MediaQuery.disableAnimationsOf`) the controller stops at a parked
  quarter-turn so the static shape still reads as a spinner.
  `Semantics(label, liveRegion)` announces the loading state.
- Golden coverage: `octo_misc/spinners` (small / medium / large, light +
  dark) — scenario wraps the row in `MediaQuery(disableAnimations:
  true)` so the snapshot stays deterministic under `freezeAnimations`.
- Demo: a new "Spinners" section in the kitchen-sink showing all three
  sizes paired with body-small status text.

## [0.5.0-dev.0] — 2026-05-14

### Added

- **`OctoToast`** + `OctoToastVariant` + `OctoToastAction` +
  `OctoToastController` — transient floating status pill (Primer
  "Toast"). Static `OctoToast.show(context, ...)` mounts an
  `OverlayEntry` at the bottom-center, slides + fades in, schedules
  auto-dismiss after `duration` (defaults to 4s; pass `Duration.zero`
  to make it sticky), and returns a controller whose `.dismiss()`
  removes the toast early. Four variants drive the leading-icon tint;
  optional action button + dismiss button. `Semantics(liveRegion)`
  announces the message to screen readers. `OctoToast.show` captures
  the ambient `OctoTheme` + `Directionality` and re-injects them into
  the overlay subtree so the pill keeps theme access even though the
  root `Overlay` sits above the inherited theme.
- **`OctoCollapsible`** — disclosure section (Primer "Accordion item").
  Supports both *uncontrolled* (`initiallyExpanded`) and *controlled*
  (`expanded` + `onExpansionChanged`) modes. Header is a focusable
  button: Space / Enter toggle expansion via `FocusableActionDetector`,
  state layer for hover / pressed, focus ring on keyboard focus.
  `Semantics(button: true, expanded: ...)` exposes the state to screen
  readers. The body height + chevron rotation animate over
  `animationDuration`; `MediaQuery.disableAnimationsOf` (ADR-0008) drops
  the duration to zero so transitions snap under motion-reduce.
- **`OctoProgressBar`** + `OctoProgressBarVariant` + `OctoProgressBarSize`
  — linear progress indicator. `value: double?` drives determinate (0..1)
  vs. indeterminate (`null`) modes. Indeterminate uses an
  `AnimationController.repeat()` sliding stripe; `MediaQuery
  .disableAnimationsOf` (motion-reduce / ADR-0008) automatically swaps in
  a static 50%-filled track so the bar still hints "in progress" without
  burning frames. Four variants (accent / success / attention / danger),
  two sizes (small = 4 px, medium = 8 px). Determinate value is exposed
  to `Semantics(value: '${n}%')`.
- **`OctoDivider`** + `OctoDividerAxis` + `OctoDividerEmphasis` — thin
  separator line between layout regions. Horizontal divider via the
  default constructor, vertical via `OctoDivider.vertical()`. Emphasis
  maps onto `theme.colors.border.{subtle,muted,defaultColor}`; `color`
  overrides the resolved palette value when needed. `indent` /
  `endIndent` inset the painted region while the widget itself still
  spans the full cross-axis (mirrors Material's `Divider` API). Wrapped
  in `ExcludeSemantics` — dividers are decorative.
- **`OctoChip`** ships a compact custom `_ChipDismissButton` (16×16)
  instead of reusing `OctoIconButton` so chips with and without an `x`
  share the same height.
- **`OctoDropdown<T>`** accepts an optional external `OctoMenuController`,
  letting callers (e.g. golden scenarios) open / close the popover
  programmatically without exposing internal state.
- Golden coverage: `octo_misc/dividers`, `octo_misc/progress_bars`,
  `octo_misc/collapsibles`, `octo_misc/toasts` (light + dark) and an
  `octo_pickers/dropdown_open` scenario that snapshots the menu in its
  open state.
- Demo: a new "Dividers" section in the kitchen-sink showing subtle /
  muted / strong horizontals plus a vertical inline strip.

## [0.4.0-dev.0] — 2026-05-09

### Added

- **`OctoSegmentedControl<T>`** + `OctoSegmentedControlItem<T>` —
  single-select group of connected buttons. Outer container uses
  `canvas.subtle`; the selected segment lifts above the rest with a
  `canvas.defaultColor` background and a subtle border. Items take a
  `label` and / or an `icon`. `Tab` walks between segments, `Space`
  activates the focused segment; the already-selected segment ignores
  taps. `Semantics(button, selected, enabled, label)` per segment.
- **`OctoChip`** + `OctoChipVariant` — compact interactive pill, filled
  rather than outlined (the distinguishing trait against `OctoLabel`).
  Five variants (`standard`/`accent`/`success`/`attention`/`danger`).
  Optional `onPressed` makes the chip tappable; optional `onDismiss`
  adds a trailing `OctIcons.x_16` close button with a
  `'Remove $label'` default a11y label.
- **`OctoDropdown<T>`** + `OctoDropdownItem<T>` — controlled single-
  select picker built on top of `OctoMenu`. Trigger renders the
  selected item's label plus a `chevron_down_16`; tapping opens a menu
  with all options (selected row pre-marked); picking an option fires
  `onChanged` and auto-closes the menu. `placeholder` shown while
  `value` is `null`.
- Demo grows three new sections — "Segmented control", "Chips",
  "Dropdown" — wired to live state.

## [0.3.0-dev.0] — 2026-05-05

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

## [0.2.0-dev.0] — 2026-05-01

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

## [0.1.0-dev.0] — 2026-04-26

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

[Unreleased]: https://github.com/Autocrab/flutter-octo-ui/compare/v0.4.0-dev.0...HEAD
[0.4.0-dev.0]: https://github.com/Autocrab/flutter-octo-ui/compare/v0.3.0-dev.0...v0.4.0-dev.0
[0.3.0-dev.0]: https://github.com/Autocrab/flutter-octo-ui/compare/v0.2.0-dev.0...v0.3.0-dev.0
[0.2.0-dev.0]: https://github.com/Autocrab/flutter-octo-ui/compare/v0.1.0-dev.0...v0.2.0-dev.0
[0.1.0-dev.0]: https://github.com/Autocrab/flutter-octo-ui/releases/tag/v0.1.0-dev.0
