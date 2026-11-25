import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class StickerButton extends StatefulWidget {
  const StickerButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  State<StickerButton> createState() => _StickerButtonState();
}

class _StickerButtonState extends State<StickerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.extension<AppThemeExtras>()!.outline;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? AppDuration.base
        : AppDuration.fast;

    return GestureDetector(
      excludeFromSemantics: true,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: Semantics(
        button: true,
        enabled: widget.onPressed != null,
        label: widget.label,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: duration,
          constraints: const BoxConstraints(minHeight: AppTapTarget.minimum),
          transform: Matrix4.translationValues(
            0,
            _pressed ? AppShadowOffset.base : 0,
            0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: AppSpace.sm,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: outline, width: AppStroke.base),
            boxShadow: _pressed
                ? const []
                : stickerShadow(outline, offset: AppShadowOffset.base),
          ),
          child: Center(
            child: widget.isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: AppSpace.lg,
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.onPrimary,
                          strokeWidth: AppStroke.thin,
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      Text(
                        widget.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: theme.colorScheme.onPrimary),
                        const SizedBox(width: AppSpace.xs),
                      ],
                      Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
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
