# Changelog

## [Unreleased]

## [1.0.0] — 2026-08-26

`1.0.0` freezes the theme API and every component API under semantic
versioning. All eight criteria the plan set for this release are met: stable
theme and component APIs, light and dark themes, an accessibility baseline
verified by tests, examples, documentation, golden tests, and no known layout
breakage on web or desktop.

Known gaps, stated so the version number does not overclaim: the colour-blind
palette variants of `OctoColorSchemeVariant` are reserved enum slots that
throw `UnimplementedError`, and `lib/src/` stays private — internal paths may
still move without a major bump.

### Added

- **Per-component documentation.** All 37 components now carry a class-level
  doc comment following one template: summary, usage sample, variants, sizes,
  interactive states, and accessibility. Before this pass one component had a
  code sample and none documented their semantics; the API reference on pub.dev
  is now the primary documentation, with no separate site to fall out of sync.

  The accessibility sections are the substantive half — each one states what
  the widget exposes (`Semantics(button:)`, `selected`, `toggled`, `checked`,
  `expanded`, live regions), which keys operate it, and where a caller still
  has to do the work: `OctoIconButton` and `OctoAvatar` require a label because
  an icon or a face announces nothing, a tooltip is not an accessible name, and
  a toast must not be the only place an actionable message appears.

- **Doc samples are type-checked** (`test/docs/doc_snippets_test.dart`). Every
  Dart code fence in `lib/` is extracted, compiled against the real API, and
  the test fails on a wrong parameter name, wrong argument type, wrong arity or a
  missing required argument. It earned its place immediately: it caught eight
  defects while the samples were being written, including `OctoLabel` and
  `OctoCounterLabel` taking positional arguments and nav items wanting a
  `Widget` rather than an `IconData`.

- **CI gate on the API reference.** `dart doc` must report zero warnings. Seven
  unresolved `[references]` — five of them pre-existing — were rendering as
  literal brackets on pub.dev and are now fixed.

## [0.11.0] — 2026-08-26

### Changed

- **BREAKING (values, not API): colour tokens are now generated from Primer
  Primitives.** The four palettes (`light`, `dark`, and their high-contrast
  variants) and the `OctoBreakpoints` scale are emitted from a frozen
  `@primer/primitives` 11.10.0 snapshot committed at
  `tools/primer_primitives_snapshot.json`, rather than typed by hand. Two
  things change at once, and both are deliberate:

  1. **The generation path.** ADR-0009 called for a major bump when tokens stop
     being hand-written, even at identical values, because the source of truth
     moves.
  2. **~61 of 128 colour values** (light 5, dark 14, light-hc 23, dark-hc 27).
     ADR-0009 assumed a generator could reproduce the hand-written palette
     1:1; measurement across 149 upstream releases showed no version matches
     more than 83/128, and `border.muted` `#d8dee4` appears in no Primer
     release at all. The palette now follows current upstream instead.

  No API changed: same classes, same fields, same `copyWith`. If you pinned a
  layout or a screenshot to specific hex values, expect a visual diff. The
  loudest one is light-hc no longer being pure white — `canvas.inset` moves
  from `#ffffff` to `#eff2f5`. All 28 WCAG contrast assertions of ADR-0008
  still pass without touching a threshold.

  Two token slots have no direct Primer counterpart and are mapped explicitly:
  `fg.subtle` → `fgColor-disabled` (upstream removed `fgColor-subtle`) and
  `neutral.emphasisPlus` → `bgColor-inverse`. See ADR-0010 for the full
  reasoning and for what stays hand-written — `OctoRadius`, `OctoTypography`,
  `OctoShadows`, `OctoAnimation` and the `gap`/`inset` aliases are outside the
  generator's remit.

### Added

- **`tools/octo_tokens_gen`** — the generator itself: a dev-only Dart package
  (`publish_to: none`, stripped from the published archive). `fetch --version
  <x.y.z>` downloads upstream, trims ~1000 tokens per theme down to the few
  dozen octo_ui consumes, and records the tarball sha256 for provenance;
  `generate` emits `lib/src/tokens/generated/primer_tokens.g.dart`;
  `generate --check` fails when the committed output has drifted, and runs in
  CI as a fourth gate beside format, analyze and test. Upgrading Primer is now
  two commands with a reviewable value diff instead of hand-edited hex.

## [0.10.0] — 2026-08-26

### Added

- **Responsive layer** (`OctoBreakpoint`, `context.octoBreakpoint`,
  `context.isAtLeast`, `OctoResponsiveBuilder`). `OctoBreakpoints` has
  been a theme token since the first release with nothing reading it;
  this is the API that does. The extension resolves against the window
  via `MediaQuery`, the builder against the incoming constraints via
  `LayoutBuilder` — the distinction that matters for content sitting
  beside a sidebar. Thresholds come from the theme, so `copyWith`
  re-tunes every call site at once.
- **`OctoFilterBar`** — search-and-filter row above a list or table. The
  search field is built in; the filters themselves are caller-supplied
  widgets in a `Wrap`, so a narrow bar reflows instead of overflowing.
  Optional clear button and an active-filter counter.
- **Service-monitoring dashboard** in `example/`, now the landing screen
  of the demo (the kitchen sink is one tap away and still there). Dense
  table, real filtering, incident feed — and three layout decisions
  driven by the responsive layer rather than by fixed widths: the KPI row
  goes 1 / 2 / 4 columns, the sidebar collapses into a popover below
  `lg`, and the table drops its latency / error columns below `md`.

### Fixed

- **`OctoStateLabel` overflowed a narrow column.** Status pills live in
  table cells, where the column decides the width — the label now
  ellipsizes instead of painting an overflow stripe across the row.

### Changed

- README drops the golden-testing section: it documented the package's
  own test tooling, which is not what a consumer of the package needs
  from the pub.dev landing page.

## [0.9.0] — 2026-08-26

### Added

- **`OctoCard`** — content surface (Primer "Box"). Presentational by
  default; passing `onPressed` turns it into a full interactive surface
  with hover / focus / pressed states, a focus ring, and
  `Semantics.button`. `selected` works in both modes so a list of
  read-only cards can still show which row is current. Two treatments
  via `OctoCardVariant`: `outlined` (hairline border) and `elevated`
  (drop shadow).
- **`OctoEmptyState`** — placeholder for a surface with nothing to show
  (Primer "Blankslate"): optional icon, title announced as a header,
  optional description, and a wrapped row of `actions`.
- **`OctoAvatarStack`** — overlapping avatar row. The first face paints
  on top, each avatar is ringed in the canvas colour so the overlap
  stays legible, and `maxVisible` collapses the remainder into a `+N`
  counter whose accessibility label is customisable through
  `overflowLabelBuilder`. Overlap is tunable via `overlapRatio`.
- **`OctoPopover`** — anchored surface holding arbitrary content, with
  four placements (`bottomStart` / `bottomEnd` / `topStart` / `topEnd`)
  resolved against the ambient `Directionality`. Same overlay machinery
  as `OctoMenu` — `OverlayPortal` + `LayerLink`, outside-tap and Escape
  dismissal — but tapping *inside* does not dismiss, since the content
  is a form rather than a list of actions.
- **`OctoAvatar.dimension`** — public getter for the diameter of a size
  bucket, so composites can compute geometry without duplicating the
  size table.
- Golden coverage for all four new components across the full theme
  axis (light / dark / light-hc / dark-hc), including hover / pressed /
  selected / focused card states and all three popover placements.

### Changed

- **`OctoMenuController` is now a typedef for `OctoOverlayController`.**
  The driver is shared by every anchored overlay in the kit, so it moved
  to `foundation/` under a name that does not claim to be menu-specific.
  Existing code keeps compiling — `OctoMenuController` remains a valid
  type name.

### Changed (toolchain)

- **CI now pins Flutter `3.44.8`** (was `3.35.7`), matching the version
  used for development. Flutter 3.44 reworked the semantics flag API:
  `isChecked` became a `CheckedState` enum, and `isSelected` /
  `isEnabled` / `isToggled` / `isExpanded` became `Tristate`, while
  `hasCheckedState`, `hasToggledState`, and `isCheckStateMixed` were
  removed — a single `CheckedState.mixed` / `Tristate.isTrue` now
  carries what used to take two or three flags. Sixteen semantics
  assertions across the suite were migrated accordingly. No `lib/` code
  changed, so the `flutter: ">=3.27.0"` constraint stays as it is — only
  the test suite requires the newer SDK.
- **`octo_command_palette` goldens rebaked.** Flutter 3.44 changed the
  Material input metrics, so the palette's search field now stretches
  closer to the panel edges and its rows sit slightly tighter. Visual
  change from the framework, not from this package.

### Fixed

- **Tapping the trigger of an open `OctoMenu` did not close it.** The
  trigger sat outside the popover's `TapRegion`, so the tap first fired
  `onTapOutside` (closing the menu) and then the trigger's own `toggle`
  (reopening it). Trigger and surface now share a `TapRegion` group.
  `OctoPopover` was built with the same group from the start.
- **`OctoAvatar` announced its initials on top of its label.** The
  fallback text is a visual stand-in for the name, never extra
  information, so a screen reader read "Marat Shakirov MA". The initials
  are now wrapped in `ExcludeSemantics`.

## [0.8.6]

### Changed

- Repository moved from `Autocrab/flutter-octo-ui` to
  `mavoryl/flutter-octo-ui` (organisation account). All in-repo URLs,
  badges, the live-demo link, and the demo / breadcrumb-test labels
  flip to the new owner. `LICENSE` / `NOTICE` keep the `Autocrab`
  copyright line — those identify the legal author, not the GitHub
  host.

### Added

- `screenshots:` section in `pubspec.yaml` so the pub.dev landing card
  carries a four-image carousel (data table, state labels, command
  palette, timeline) instead of falling back to a plain text preview.

## [0.8.5]
### Added

- **`OctoTooltip.tooltipKey`** — optional `Key` forwarded to the inner
  Material `Tooltip`. Lets callers hold a `GlobalKey<TooltipState>` and
  drive show / dismiss programmatically — useful for golden snapshots,
  guided tutorials, and first-run coachmarks.
- Golden coverage: a new `octo_tooltip/shown` scenario captures the
  popup at full opacity across all four theme variants.
- The golden theme axis (`octoThemes`) now includes `light-hc` and
  `dark-hc` so every existing scenario also snapshots the high-contrast
  palette. Catches regressions where a component reads from the wrong
  token slot in addition to the WCAG-AA contrast unit tests.

### Fixed

- **Dark-theme tooltip was unreadable** — the popup used
  `neutral.emphasisPlus` as its background, but in Primer's dark
  palette `emphasisPlus` flips to a light "highest-contrast inverse
  surface" colour. Pairing that with `fg.onEmphasis` (white in dark
  mode) rendered white text on a near-white tooltip. The Material
  adapter now uses `neutral.emphasis` for the tooltip background —
  it stays high-contrast against the canvas in every palette and
  pairs correctly with `fg.onEmphasis`.
- The tooltip popup textStyle now sets an explicit `fontFamily`
  (`'Roboto'` with a platform-aware fallback cascade). Previously the
  textStyle inherited only `fontFamilyFallback` from the ambient
  typography, but Material's `_TooltipOverlay` replaces the ambient
  `DefaultTextStyle` rather than merging into it — so on platforms
  where the fallback families don't resolve (Linux desktop, certain
  embedded builds, golden tests) every glyph rendered as the Ahem
  `.notdef` block.

## [0.8.3]
### Added

- Live demo on GitHub Pages — the kitchen-sink runs in-browser at
  <https://mavoryl.github.io/flutter-octo-ui/>, redeployed on every
  push to `main`. Built with `flutter build web --release --wasm` so
  the Skwasm renderer is used on modern Chromium / Firefox with
  automatic CanvasKit fallback for older browsers.
- README now opens with a link to the live demo right under the
  badges.

## [0.8.2]
### Added

- Five pub.dev topics for discovery: `design-system`, `ui`, `widgets`,
  `theme`, `dashboard`.
- Codecov badge in the README; `flutter test --coverage` now uploads
  `coverage/lcov.info` to codecov from CI.

### Changed

- CI gates `lib/` line coverage at **>= 90%** — a regression that
  drops below the threshold fails the workflow. Current coverage
  sits at 92.4%, leaving headroom for the next round of features.

## [0.8.1]
### Changed

- Minor fixes — README now ships pub.dev + CI badges and the install
  snippet drops the git-ref fallback now that the package is live.

## [0.8.0]
First stable release on pub.dev. Promotes the `0.7.0-dev.0` component
surface (25 components across form / display / navigation / overlay /
data / layout categories) without API changes.

### Changed

- Repository / issue-tracker URLs in `pubspec.yaml` point at the
  canonical `github.com/mavoryl/flutter-octo-ui` location.
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

## [0.7.0-dev.0]
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

## [0.6.0-dev.0]
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

## [0.5.0-dev.0]
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

## [0.4.0-dev.0]
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

## [0.3.0-dev.0]
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

## [0.2.0-dev.0]
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

## [0.1.0-dev.0]
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

[Unreleased]: https://github.com/mavoryl/flutter-octo-ui/compare/v0.4.0-dev.0...HEAD
[0.4.0-dev.0]: https://github.com/mavoryl/flutter-octo-ui/compare/v0.3.0-dev.0...v0.4.0-dev.0
[0.3.0-dev.0]: https://github.com/mavoryl/flutter-octo-ui/compare/v0.2.0-dev.0...v0.3.0-dev.0
[0.2.0-dev.0]: https://github.com/mavoryl/flutter-octo-ui/compare/v0.1.0-dev.0...v0.2.0-dev.0
[0.1.0-dev.0]: https://github.com/mavoryl/flutter-octo-ui/releases/tag/v0.1.0-dev.0
