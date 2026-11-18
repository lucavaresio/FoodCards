import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import 'coin_badge.dart';

enum StickerButtonVariant { primary, secondary, neutral }

class StickerButton extends StatefulWidget {
  const StickerButton({super.key, required this.label, this.onPressed, this.variant = StickerButtonVariant.primary, this.compact = false, this.cost, this.isLoading = false, this.expanded = true, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final StickerButtonVariant variant;
  final bool compact;
  final int? cost;
  final bool isLoading;
  final bool expanded;
  final IconData? icon;

  @override
  State<StickerButton> createState() => _StickerButtonState();
}

class _StickerButtonState extends State<StickerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
    final enabled = widget.onPressed != null && !widget.isLoading;
    final (fill, foreground) = switch (widget.variant) {
      StickerButtonVariant.primary => (AppColors.tomatoAction, AppColors.cream),
      StickerButtonVariant.secondary => (AppColors.cheese, AppColors.espresso),
      StickerButtonVariant.neutral => (Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.onSurface),
    };
    final effectiveFill = enabled ? fill : fill.withValues(alpha: 0.55);
    final height = widget.compact ? 40.0 : 52.0;
    final shadowOffset = enabled && !_pressed ? AppShadowOffset.base : 0.0;

    final content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: AppStroke.base, color: foreground))
        else ...[
          if (widget.icon != null) ...[Icon(widget.icon, size: 20, color: foreground), const SizedBox(width: AppSpace.xs)],
          Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(widget.label.toUpperCase(), style: AppText.button.copyWith(color: foreground)))),
          if (widget.cost != null) ...[const SizedBox(width: AppSpace.xs), CoinBadge(widget.cost!, size: 24)],
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.isLoading ? '${widget.label}, caricamento in corso' : widget.label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTap: enabled ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : AppDuration.fast,
            transform: Matrix4.translationValues(0, enabled && _pressed ? AppShadowOffset.base : 0, 0),
            height: height,
            width: widget.expanded ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
            decoration: BoxDecoration(
              color: effectiveFill,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: extras.outline, width: AppStroke.base),
              boxShadow: shadowOffset == 0 ? null : stickerShadow(extras.outline, offset: shadowOffset),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
