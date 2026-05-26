import 'package:flutter/material.dart';
import 'package:octo_ui/octo_ui.dart';

void main() => runApp(const KitchenSinkApp());

class KitchenSinkApp extends StatefulWidget {
  const KitchenSinkApp({super.key});

  @override
  State<KitchenSinkApp> createState() => _KitchenSinkAppState();
}

class _KitchenSinkAppState extends State<KitchenSinkApp> {
  bool _dark = false;

  void _toggle() => setState(() => _dark = !_dark);

  @override
  Widget build(BuildContext context) {
    final octo = _dark ? OctoThemeData.dark() : OctoThemeData.light();
    return OctoTheme(
      data: octo,
      child: MaterialApp(
        title: 'octo_ui kitchen sink',
        debugShowCheckedModeBanner: false,
        theme: octo.toMaterialTheme(),
        home: KitchenSinkPage(isDark: _dark, onToggleTheme: _toggle),
      ),
    );
  }
}

class KitchenSinkPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const KitchenSinkPage({super.key, required this.isDark, required this.onToggleTheme});

  @override
  State<KitchenSinkPage> createState() => _KitchenSinkPageState();
}

class _KitchenSinkPageState extends State<KitchenSinkPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = OctoTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colors.canvas.defaultColor,
      appBar: AppBar(
        backgroundColor: theme.colors.canvas.subtle,
        surfaceTintColor: theme.colors.canvas.subtle,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: theme.colors.border.defaultColor)),
        title: const OctoText('octo_ui kitchen sink', kind: OctoTextKind.title),
        actions: [
          OctoIconButton(
            icon: widget.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onPressed: widget.onToggleTheme,
            variant: OctoButtonVariant.invisible,
            semanticLabel: widget.isDark ? 'Switch to light theme' : 'Switch to dark theme',
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
                  title: 'Buttons — variants',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OctoButton.label('Save', onPressed: () {}, variant: OctoButtonVariant.primary),
                      OctoButton.label('Cancel', onPressed: () {}),
                      OctoButton.label('Delete', onPressed: () {}, variant: OctoButtonVariant.danger),
                      OctoButton.label('Edit', onPressed: () {}, variant: OctoButtonVariant.invisible),
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
                      OctoButton.label('Small', onPressed: () {}, size: OctoButtonSize.small),
                      OctoButton.label('Medium', onPressed: () {}),
                      OctoButton.label('Large', onPressed: () {}, size: OctoButtonSize.large),
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
                        icon: Icons.star_outline,
                        onPressed: () {},
                        semanticLabel: 'Star',
                      ),
                      OctoIconButton(
                        icon: Icons.favorite_outline,
                        onPressed: () {},
                        variant: OctoButtonVariant.primary,
                        semanticLabel: 'Favorite',
                      ),
                      OctoIconButton(
                        icon: Icons.more_horiz,
                        onPressed: () {},
                        variant: OctoButtonVariant.invisible,
                        semanticLabel: 'More',
                      ),
                      const OctoIconButton(
                        icon: Icons.lock_outline,
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
                      OctoFlash(message: 'A new release is available.', icon: Icons.info_outline),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Changes saved successfully.',
                        variant: OctoFlashVariant.success,
                        icon: Icons.check_circle_outline,
                      ),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Review required before merge.',
                        variant: OctoFlashVariant.attention,
                        icon: Icons.error_outline,
                      ),
                      SizedBox(height: 12),
                      OctoFlash(
                        message: 'Build failed — see the logs for details.',
                        variant: OctoFlashVariant.danger,
                        icon: Icons.cancel_outlined,
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
                        onPressed: () => setState(() => _showError = !_showError),
                      ),
                      SizedBox(height: theme.spacing.gap.md),
                      const OctoTextField(placeholder: 'disabled', enabled: false),
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
              borderRadius: BorderRadius.all(Radius.circular(theme.radii.medium)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
