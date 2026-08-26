import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/action_list/octo_action_list.dart';
import 'package:octo_ui/src/components/action_list/octo_action_list_item.dart';
import 'package:octo_ui/src/components/command_palette/octo_command_palette_controller.dart';
import 'package:octo_ui/src/components/text_field/octo_text_field.dart';
import 'package:octo_ui/src/foundation/octo_text.dart';
import 'package:octo_ui/src/theme/octo_theme.dart';

/// Modal command palette — search field + filterable action list,
/// rendered through [OverlayPortal] in the root [Overlay].
///
/// Wrap any subtree (typically the entire app) with [OctoCommandPalette]
/// to make the palette available from inside. Open it via the
/// [controller] or via [openShortcut] (e.g. `Cmd+K` / `Ctrl+K`). When
/// open, the modal:
///
///   * autofocuses the search field,
///   * filters [items] by case-insensitive substring match on
///     `label + description`,
///   * activates the first match on `Enter`,
///   * dismisses on `Escape`, outside tap, or item selection.
///
/// Requires an enclosing [Overlay] (provided by `MaterialApp` /
/// `WidgetsApp`).
///
/// ```dart
/// final palette = OctoCommandPaletteController();
///
/// OctoCommandPalette(
///   controller: palette,
///   placeholder: 'Search commands…',
///   items: [
///     OctoActionListItem(label: 'Open service', onPressed: _openService),
///     OctoActionListItem(label: 'Acknowledge alert', onPressed: _ack),
///   ],
///   child: appBody,
/// )
/// ```
///
/// **Variants** — [openShortcut] overrides the default ⌘K / Ctrl-K binding;
/// [maxWidth] and [maxHeight] bound the panel on large screens. Filtering is
/// built in: the query is matched as a substring of an entry's label or its
/// description, so a command is findable by what it does as well as by name.
///
/// **States** — the panel opens over [child] with the query field focused, the
/// first match highlighted, and hover / focus tracked per entry. Entries whose
/// label does not match the query are removed, not greyed out.
///
/// **Accessibility** — fully keyboard-driven, which is the whole point of the
/// component: the shortcut opens it, arrows move the highlight, Enter runs the
/// command, Escape closes and returns focus where it was. Entries carry
/// `Semantics(selected: …)` so the highlight is announced, not just painted.
///
/// See also:
///
///  * [OctoMenu], for a short list anchored to a specific trigger.
class OctoCommandPalette extends StatefulWidget {
  /// Open / closed state driver.
  final OctoCommandPaletteController controller;

  /// Commands the user can invoke.
  final List<OctoActionListItem> items;

  /// Subtree that hosts the palette overlay. Typically the whole app.
  final Widget child;

  /// Optional global keyboard shortcut that opens the palette. When
  /// `null`, the caller is responsible for invoking
  /// [OctoCommandPaletteController.open].
  /// Defaults to `null` — set e.g.
  /// `SingleActivator(LogicalKeyboardKey.keyK, meta: true)` for `Cmd+K`.
  final ShortcutActivator? openShortcut;

  /// Placeholder shown inside the search field.
  final String placeholder;

  /// Modal max width — clamped against the viewport.
  final double maxWidth;

  /// Modal max height — clamped against the viewport.
  final double maxHeight;

  /// Wraps [child] with a global command palette overlay.
  const OctoCommandPalette({
    super.key,
    required this.controller,
    required this.items,
    required this.child,
    this.openShortcut,
    this.placeholder = 'Type a command…',
    this.maxWidth = 600,
    this.maxHeight = 500,
  });

  @override
  State<OctoCommandPalette> createState() => _OctoCommandPaletteState();
}

class _OpenPaletteIntent extends Intent {
  const _OpenPaletteIntent();
}

class _OctoCommandPaletteState extends State<OctoCommandPalette> {
  final OverlayPortalController _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
  }

  @override
  void didUpdateWidget(OctoCommandPalette oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    final shouldShow = widget.controller.isOpen;
    if (shouldShow && !_portal.isShowing) _portal.show();
    if (!shouldShow && _portal.isShowing) _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: widget.child,
    );
    final shortcut = widget.openShortcut;
    if (shortcut == null) return overlay;
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{shortcut: const _OpenPaletteIntent()},
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(
            onInvoke: (_) {
              widget.controller.open();
              return null;
            },
          ),
        },
        // A focusable root ensures keypresses are routed up through this
        // Shortcuts when nothing in the host app has explicit focus. The
        // node skips Tab traversal so it doesn't intercept user-driven
        // focus movement.
        child: Focus(
          autofocus: true,
          skipTraversal: true,
          child: overlay,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return _PaletteModal(
      items: widget.items,
      placeholder: widget.placeholder,
      maxWidth: widget.maxWidth,
      maxHeight: widget.maxHeight,
      onSelect: (item) {
        widget.controller.close();
        item.onPressed?.call();
      },
      onClose: widget.controller.close,
    );
  }
}

class _PaletteModal extends StatefulWidget {
  final List<OctoActionListItem> items;
  final String placeholder;
  final double maxWidth;
  final double maxHeight;
  final void Function(OctoActionListItem) onSelect;
  final VoidCallback onClose;

  const _PaletteModal({
    required this.items,
    required this.placeholder,
    required this.maxWidth,
    required this.maxHeight,
    required this.onSelect,
    required this.onClose,
  });

  @override
  State<_PaletteModal> createState() => _PaletteModalState();
}

class _PaletteModalState extends State<_PaletteModal> {
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChange);
  }

  @override
  void dispose() {
    _query.removeListener(_onQueryChange);
    _query.dispose();
    super.dispose();
  }

  void _onQueryChange() {
    setState(() {});
  }

  List<OctoActionListItem> get _filtered {
    final q = _query.text.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items.where((item) {
      final hay = '${item.label} ${item.description ?? ''}'.toLowerCase();
      return hay.contains(q);
    }).toList(growable: false);
  }

  OctoActionListItem _wrap(OctoActionListItem item) {
    return OctoActionListItem(
      label: item.label,
      description: item.description,
      leading: item.leading,
      trailing: item.trailing,
      selected: item.selected,
      variant: item.variant,
      semanticLabel: item.semanticLabel,
      onPressed: item.onPressed == null ? null : () => widget.onSelect(item),
    );
  }

  void _handleSubmit(String _) {
    final filtered = _filtered;
    if (filtered.isEmpty) return;
    // Activate the first ENABLED row; null-onPressed rows are skipped.
    for (final item in filtered) {
      if (item.onPressed != null) {
        widget.onSelect(item);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    final radius = BorderRadius.all(Radius.circular(theme.radii.large));
    final filtered = _filtered;

    // OverlayPortal renders the overlay child in the root Overlay; the
    // Scaffold's Material is not an ancestor of that subtree, but
    // OctoTextField wraps Material's TextField which needs one. Provide
    // our own Material here.
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dimmed scrim — also catches taps that would otherwise hit the
          // unrelated app behind the modal.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onClose,
              child: ColoredBox(color: theme.colors.neutral.muted),
            ),
          ),
          // Modal body — TapRegion catches outside taps that landed on
          // descendants of the scrim but outside the modal itself; the
          // scrim onTap above covers everything else.
          Center(
            child: TapRegion(
              onTapOutside: (_) => widget.onClose(),
              child: Shortcuts(
                shortcuts: const <ShortcutActivator, Intent>{
                  SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
                },
                child: Actions(
                  actions: <Type, Action<Intent>>{
                    DismissIntent: CallbackAction<DismissIntent>(
                      onInvoke: (_) {
                        widget.onClose();
                        return null;
                      },
                    ),
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: widget.maxWidth,
                      maxHeight: widget.maxHeight,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colors.canvas.overlay,
                        border: Border.all(color: theme.colors.border.defaultColor),
                        borderRadius: radius,
                        boxShadow: theme.shadows.large,
                      ),
                      child: ClipRRect(
                        borderRadius: radius,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(theme.spacing.gap.md),
                              child: OctoTextField(
                                controller: _query,
                                placeholder: widget.placeholder,
                                autofocus: true,
                                onSubmitted: _handleSubmit,
                              ),
                            ),
                            Container(
                              height: 1,
                              color: theme.colors.border.subtle,
                            ),
                            if (filtered.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: theme.spacing.gap.lg,
                                  vertical: theme.spacing.gap.xl,
                                ),
                                child: OctoText(
                                  'No matching commands',
                                  kind: OctoTextKind.bodySmall,
                                  color: theme.colors.fg.muted,
                                ),
                              )
                            else
                              Flexible(
                                child: OctoActionList.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (_, i) => _wrap(filtered[i]),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
