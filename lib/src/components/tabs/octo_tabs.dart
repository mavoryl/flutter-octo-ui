import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/underline_nav/octo_underline_nav.dart';
import 'package:octo_ui/src/components/underline_nav/octo_underline_nav_item.dart';

/// Content-switching tab strip built on top of [OctoUnderlineNav].
///
/// Pairs a list of tab descriptors with an equal-length list of body
/// widgets and swaps the visible body whenever the user picks a
/// different tab. The tab bar is shared with [OctoUnderlineNav] for
/// visual consistency — `OctoTabs` adds the controller plumbing,
/// AnimatedSwitcher-driven body transitions, and a sane motion-reduce
/// path (ADR-0008).
///
/// **Modes.**
/// - *Uncontrolled* — pass [initialIndex] (defaults to 0). The widget
///   tracks its own selection.
/// - *Controlled* — pass [selectedIndex] (non-null) together with
///   [onTabChanged]; the parent owns the state and the widget mirrors
///   whatever the parent rebuilds with.
///
/// ```dart
/// OctoTabs(
///   tabs: const [
///     OctoUnderlineNavItem(label: 'Logs'),
///     OctoUnderlineNavItem(label: 'Metrics'),
///   ],
///   children: [LogsView(), MetricsView()],
/// )
/// ```
///
/// **Variants** — uncontrolled by default: pass [initialIndex] and let the widget
/// track the selection. Pass [selectedIndex] together with [onTabChanged] to
/// drive it from outside, e.g. from a route.
///
/// **States** — the bar's own hover / focus / selected handling comes from
/// [OctoUnderlineNav]. Bodies cross-fade over [switchDuration], and the fade is
/// skipped when the platform asks for reduced motion.
///
/// **Accessibility** — inherits the nav bar's per-item `Semantics(selected: …)`.
/// Only the visible body is in the tree, so a screen reader never walks content
/// belonging to a hidden tab.
///
/// See also:
///
///  * [OctoUnderlineNav], when the bodies live elsewhere — under a router, say.
class OctoTabs extends StatefulWidget {
  /// Tab descriptors (label / icon / trailing). The same shape used by
  /// [OctoUnderlineNav].
  final List<OctoUnderlineNavItem> tabs;

  /// Body widgets — one per tab. Must match `tabs.length`.
  final List<Widget> children;

  /// Initial selection when uncontrolled. Ignored when [selectedIndex]
  /// is non-null.
  final int initialIndex;

  /// Controlled selection. When non-null, the widget ignores its own
  /// internal flag and shows whatever index the parent passes.
  final int? selectedIndex;

  /// Fires with the requested next index whenever the user picks a
  /// different tab. Always fires (controlled or uncontrolled).
  final ValueChanged<int>? onTabChanged;

  /// Cross-fade duration between body panels. Drops to zero under
  /// `MediaQuery.disableAnimationsOf`.
  final Duration switchDuration;

  /// Creates a content-switching tab group.
  // ignore: prefer_const_constructors_in_immutables
  OctoTabs({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
    this.selectedIndex,
    this.onTabChanged,
    this.switchDuration = const Duration(milliseconds: 180),
  })  : assert(
          tabs.length == children.length,
          'tabs and children must have the same length',
        ),
        assert(tabs.isNotEmpty, 'at least one tab is required'),
        assert(
          initialIndex >= 0 && initialIndex < tabs.length,
          'initialIndex out of range',
        );

  @override
  State<OctoTabs> createState() => _OctoTabsState();
}

class _OctoTabsState extends State<OctoTabs> {
  late int _internalIndex;

  int get _index => widget.selectedIndex ?? _internalIndex;

  @override
  void initState() {
    super.initState();
    _internalIndex = widget.initialIndex;
  }

  void _onChanged(int next) {
    if (next == _index) return;
    if (widget.selectedIndex == null) {
      setState(() => _internalIndex = next);
    }
    widget.onTabChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final disableAnims = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = disableAnims ? Duration.zero : widget.switchDuration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        OctoUnderlineNav(
          items: widget.tabs,
          selectedIndex: _index,
          onChanged: _onChanged,
        ),
        AnimatedSwitcher(
          duration: duration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          // Key the child by index so the switcher detects swaps even
          // when adjacent panels share a runtime type.
          child: KeyedSubtree(
            key: ValueKey<int>(_index),
            child: widget.children[_index],
          ),
        ),
      ],
    );
  }
}
