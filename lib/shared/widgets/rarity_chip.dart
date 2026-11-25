import 'package:flutter/material.dart';

import '../../data/models/rarity.dart';
import '../../theme/app_tokens.dart';

class RarityChip extends StatelessWidget {
  const RarityChip({
    required this.label,
    this.rarity,
    this.selected = false,
    this.onSelected,
    super.key,
  });

  final String label;
  final Rarity? rarity;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: rarity == null ? '$label, tutte le rarità' : 'Rarità $label',
    selected: selected,
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: rarity == null
          ? null
          : CircleAvatar(backgroundColor: rarity!.color, radius: AppSpace.xxs),
    ),
  );
}
