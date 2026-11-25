import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/food_card.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/food_card_widget.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../shared/widgets/sticker_cards.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'engine/game_state.dart';
import 'game_controller.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  bool _isPlaying = false;
  Object? _error;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider);
    final canPop = GoRouter.of(context).canPop();
    return PopScope<Object?>(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.game);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Partita')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: state == null
                ? _MissingMatch(onReturn: () => context.go(AppRoutes.game))
                : _matchBody(context, state),
          ),
        ),
      ),
    );
  }

  Widget _matchBody(BuildContext context, BattleState state) {
    if (state.isComplete) return _result(context, state);

    final playerCard = state.activePlayerCard!;
    final opponentCard = state.activeOpponentCard!;
    final latestEvents = state.events.skip(
      state.events.length > 2 ? state.events.length - 2 : 0,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.authFormMaxWidth),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Round ${state.round + 1}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Combatant(
                    label: 'Tu',
                    card: playerCard,
                    health: state.playerHealth,
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: _Combatant(
                    label: 'Cuoco Bot',
                    card: opponentCard,
                    health: state.opponentHealth,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            _RoundLog(events: latestEvents.toList()),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.sm),
              _ErrorMessage(message: 'Round non salvato: $_error'),
            ],
            const SizedBox(height: AppSpace.md),
            StickerButton(
              label: _isPlaying ? 'Risoluzione in corso' : 'Risolvi round',
              icon: Icons.flash_on_outlined,
              isLoading: _isPlaying,
              onPressed: _isPlaying ? null : _playRound,
            ),
          ],
        ),
      ),
    );
  }

  Widget _result(BuildContext context, BattleState state) {
    final didWin = state.status == BattleStatus.playerWon;
    final icon = didWin ? Icons.emoji_events_outlined : Icons.replay_outlined;
    final color = didWin ? AppColors.success : AppColors.warning;
    final title = didWin ? 'Hai vinto!' : 'Partita persa';
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.authFormMaxWidth),
        child: StickerCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: title,
                child: Icon(icon, size: AppSpace.xxxl, color: color),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpace.xs),
              Text('Round giocati: ${state.round}'),
              const SizedBox(height: AppSpace.lg),
              StickerButton(
                label: 'Torna alla lobby',
                icon: Icons.arrow_back,
                onPressed: () {
                  ref.read(gameControllerProvider.notifier).abandonMatch();
                  context.go(AppRoutes.game);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playRound() async {
    setState(() {
      _isPlaying = true;
      _error = null;
    });
    try {
      await ref.read(gameControllerProvider.notifier).playRound();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }
}

class _Combatant extends StatelessWidget {
  const _Combatant({
    required this.label,
    required this.card,
    required this.health,
  });

  final String label;
  final FoodCard card;
  final int health;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: AppSpace.xs),
      AspectRatio(
        aspectRatio: AppLayout.collectionCardAspectRatio,
        child: FoodCardWidget(card: card, quantity: 1),
      ),
      const SizedBox(height: AppSpace.xs),
      Semantics(
        label: '${card.name}: $health punti vita',
        child: Text(
          'Vita: $health',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    ],
  );
}

class _RoundLog extends StatelessWidget {
  const _RoundLog({required this.events});

  final List<BattleEvent> events;

  @override
  Widget build(BuildContext context) => StickerCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ultimi attacchi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpace.xs),
        if (events.isEmpty)
          const Text('Risolvi il round per vedere gli attacchi.')
        else
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.xxs),
              child: Semantics(
                label:
                    '${event.attacker == BattleSide.player ? 'Tu' : 'Cuoco Bot'}: '
                    '${event.attackerCardId} attacca ${event.targetCardId}, '
                    '${event.damage} danni${event.knockedOut ? ', carta sconfitta' : ''}',
                child: Text(
                  '${event.attacker == BattleSide.player ? 'Tu' : 'Cuoco Bot'}: '
                  '${event.damage} danni'
                  '${event.knockedOut ? ' · carta sconfitta' : ''}',
                ),
              ),
            ),
      ],
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error),
        const SizedBox(width: AppSpace.xs),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _MissingMatch extends StatelessWidget {
  const _MissingMatch({required this.onReturn});

  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) => Center(
    child: StickerCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: AppSpace.xxl),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Nessuna partita attiva',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpace.lg),
          StickerButton(label: 'Torna alla lobby', onPressed: onReturn),
        ],
      ),
    ),
  );
}
