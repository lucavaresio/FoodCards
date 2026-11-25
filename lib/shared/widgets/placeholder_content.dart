import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../theme/app_text.dart';
import '../../theme/app_tokens.dart';
import 'app_scaffold.dart';
import 'sticker_button.dart';
import 'sticker_cards.dart';

class TabPlaceholderScreen extends StatelessWidget {
  const TabPlaceholderScreen({
    required this.title,
    required this.currentIndex,
    super.key,
  });

  final String title;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      currentIndex: currentIndex,
      onDestinationSelected: (index) => context.go(AppRoutes.tabAt(index)),
      body: _PlaceholderCard(title: title),
    );
  }
}

class FullscreenPlaceholderScreen extends StatelessWidget {
  const FullscreenPlaceholderScreen({
    required this.title,
    required this.parentRoute,
    super.key,
  });

  final String title;
  final String parentRoute;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: GoRouter.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(parentRoute);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
            child: _PlaceholderCard(title: title),
          ),
        ),
      ),
    );
  }
}

class StandalonePlaceholderScreen extends StatelessWidget {
  const StandalonePlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Center(child: _PlaceholderCard(title: title)),
      ),
    ),
  );
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: '$title. In arrivo',
        child: StickerCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                'In arrivo',
                textAlign: TextAlign.center,
                style: AppText.bodyL.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: StickerCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: AppSpace.xxxl,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    'Pagina non trovata',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  StickerButton(
                    label: 'Torna alla Home',
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
