import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/game_constants.dart';
import '../../data/models/player_game_stats.dart';
import '../../data/providers.dart';
import '../../data/session_providers.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../shared/widgets/sticker_cards.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'engine/bot_player.dart';
import 'game_controller.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    return AppScaffold(
      title: 'Gioco',
      currentIndex: 3,
      coins: ref.watch(coinsProvider),
      onDestinationSelected: (index) => context.go(AppRoutes.tabAt(index)),
      body: _lobby(context, ref, uid),
    );
  }

  Widget _lobby(BuildContext context, WidgetRef ref, String? uid) {
    if (uid == null) {
      return const _LobbyMessage(
        icon: Icons.lock_outline,
        title: 'Accedi per giocare',
        message: 'La partita e le statistiche vengono salvate sul tuo profilo.',
      );
    }

    final activeDeck = ref.watch(activePlayerDeckProvider(uid));
    final catalog = ref.watch(cardRepositoryProvider);
    final stats = ref.watch(playerGameStatsProvider(uid));
    if (activeDeck.isLoading || catalog.isLoading || stats.isLoading) {
      return Center(
        child: Semantics(
          label: 'Caricamento della lobby',
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (activeDeck.hasError || catalog.hasError || stats.hasError) {
      return _LoadError(
        onRetry: () {
          ref.invalidate(activePlayerDeckProvider(uid));
          ref.invalidate(cardRepositoryProvider);
          ref.invalidate(playerGameStatsProvider(uid));
        },
      );
    }

    final deck = activeDeck.value;
    final cards = catalog.value!;
    final record = stats.value!;
    if (deck == null) {
      return _LobbyMessage(
        icon: Icons.style_outlined,
        title: 'Scegli un mazzo completo',
        message:
            'Attiva un mazzo di ${GameConstants.matchSize} carte per iniziare.',
        action: StickerButton(
          label: 'Vai ai mazzi',
          icon: Icons.arrow_forward,
          onPressed: () => context.go(AppRoutes.deck),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.authFormMaxWidth),
        child: ListView(
          shrinkWrap: true,
          children: [
            StickerCard(
              child: Column(
                children: [
                  const Icon(Icons.sports_esports_outlined, size: AppSpace.xxl),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    'Sfida il cuoco',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Mazzo attivo: ${deck.name} · ${deck.cardIds.length} carte',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  StickerButton(
                    label: 'Avvia partita',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      try {
                        final playerCards = deck.cardIds
                            .map(cards.requireById)
                            .toList(growable: false);
                        final opponentCards = BotPlayer.chooseDeck(cards.all);
                        ref
                            .read(gameControllerProvider.notifier)
                            .startMatch(
                              playerDeck: playerCards,
                              opponentDeck: opponentCards,
                            );
                        context.push(AppRoutes.match);
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: AppSpace.xs),
                                Expanded(
                                  child: Text('Impossibile iniziare: $error'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpace.sm),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.deck),
                    child: const Text('Gestisci mazzi'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            _StatsCard(stats: record),
          ],
        ),
      ),
    );
  }
}

class _LobbyMessage extends StatelessWidget {
  const _LobbyMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppLayout.authFormMaxWidth),
      child: StickerCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpace.xxl),
            const SizedBox(height: AppSpace.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpace.xs),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: AppSpace.lg),
              action!,
            ],
          ],
        ),
      ),
    ),
  );
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final PlayerGameStats stats;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label:
        'Statistiche: ${stats.matchesPlayed} partite, ${stats.wins} vittorie, ${stats.losses} sconfitte',
    child: StickerCard(
      child: Column(
        children: [
          Text(
            'Le tue statistiche',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatValue(label: 'Partite', value: stats.matchesPlayed),
              _StatValue(label: 'Vittorie', value: stats.wins),
              _StatValue(label: 'Sconfitte', value: stats.losses),
            ],
          ),
        ],
      ),
    ),
  );
}

class _StatValue extends StatelessWidget {
  const _StatValue({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: Theme.of(context).textTheme.headlineSmall),
      Text(label, textAlign: TextAlign.center),
    ],
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _LobbyMessage(
    icon: Icons.error_outline,
    title: 'Dati non disponibili',
    message: 'Non è stato possibile caricare la lobby.',
    action: StickerButton(
      label: 'Riprova',
      icon: Icons.refresh,
      onPressed: onRetry,
    ),
  );
}
