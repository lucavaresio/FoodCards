import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';

enum StatType { health, attack, defense, speed }

extension StatTypeX on StatType {
  String get label => switch (this) { StatType.health => 'Vita', StatType.attack => 'Forza', StatType.defense => 'Difesa', StatType.speed => 'Velocità' };
  Color get color => switch (this) { StatType.health => AppColors.vita, StatType.attack => AppColors.forza, StatType.defense => AppColors.difesa, StatType.speed => AppColors.velocita };
  IconData get icon => switch (this) { StatType.health => Icons.favorite, StatType.attack => Icons.sports_mma, StatType.defense => Icons.shield, StatType.speed => Icons.bolt };
}

class StatIcon extends StatelessWidget {
  const StatIcon({super.key, required this.type, required this.value, this.size = 40});
  final StatType type;
  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
    return Semantics(label: '${type.label} $value', child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: type.color, shape: BoxShape.circle, border: Border.all(color: extras.outline, width: AppStroke.base)),
        child: Icon(type.icon, size: size * 0.48, color: AppColors.espresso),
      ),
      const SizedBox(width: AppSpace.xs),
      Text('$value', style: AppText.stat),
    ]));
  }
}
