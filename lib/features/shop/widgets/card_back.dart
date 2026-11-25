import 'package:flutter/material.dart';

import '../../../shared/widgets/sticker_cards.dart';
import '../../../theme/app_tokens.dart';

class CardBack extends StatelessWidget {
  const CardBack({super.key});

  @override
  Widget build(BuildContext context) => StickerCard(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo/logo_foodcards.png',
          height: AppSpace.xxxl,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpace.xs),
        Text('FOOD CARDS', style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}
