import 'package:flutter/material.dart';

import '../../../data/models/card_pack.dart';
import '../../../theme/app_tokens.dart';

class DropRatesSheet extends StatelessWidget {
  const DropRatesSheet({required this.pack, super.key});

  final CardPack pack;

  @override
  Widget build(BuildContext context) {
    final total = pack.dropRates.values.fold<double>(0, (a, b) => a + b);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Probabilità · ${pack.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final rarity in pack.dropRates.keys)
              ListTile(
                leading: Icon(Icons.circle, color: rarity.color),
                title: Text(rarity.label),
                trailing: Text(
                  '${((pack.dropRates[rarity]! / total) * 100).toStringAsFixed(1)}%',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
