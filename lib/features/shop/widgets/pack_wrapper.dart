import 'package:flutter/material.dart';

import '../../../data/models/card_pack.dart';
import '../../../theme/app_tokens.dart';

class PackWrapper extends StatelessWidget {
  const PackWrapper({
    required this.pack,
    this.onTap,
    this.shaking = false,
    super.key,
  });

  final CardPack pack;
  final VoidCallback? onTap;
  final bool shaking;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: 'Pacchetto ${pack.name}',
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedRotation(
        turns: shaking ? 0.025 : 0,
        duration: MediaQuery.disableAnimationsOf(context)
            ? AppDuration.base
            : AppDuration.splash,
        child: AnimatedContainer(
          duration: AppDuration.slow,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: stickerShadow(
              Theme.of(context).extension<AppThemeExtras>()!.outline,
            ),
          ),
          child: Image.asset(pack.imageAsset, fit: BoxFit.contain),
        ),
      ),
    ),
  );
}
