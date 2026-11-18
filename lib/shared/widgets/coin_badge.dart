import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';

class CoinBadge extends StatelessWidget {
  const CoinBadge(this.amount, {super.key, this.size = 28, this.showPlus = false});
  final int amount;
  final double size;
  final bool showPlus;

  static String formatAmount(int amount) {
    final negative = amount < 0;
    final digits = amount.abs().toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final position = digits.length - i;
      out.write(digits[i]);
      if (position > 1 && position % 3 == 1) out.write('.');
    }
    return '${negative ? '-' : ''}${out.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final extras = Theme.of(context).extension<AppThemeExtras>()!;
    final formatted = '${showPlus ? '+' : ''}${formatAmount(amount)}';
    return Semantics(label: '$formatted monete', child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.cheese, shape: BoxShape.circle, border: Border.all(color: extras.outline, width: AppStroke.base)),
        child: FittedBox(child: Text(showPlus ? '+' : 'C', style: AppText.label.copyWith(color: AppColors.espresso))),
      ),
      const SizedBox(width: AppSpace.xxs),
      Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(formatted, style: AppText.label.copyWith(fontWeight: FontWeight.w700))))
    ]));
  }
}
