import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class StickerCard extends StatelessWidget {
  const StickerCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.extension<AppThemeExtras>()!.outline;

    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: outline, width: AppStroke.base),
        boxShadow: stickerShadow(outline, offset: AppShadowOffset.base),
      ),
      child: child,
    );
  }
}
