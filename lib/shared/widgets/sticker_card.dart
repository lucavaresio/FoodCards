import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class StickerCard extends StatefulWidget {
  const StickerCard({super.key, required this.child, this.onTap, this.padding, this.radius, this.color});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? color;

  @override
  State<StickerCard> createState() => _StickerCardState();
}

class _StickerCardState extends State<StickerCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
    final enabled = widget.onTap != null;
    final radius = widget.radius ?? AppRadius.card;

    return Semantics(
      button: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : AppDuration.fast,
          transform: Matrix4.translationValues(0, enabled && _pressed ? 3 : 0, 0),
          padding: widget.padding ?? const EdgeInsets.all(AppSpace.md),
          decoration: BoxDecoration(
            color: widget.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: extras.outline, width: AppStroke.base),
            boxShadow: enabled && !_pressed ? stickerShadow(extras.outline, offset: AppShadowOffset.sm) : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
