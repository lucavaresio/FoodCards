import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shared/widgets/sticker_cards.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/app_text.dart';
import 'theme/app_tokens.dart';
import 'theme/theme_mode_provider.dart';
import 'router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FoodCards',
      routerConfig: ref.watch(appRouterProvider),
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ref.watch(themeModeProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirebaseSetupErrorApp extends StatelessWidget {
  const FirebaseSetupErrorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FoodCards',
    theme: lightTheme(),
    darkTheme: darkTheme(),
    themeMode: ThemeMode.system,
    home: Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: StickerCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: AppSpace.xxxl,
                  ),
                  const SizedBox(height: AppSpace.md),
                  Text(
                    'Configurazione Firebase necessaria',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    'Esegui flutterfire configure per avviare l’app.',
                    textAlign: TextAlign.center,
                    style: AppText.bodyL.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
