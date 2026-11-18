import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';

class StickerChip extends StatelessWidget {
  const StickerChip({super.key, required this.label, required this.color, required this.selected, this.onTap, this.leading});

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
    final luminance = color.computeLuminance();
    final foreground = luminance > 0.55 ? AppColors.espresso : AppColors.cream;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: AppSpace.xs),
            decoration: BoxDecoration(
              color: selected ? color : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: extras.outline, width: AppStroke.base),
              boxShadow: selected ? stickerShadow(extras.outline, offset: AppShadowOffset.sm) : null,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              leading ?? Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: extras.outline, width: 1))),
              const SizedBox(width: AppSpace.xs),
              Text(label, style: AppText.label.copyWith(color: selected ? foreground : Theme.of(context).colorScheme.onSurface)),
            ]),
          ),
        ),
      ),
    );
  }
}
