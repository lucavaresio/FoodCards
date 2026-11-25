import 'package:flutter/material.dart';

import '../../../data/models/card_pack.dart';
import '../../../shared/widgets/coin_badge.dart';
import '../../../theme/app_tokens.dart';

class PackTile extends StatelessWidget {
  const PackTile({
    required this.pack,
    required this.coins,
    required this.onOpen,
    required this.onRates,
    this.busy = false,
    super.key,
  });

  final CardPack pack;
  final int coins;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onRates;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).extension<AppThemeExtras>()!.outline;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.md),
      padding: const EdgeInsets.all(AppSpace.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: outline, width: AppStroke.base),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: stickerShadow(outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSpace.xxxl,
            height: AppSpace.xxxl,
            child: Image.asset(pack.imageAsset, fit: BoxFit.contain),
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pack.name, style: Theme.of(context).textTheme.titleMedium),
                Text('${pack.level} · ${pack.cardCount} carte'),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: AppSpace.sm,
                      color: pack.highestLikelyRarity.color,
                    ),
                    const SizedBox(width: AppSpace.xxs),
                    Text(pack.highestLikelyRarity.label),
                  ],
                ),
                CoinBadge(coins: pack.cost),
                TextButton(
                  onPressed: onRates,
                  child: const Text('Probabilità'),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          Semantics(
            label: coins < pack.cost
                ? 'Monete insufficienti per ${pack.name}'
                : 'Apri ${pack.name}',
            child: FilledButton.tonal(
              onPressed: busy ? null : onOpen,
              child: const Text('APRI'),
            ),
          ),
        ],
      ),
    );
  }
}
