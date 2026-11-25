import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/session_providers.dart';
import '../shared/widgets/sticker_button.dart';
import '../shared/widgets/sticker_cards.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readiness = ref.watch(appReadyProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  image: true,
                  label: 'Logo FoodCards',
                  child: Image.asset(
                    'assets/images/logo/logo_foodcards.png',
                    width: AppSpace.xxxl * 2,
                    height: AppSpace.xxxl * 2,
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                if (readiness.hasError) ...[
                  StickerCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          'Impossibile caricare la sessione. Riprova.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: AppSpace.md),
                        StickerButton(
                          label: 'RIPROVA',
                          onPressed: () {
                            ref.invalidate(sessionProvider);
                            ref.invalidate(playerCollectionProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                ] else
                  Semantics(
                    label: 'Verifica della sessione',
                    child: CircularProgressIndicator(
                      color: AppColors.tomatoAction,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
