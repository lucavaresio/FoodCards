import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class StickerButton extends StatefulWidget {
  const StickerButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

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
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: duration,
        constraints: const BoxConstraints(minHeight: 48),
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
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
