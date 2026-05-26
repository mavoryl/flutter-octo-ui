import 'package:flutter/widgets.dart';

import 'package:octo_ui/src/components/button/octo_button.dart';
import 'package:octo_ui/src/foundation/octo_icon.dart';

/// Square icon-only button. Composition over [OctoButton]: same state
/// machine, focus, keyboard activation, theming — but with square geometry
/// and a single icon child.
///
/// `semanticLabel` is required (ADR-0008): a bare icon is meaningless to
/// screen-readers without an explicit description.
class OctoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final OctoButtonVariant variant;
  final OctoButtonSize size;
  final bool loading;
  final String semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  const OctoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.variant = OctoButtonVariant.standard,
    this.size = OctoButtonSize.medium,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
  });

  OctoIconSize get _iconSize => switch (size) {
    OctoButtonSize.small => OctoIconSize.small,
    OctoButtonSize.medium => OctoIconSize.medium,
    OctoButtonSize.large => OctoIconSize.large,
  };

  @override
  Widget build(BuildContext context) {
    return OctoButton(
      onPressed: onPressed,
      variant: variant,
      size: size,
      loading: loading,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      // The icon needs no inner semantic label — the outer Semantics(button)
      // from OctoButton carries `semanticLabel`. Excluding the icon's
      // semantics avoids a doubled announcement.
      child: ExcludeSemantics(
        child: OctoIcon(icon, size: _iconSize),
      ),
    );
  }
}
