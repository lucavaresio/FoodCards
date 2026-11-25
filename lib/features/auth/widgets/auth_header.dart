import 'package:flutter/material.dart';

import '../../../theme/app_text.dart';
import '../../../theme/app_tokens.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Semantics(
        image: true,
        label: 'Logo FoodCards',
        child: Image.asset(
          'assets/images/logo/logo_foodcards.png',
          width: AppSpace.xxxl * 2,
          height: AppSpace.xxxl * 2,
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(height: AppSpace.md),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      if (subtitle != null) ...[
        const SizedBox(height: AppSpace.xs),
        Text(
          subtitle!,
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    ],
  );
}
