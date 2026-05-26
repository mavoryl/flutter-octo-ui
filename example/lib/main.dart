import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
// Octicons are re-exported by package:octo_ui/octo_ui.dart as `OctIcons`.
import 'package:octo_ui/octo_ui.dart';

void main() => runApp(const KitchenSinkApp());

class KitchenSinkApp extends StatefulWidget {
  const KitchenSinkApp({super.key});

  @override
  State<KitchenSinkApp> createState() => _KitchenSinkAppState();
}

class _KitchenSinkAppState extends State<KitchenSinkApp> {
  bool _dark = false;
  bool _highContrast = false;
  final OctoCommandPaletteController _paletteController =
      OctoCommandPaletteController();

  void _toggleDark() => setState(() => _dark = !_dark);

  void _toggleHighContrast() => setState(() => _highContrast = !_highContrast);

  @override
  void dispose() {
    _paletteController.dispose();
    super.dispose();
  }

  List<OctoActionListItem> _paletteItems() => [
        OctoActionListItem(
          label: _dark ? 'Switch to light theme' : 'Switch to dark theme',
          leading: Icon(_dark ? OctIcons.sun_16 : OctIcons.moon_16),
          onPressed: _toggleDark,
        ),
        OctoActionListItem(
          label: _highContrast
              ? 'Switch to standard contrast'
              : 'Switch to high contrast',
          leading: Icon(_highContrast
              ? OctIcons.accessibility_16
              : OctIcons.accessibility_inset_16),
          onPressed: _toggleHighContrast,
        ),
        OctoActionListItem(
          label: 'New issue',
          description: 'Open the issue composer',
          leading: const Icon(OctIcons.plus_16),
          onPressed: () {},
        ),
        OctoActionListItem(
          label: 'Open pull requests',
          leading: const Icon(OctIcons.git_pull_request_16),
          onPressed: () {},
        ),
        OctoActionListItem(
          label: 'Repository settings',
          leading: const Icon(OctIcons.gear_16),
          onPressed: () {},
        ),
        OctoActionListItem(
          label: 'Delete repository',
          leading: const Icon(OctIcons.trash_16),
          variant: OctoActionListItemVariant.danger,
          onPressed: () {},
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final variant = _highContrast
        ? OctoColorSchemeVariant.highContrast
        : OctoColorSchemeVariant.standard;
    final octo = _dark
        ? OctoThemeData.dark(variant: variant)
        : OctoThemeData.light(variant: variant);
    return OctoTheme(
      data: octo,
      child: MaterialApp(
        title: 'octo_ui kitchen sink',
        debugShowCheckedModeBanner: false,
        theme: octo.toMaterialTheme(),
        home: OctoCommandPalette(
          controller: _paletteController,
          items: _paletteItems(),
          // Cmd+K on macOS, Ctrl+K elsewhere — same activator covers both
          // because LogicalKeyboardKey.meta maps to the platform's command
          // key on macOS and the Windows / Super key on Linux. For desktops
          // a separate `control: true` activator could be added.
          openShortcut: const SingleActivator(
            LogicalKeyboardKey.keyK,
            meta: true,
          ),
          child: KitchenSinkPage(
            isDark: _dark,
            isHighContrast: _highContrast,
            onToggleTheme: _toggleDark,
            onToggleHighContrast: _toggleHighContrast,
            onOpenPalette: _paletteController.open,
          ),
        ),
      ),
    );
  }
}

class KitchenSinkPage extends StatefulWidget {
  final bool isDark;
  final bool isHighContrast;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleHighContrast;
  final VoidCallback onOpenPalette;

  const KitchenSinkPage({
    super.key,
    required this.isDark,
    required this.isHighContrast,
    required this.onToggleTheme,
    required this.onToggleHighContrast,
    required this.onOpenPalette,
  });

  @override
  State<KitchenSinkPage> createState() => _KitchenSinkPageState();
}

class _KitchenSinkPageState extends State<KitchenSinkPage> {
  final TextEditingController _emailController = TextEditingController();
  final OctoMenuController _menuController = OctoMenuController();
  bool _showError = false;
  String _lastAction = '';
  int _navIndex = 0;
  bool _notifications = true;
  bool? _terms = false;
  String _priority = 'medium';
  bool _showSkeleton = false;
  String? _dialogResult;
  String _segment = 'open';
  String? _droppedPriority = 'medium';
  final Set<String> _chips = {'frontend', 'flutter', 'p1'};

  @override
  void dispose() {
    _emailController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  void _record(String action) => setState(() => _lastAction = action);

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colors.canvas.defaultColor,
      appBar: AppBar(
        backgroundColor: theme.colors.canvas.subtle,
        surfaceTintColor: theme.colors.canvas.subtle,
        elevation: 0,
        shape:
            Border(bottom: BorderSide(color: theme.colors.border.defaultColor)),
        title: const OctoText('octo_ui kitchen sink', kind: OctoTextKind.title),
        actions: [
          OctoTooltip(
            message: 'Open command palette (⌘K)',
            child: OctoIconButton(
              icon: OctIcons.search_16,
              onPressed: widget.onOpenPalette,
              variant: OctoButtonVariant.invisible,
              semanticLabel: 'Open command palette',
            ),
          ),
          SizedBox(width: theme.spacing.gap.sm),
          OctoIconButton(
            icon: widget.isHighContrast
                ? OctIcons.accessibility_16
                : OctIcons.accessibility_inset_16,
            onPressed: widget.onToggleHighContrast,
            variant: OctoButtonVariant.invisible,
            semanticLabel: widget.isHighContrast
                ? 'Switch to standard contrast'
                : 'Switch to high contrast',
          ),
          SizedBox(width: theme.spacing.gap.sm),
          OctoIconButton(
            icon: widget.isDark ? OctIcons.sun_16 : OctIcons.moon_16,
            onPressed: widget.onToggleTheme,
            variant: OctoButtonVariant.invisible,
            semanticLabel: widget.isDark
                ? 'Switch to light theme'
                : 'Switch to dark theme',
          ),
          SizedBox(width: theme.spacing.gap.md),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Section(
                  title: 'Breadcrumbs',
                  child: OctoBreadcrumbs(
                    items: [
                      OctoBreadcrumbItem(
                        label: 'Autocrab',
                        onPressed: () => _record('Autocrab'),
                      ),
                      OctoBreadcrumbItem(
                        label: 'octo_ui',
                        onPressed: () => _record('octo_ui'),
                      ),
                      const OctoBreadcrumbItem(label: 'main'),
                    ],
                  ),
                ),
                _Section(
                  title: 'Avatars',
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      OctoAvatar(
                        initials: 'X',
                        size: OctoAvatarSize.xs,
                        semanticLabel: 'X',
                      ),
                      OctoAvatar(
                        initials: 'S',
                        size: OctoAvatarSize.sm,
                        semanticLabel: 'S',
                      ),
                      OctoAvatar(initials: 'MA', semanticLabel: 'MA'),
                      OctoAvatar(
                        initials: 'JD',
                        size: OctoAvatarSize.lg,
                        semanticLabel: 'JD',
                      ),
                      OctoAvatar(
                        initials: 'XL',
                        size: OctoAvatarSize.xl,
                        semanticLabel: 'XL',
                      ),
                      OctoAvatar(
                        initials: 'OG',
                        shape: OctoAvatarShape.square,
                        size: OctoAvatarSize.lg,
                        semanticLabel: 'OG org',
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Underline nav — section tabs',
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: OctoUnderlineNav(
                      selectedIndex: _navIndex,
                      onChanged: (i) => setState(() => _navIndex = i),
                      items: const [
                        OctoUnderlineNavItem(
                          label: 'Code',
                          icon: Icon(OctIcons.code_16),
                        ),
                        OctoUnderlineNavItem(
                          label: 'Issues',
                          icon: Icon(OctIcons.bug_16),
                          trailing: OctoCounterLabel(12),
                        ),
                        OctoUnderlineNavItem(
                          label: 'Pull requests',
                          icon: Icon(OctIcons.git_pull_request_16),
                          trailing: OctoCounterLabel(3),
                        ),
                        OctoUnderlineNavItem(
                          label: 'Settings',
                          icon: Icon(OctIcons.gear_16),
                        ),
                      ],
                    ),
                  ),
                ),
                _Section(
                  title: 'Labels',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      OctoLabel('Bug'),
                      OctoLabel('Feature', variant: OctoLabelVariant.accent),
                      OctoLabel('Merged', variant: OctoLabelVariant.success),
                      OctoLabel('Review', variant: OctoLabelVariant.attention),
                      OctoLabel('Critical', variant: OctoLabelVariant.danger),
                    ],
                  ),
                ),
                _Section(
                  title: 'Counter labels',
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: const [
                      OctoText('Issues', kind: OctoTextKind.body),
                      OctoCounterLabel(12),
                      OctoText('Pull requests', kind: OctoTextKind.body),
                      OctoCounterLabel(
                        4,
                        variant: OctoCounterLabelVariant.primary,
                      ),
                      OctoText('Stars', kind: OctoTextKind.body),
                      OctoCounterLabel(
                        1248,
                        maxDisplayed: 999,
                        variant: OctoCounterLabelVariant.secondary,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Buttons — variants',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoButton.label('Save',
                          onPressed: () {}, variant: OctoButtonVariant.primary),
                      OctoButton.label('Cancel', onPressed: () {}),
                      OctoButton.label('Delete',
                          onPressed: () {}, variant: OctoButtonVariant.danger),
                      OctoButton.label('Edit',
                          onPressed: () {},
                          variant: OctoButtonVariant.invisible),
                      OctoButton.label('Disabled', onPressed: null),
                    ],
                  ),
                ),
                _Section(
                  title: 'Buttons — sizes',
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoButton.label('Small',
                          onPressed: () {}, size: OctoButtonSize.small),
                      OctoButton.label('Medium', onPressed: () {}),
                      OctoButton.label('Large',
                          onPressed: () {}, size: OctoButtonSize.large),
                    ],
                  ),
                ),
                _Section(
                  title: 'Icon buttons',
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoIconButton(
                        icon: OctIcons.star_16,
                        onPressed: () {},
                        semanticLabel: 'Star',
                      ),
                      OctoIconButton(
                        icon: OctIcons.heart_16,
                        onPressed: () {},
                        variant: OctoButtonVariant.primary,
                        semanticLabel: 'Favorite',
                      ),
                      OctoIconButton(
                        icon: OctIcons.kebab_horizontal_16,
                        onPressed: () {},
                        variant: OctoButtonVariant.invisible,
                        semanticLabel: 'More',
                      ),
                      const OctoIconButton(
                        icon: OctIcons.lock_16,
                        onPressed: null,
                        semanticLabel: 'Locked',
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Flashes',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      OctoFlash(
                          message: 'A new release is available.',
                          icon: OctIcons.info_16),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Changes saved successfully.',
                        variant: OctoFlashVariant.success,
                        icon: OctIcons.check_circle_16,
                      ),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Review required before merge.',
                        variant: OctoFlashVariant.attention,
                        icon: OctIcons.alert_16,
                      ),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Build failed — see the logs for details.',
                        variant: OctoFlashVariant.danger,
                        icon: OctIcons.x_circle_16,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Text field',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OctoTextField(
                        label: 'Email',
                        placeholder: 'you@example.com',
                        controller: _emailController,
                        helperText: 'Used for login only',
                        errorText: _showError ? 'Invalid email address' : null,
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                      OctoButton.label(
                        _showError ? 'Hide error' : 'Show error',
                        onPressed: () =>
                            setState(() => _showError = !_showError),
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                      const OctoTextField(
                        placeholder: 'disabled',
                        enabled: false,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Segmented control — single-select filter',
                  child: Row(
                    children: [
                      OctoSegmentedControl<String>(
                        value: _segment,
                        onChanged: (v) => setState(() => _segment = v),
                        items: const [
                          OctoSegmentedControlItem(value: 'all', label: 'All'),
                          OctoSegmentedControlItem(
                              value: 'open', label: 'Open'),
                          OctoSegmentedControlItem(
                            value: 'closed',
                            label: 'Closed',
                            icon: Icon(OctIcons.check_circle_16),
                          ),
                        ],
                      ),
                      SizedBox(width: theme.spacing.gap.md),
                      OctoText(
                        'Viewing: $_segment',
                        kind: OctoTextKind.bodySmall,
                        color: theme.colors.fg.muted,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Chips — labels, filters, recipients',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in _chips)
                        OctoChip(
                          label: tag,
                          variant: tag == 'p1'
                              ? OctoChipVariant.danger
                              : OctoChipVariant.standard,
                          onDismiss: () => setState(() => _chips.remove(tag)),
                        ),
                      const OctoChip(
                          label: 'preview', variant: OctoChipVariant.accent),
                    ],
                  ),
                ),
                _Section(
                  title: 'Dropdown — single-select picker',
                  child: Row(
                    children: [
                      OctoDropdown<String>(
                        value: _droppedPriority,
                        onChanged: (v) => setState(() => _droppedPriority = v),
                        items: const [
                          OctoDropdownItem(value: 'low', label: 'Low'),
                          OctoDropdownItem(value: 'medium', label: 'Medium'),
                          OctoDropdownItem(value: 'high', label: 'High'),
                        ],
                      ),
                      SizedBox(width: theme.spacing.gap.md),
                      OctoText(
                        'Priority: ${_droppedPriority ?? "—"}',
                        kind: OctoTextKind.bodySmall,
                        color: theme.colors.fg.muted,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Collapsible — accordion sections',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OctoCollapsible(
                        title: 'Repository details',
                        initiallyExpanded: true,
                        child: OctoText(
                          'Primer-inspired Flutter UI kit. Foundation '
                          'tokens, themed Material adapter, and a growing '
                          'set of components.',
                          kind: OctoTextKind.bodySmall,
                          color: theme.colors.fg.muted,
                        ),
                      ),
                      SizedBox(height: theme.spacing.gap.sm),
                      OctoCollapsible(
                        title: 'Roadmap',
                        child: OctoText(
                          'Toast / SnackBar, Tabs, Pagination, Table — see '
                          'CHANGELOG for the running list.',
                          kind: OctoTextKind.bodySmall,
                          color: theme.colors.fg.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Toasts — transient overlay feedback',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OctoButton.label(
                        'Show success',
                        onPressed: () => OctoToast.show(
                          context,
                          message: 'Changes saved',
                          variant: OctoToastVariant.success,
                        ),
                      ),
                      OctoButton.label(
                        'Show warning',
                        variant: OctoButtonVariant.invisible,
                        onPressed: () => OctoToast.show(
                          context,
                          message: 'Heads up — 3 packages need an upgrade',
                          variant: OctoToastVariant.attention,
                        ),
                      ),
                      OctoButton.label(
                        'Show with action',
                        variant: OctoButtonVariant.invisible,
                        onPressed: () => OctoToast.show(
                          context,
                          message: 'Note archived',
                          action: OctoToastAction(
                            label: 'Undo',
                            onPressed: () {},
                          ),
                        ),
                      ),
                      OctoButton.label(
                        'Show danger',
                        variant: OctoButtonVariant.danger,
                        onPressed: () => OctoToast.show(
                          context,
                          message: 'Failed to publish workflow',
                          variant: OctoToastVariant.danger,
                          dismissible: true,
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Spinners — small / medium / large',
                  child: Row(
                    children: [
                      const OctoSpinner(size: OctoSpinnerSize.small),
                      SizedBox(width: theme.spacing.gap.md),
                      const OctoSpinner(),
                      SizedBox(width: theme.spacing.gap.md),
                      const OctoSpinner(size: OctoSpinnerSize.large),
                      SizedBox(width: theme.spacing.gap.md),
                      OctoText(
                        'Fetching repositories…',
                        kind: OctoTextKind.bodySmall,
                        color: theme.colors.fg.muted,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Progress bars — determinate + indeterminate',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const OctoText('accent · 25%',
                          kind: OctoTextKind.bodySmall),
                      const SizedBox(height: 6),
                      const OctoProgressBar(value: 0.25),
                      const SizedBox(height: 12),
                      const OctoText('success · 75%',
                          kind: OctoTextKind.bodySmall),
                      const SizedBox(height: 6),
                      const OctoProgressBar(
                        value: 0.75,
                        variant: OctoProgressBarVariant.success,
                      ),
                      const SizedBox(height: 12),
                      const OctoText('danger · small · 40%',
                          kind: OctoTextKind.bodySmall),
                      const SizedBox(height: 6),
                      const OctoProgressBar(
                        value: 0.4,
                        variant: OctoProgressBarVariant.danger,
                        size: OctoProgressBarSize.small,
                      ),
                      const SizedBox(height: 12),
                      const OctoText('indeterminate',
                          kind: OctoTextKind.bodySmall),
                      const SizedBox(height: 6),
                      const OctoProgressBar(),
                    ],
                  ),
                ),
                _Section(
                  title: 'Dividers — subtle / muted / strong + vertical',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const OctoText('Subtle', kind: OctoTextKind.bodySmall),
                      const SizedBox(height: 6),
                      const OctoDivider(emphasis: OctoDividerEmphasis.subtle),
                      const SizedBox(height: 12),
                      const OctoText('Muted', kind: OctoTextKind.bodySmall),
                      const SizedBox(height: 6),
                      const OctoDivider(),
                      const SizedBox(height: 12),
                      const OctoText('Strong + indent',
                          kind: OctoTextKind.bodySmall),
                      const SizedBox(height: 6),
                      const OctoDivider(
                        emphasis: OctoDividerEmphasis.strong,
                        indent: 32,
                        endIndent: 32,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 28,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Center(
                                child: OctoText('Inline A',
                                    kind: OctoTextKind.bodySmall),
                              ),
                            ),
                            const OctoDivider.vertical(),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Center(
                                child: OctoText('Inline B',
                                    kind: OctoTextKind.bodySmall),
                              ),
                            ),
                            const OctoDivider.vertical(),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Center(
                                child: OctoText('Inline C',
                                    kind: OctoTextKind.bodySmall),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Form controls',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          OctoSwitch(
                            value: _notifications,
                            onChanged: (v) =>
                                setState(() => _notifications = v),
                            semanticLabel: 'Notifications',
                          ),
                          SizedBox(width: theme.spacing.gap.md),
                          OctoText(
                            _notifications
                                ? 'Notifications: enabled'
                                : 'Notifications: muted',
                            kind: OctoTextKind.body,
                          ),
                        ],
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                      Row(
                        children: [
                          OctoCheckbox(
                            value: _terms,
                            tristate: true,
                            onChanged: (v) => setState(() => _terms = v),
                            semanticLabel: 'I accept the terms',
                          ),
                          SizedBox(width: theme.spacing.gap.md),
                          const OctoText(
                            'I accept the terms (tap cycles tri-state)',
                            kind: OctoTextKind.body,
                          ),
                        ],
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                      OctoText(
                        'Priority',
                        kind: OctoTextKind.label,
                        color: theme.colors.fg.muted,
                      ),
                      SizedBox(height: theme.spacing.gap.sm),
                      Row(
                        children: [
                          for (final p in const ['low', 'medium', 'high']) ...[
                            OctoRadio<String>(
                              value: p,
                              groupValue: _priority,
                              onChanged: (v) => setState(() => _priority = v!),
                            ),
                            SizedBox(width: theme.spacing.gap.sm),
                            OctoText(p, kind: OctoTextKind.body),
                            SizedBox(width: theme.spacing.gap.lg),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Tooltips — hover or long-press',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoTooltip(
                        message: 'Save changes (⌘S)',
                        child: OctoButton.label(
                          'Save',
                          onPressed: () => _record('Save tapped'),
                          variant: OctoButtonVariant.primary,
                        ),
                      ),
                      OctoTooltip(
                        message: 'Watch this repository',
                        child: OctoIconButton(
                          icon: OctIcons.eye_16,
                          onPressed: () => _record('Watch tapped'),
                          semanticLabel: 'Watch',
                        ),
                      ),
                      OctoTooltip(
                        message: 'Pinned for later',
                        child: OctoIconButton(
                          icon: OctIcons.pin_16,
                          onPressed: () => _record('Pin tapped'),
                          variant: OctoButtonVariant.invisible,
                          semanticLabel: 'Pin',
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Menu — controller-driven popover',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OctoMenu(
                        controller: _menuController,
                        items: [
                          OctoActionListItem(
                            label: 'New issue',
                            leading: const Icon(OctIcons.plus_16),
                            onPressed: () => _record('New issue'),
                          ),
                          OctoActionListItem(
                            label: 'New pull request',
                            leading: const Icon(OctIcons.git_pull_request_16),
                            onPressed: () => _record('New PR'),
                          ),
                          OctoActionListItem(
                            label: 'Settings',
                            leading: const Icon(OctIcons.gear_16),
                            onPressed: () => _record('Settings'),
                          ),
                          OctoActionListItem(
                            label: 'Delete repository',
                            leading: const Icon(OctIcons.trash_16),
                            variant: OctoActionListItemVariant.danger,
                            onPressed: () => _record('Delete'),
                          ),
                        ],
                        child: OctoButton.label(
                          'More actions',
                          onPressed: _menuController.toggle,
                          trailingIcon: const Icon(OctIcons.chevron_down_16),
                        ),
                      ),
                      SizedBox(width: theme.spacing.gap.md),
                      Flexible(
                        child: OctoText(
                          _lastAction.isEmpty
                              ? 'Pick something from the menu…'
                              : 'Last action: $_lastAction',
                          kind: OctoTextKind.bodySmall,
                          color: theme.colors.fg.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Action list — inline (e.g. drawer / sidebar)',
                  child: SizedBox(
                    width: 320,
                    child: OctoActionList(
                      items: [
                        OctoActionListItem(
                          label: 'Code',
                          leading: const Icon(OctIcons.code_16),
                          trailing: const OctoCounterLabel(42),
                          onPressed: () => _record('Code'),
                          selected: true,
                        ),
                        OctoActionListItem(
                          label: 'Issues',
                          leading: const Icon(OctIcons.bug_16),
                          trailing: const OctoCounterLabel(7),
                          onPressed: () => _record('Issues'),
                        ),
                        OctoActionListItem(
                          label: 'Pull requests',
                          leading: const Icon(OctIcons.git_pull_request_16),
                          trailing: const OctoCounterLabel(3),
                          onPressed: () => _record('PRs'),
                        ),
                        OctoActionListItem(
                          label: 'Settings',
                          leading: const Icon(OctIcons.gear_16),
                          description: 'Members, integrations, secrets',
                          onPressed: () => _record('Settings'),
                        ),
                      ],
                    ),
                  ),
                ),
                _Section(
                  title: 'Skeleton — loading placeholders',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          OctoButton.label(
                            _showSkeleton ? 'Hide loading' : 'Show loading',
                            onPressed: () =>
                                setState(() => _showSkeleton = !_showSkeleton),
                          ),
                        ],
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                      if (_showSkeleton)
                        const SizedBox(
                          width: 320,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  OctoSkeletonAvatar(),
                                  SizedBox(width: 12),
                                  Expanded(child: OctoSkeletonText(lines: 2)),
                                ],
                              ),
                              SizedBox(height: 16),
                              OctoSkeleton(height: 32),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            const OctoAvatar(
                                initials: 'JD', semanticLabel: 'JD'),
                            SizedBox(width: theme.spacing.gap.md),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OctoText(
                                    'Jane Doe',
                                    kind: OctoTextKind.bodyEmphasis,
                                  ),
                                  OctoText(
                                    'Opened PR #42 a moment ago.',
                                    kind: OctoTextKind.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Dialog — confirm destructive action',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OctoButton.label(
                        'Delete repository…',
                        leadingIcon: const Icon(OctIcons.trash_16),
                        variant: OctoButtonVariant.danger,
                        onPressed: () async {
                          final ctx = context;
                          final result = await OctoDialog.show<String>(
                            context: ctx,
                            title: const OctoDialogTitle('Delete repository?'),
                            content: const OctoText(
                              'This action cannot be undone. The repository '
                              'and all of its history will be permanently '
                              'removed.',
                            ),
                            actions: [
                              Builder(
                                builder: (dCtx) => OctoButton.label(
                                  'Cancel',
                                  onPressed: () =>
                                      Navigator.pop(dCtx, 'cancel'),
                                ),
                              ),
                              Builder(
                                builder: (dCtx) => OctoButton.label(
                                  'Delete',
                                  onPressed: () =>
                                      Navigator.pop(dCtx, 'delete'),
                                  variant: OctoButtonVariant.danger,
                                ),
                              ),
                            ],
                          );
                          setState(() => _dialogResult = result ?? 'dismissed');
                        },
                      ),
                      SizedBox(height: theme.spacing.gap.sm),
                      OctoText(
                        _dialogResult == null
                            ? 'No result yet.'
                            : 'Last result: $_dialogResult',
                        kind: OctoTextKind.bodySmall,
                        color: theme.colors.fg.muted,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Command palette — ⌘K from anywhere',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OctoButton.label(
                        'Open command palette',
                        leadingIcon: const Icon(OctIcons.search_16),
                        onPressed: widget.onOpenPalette,
                        variant: OctoButtonVariant.primary,
                      ),
                      SizedBox(width: theme.spacing.gap.md),
                      Flexible(
                        child: OctoText(
                          'Or press ⌘K from anywhere on the page.',
                          kind: OctoTextKind.bodySmall,
                          color: theme.colors.fg.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OctoText(title, kind: OctoTextKind.heading),
          SizedBox(height: theme.spacing.gap.md),
          Container(
            padding: EdgeInsets.all(theme.spacing.gap.lg),
            decoration: BoxDecoration(
              color: theme.colors.canvas.subtle,
              border: Border.all(color: theme.colors.border.defaultColor),
              borderRadius:
                  BorderRadius.all(Radius.circular(theme.radii.medium)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
