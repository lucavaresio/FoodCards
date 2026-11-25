import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

class CoinBadge extends StatelessWidget {
  const CoinBadge({required this.coins, super.key});

  final int coins;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$coins monete',
    child: Container(
      constraints: const BoxConstraints(minHeight: AppTapTarget.minimum),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.cheese,
        border: Border.all(
          color: Theme.of(context).extension<AppThemeExtras>()!.outline,
          width: AppStroke.base,
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on_outlined),
          const SizedBox(width: AppSpace.xxs),
          Text('$coins'),
        ],
      ),
    ),
  );
}
