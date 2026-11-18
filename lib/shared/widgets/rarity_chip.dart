import 'package:flutter/material.dart';

import '../../data/models/rarity.dart';
import '../../theme/app_colors.dart';
import 'sticker_chip.dart';

class RarityChip extends StatelessWidget {
  const RarityChip({super.key, required this.rarity, required this.selected, this.onTap}) : all = false;

  const RarityChip.all({super.key, required this.selected, this.onTap})
      : rarity = Rarity.common,
        all = true;

  final Rarity rarity;
  final bool selected;
  final VoidCallback? onTap;
  final bool all;

  @override
  Widget build(BuildContext context) {
    return StickerChip(
      label: all ? 'Tutte' : rarity.label,
      color: all ? AppColors.cheese : rarity.color,
      selected: selected,
      onTap: onTap,
    );
  }
}
