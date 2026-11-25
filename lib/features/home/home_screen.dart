import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/game_constants.dart';
import '../../data/session_providers.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../shared/widgets/sticker_cards.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'daily_pack_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _dailyRewardTimer;

  @override
  void initState() {
    super.initState();
    _scheduleDailyRewardRefresh();
  }

  @override
  void dispose() {
    _dailyRewardTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final uid = session.value?.uid;
    return AppScaffold(
      title: 'Home',
      currentIndex: 0,
      coins: ref.watch(coinsProvider),
      actions: [
        IconButton(
          tooltip: 'Impostazioni e profilo',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
      onDestinationSelected: (index) => context.go(AppRoutes.tabAt(index)),
      body: session.isLoading
          ? Center(
              child: Semantics(
                label: 'Caricamento del profilo',
                child: CircularProgressIndicator(),
              ),
            )
          : session.hasError
          ? _HomeMessage(
              icon: Icons.error_outline,
              title: 'Sessione non disponibile',
              message: 'Ricarica l’app e riprova.',
              isError: true,
            )
          : uid == null
          ? _HomeMessage(
              icon: Icons.lock_outline,
              title: 'Accedi per continuare',
              message: 'Il tuo profilo e i tuoi progressi ti aspettano.',
              action: StickerButton(
                label: 'Accedi',
                onPressed: () => context.go(AppRoutes.login),
              ),
            )
          : _dashboard(context, ref, uid, session.value!.displayName),
    );
  }

  void _scheduleDailyRewardRefresh() {
    final now = DateTime.now().toUtc();
    final nextDay = DateTime.utc(now.year, now.month, now.day + 1);
    _dailyRewardTimer = Timer(nextDay.difference(now), () {
      if (!mounted) return;
      ref.invalidate(playerCollectionProvider);
      _scheduleDailyRewardRefresh();
    });
  }

  Widget _dashboard(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String displayName,
  ) {
    final collection = ref.watch(playerCollectionProvider);
    final stats = ref.watch(playerGameStatsProvider(uid));
    if (collection.isLoading || stats.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (collection.hasError || stats.hasError) {
      return _HomeMessage(
        icon: Icons.error_outline,
        title: 'Dati non disponibili',
        message: 'Non è stato possibile caricare il tuo profilo.',
        isError: true,
        action: StickerButton(
          label: 'Riprova',
          icon: Icons.refresh,
          onPressed: () {
            ref.invalidate(playerCollectionProvider);
            ref.invalidate(playerGameStatsProvider(uid));
          },
        ),
      );
    }

    final player = collection.value!;
    final record = stats.value!;
    final isClaiming = ref.watch(dailyPackControllerProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.authFormMaxWidth),
        child: ListView(
          children: [
            Text(
              'Ciao, $displayName!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpace.md),
            StickerCard(
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard, size: AppSpace.xxl),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Regalo giornaliero',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Ritira ${GameConstants.dailyFreeCardCount} carte gratuite ogni giorno.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpace.md),
                  StickerButton(
                    label: player.dailyRewardClaimed
                        ? 'Già ritirato oggi'
                        : 'Ritira il regalo',
                    icon: player.dailyRewardClaimed
                        ? Icons.check_circle_outline
                        : Icons.redeem,
                    isLoading: isClaiming,
                    onPressed: player.dailyRewardClaimed || isClaiming
                        ? null
                        : () => _claimDailyPack(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.md),
            StickerCard(
              child: Semantics(
                container: true,
                label:
                    'Statistiche profilo: ${player.owned.length} carte uniche, '
                    '${record.matchesPlayed} partite, ${record.wins} vittorie',
                child: Column(
                  children: [
                    Text(
                      'Il tuo profilo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ProfileValue(
                          label: 'Carte uniche',
                          value: player.owned.length,
                        ),
                        _ProfileValue(
                          label: 'Partite',
                          value: record.matchesPlayed,
                        ),
                        _ProfileValue(label: 'Vittorie', value: record.wins),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpace.xs,
              runSpacing: AppSpace.xs,
              children: [
                _HomeLink(
                  label: 'Collezione',
                  onPressed: () => context.go(AppRoutes.collection),
                ),
                _HomeLink(
                  label: 'I miei mazzi',
                  onPressed: () => context.go(AppRoutes.deck),
                ),
                _HomeLink(
                  label: 'Gioca',
                  onPressed: () => context.go(AppRoutes.game),
                ),
                _HomeLink(
                  label: 'Negozio',
                  onPressed: () => context.go(AppRoutes.shop),
                ),
                _HomeLink(
                  label: 'Ricettario',
                  onPressed: () => context.push(AppRoutes.recipes),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _claimDailyPack(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(dailyPackControllerProvider.notifier).claim();
      if (!context.mounted) return;
      context.push(AppRoutes.packOpening);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: AppSpace.xs),
              Expanded(child: Text('Premio non disponibile: $error')),
            ],
          ),
        ),
      );
    }
  }
}

class _ProfileValue extends StatelessWidget {
  const _ProfileValue({required this.label, required this.value});

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

class _HomeLink extends StatelessWidget {
  const _HomeLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: onPressed, child: Text(label));
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isError;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: StickerCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpace.xxl,
            color: isError ? AppColors.error : null,
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpace.xs),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: AppSpace.lg), action!],
        ],
      ),
    ),
  );
}
