import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/session_providers.dart';
import '../../data/repositories/collection_repository.dart';
import '../../theme/app_colors.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/sticker_button.dart';
import '../../theme/app_tokens.dart';
import 'shop_controller.dart';
import 'widgets/pack_summary_grid.dart';
import 'widgets/pack_wrapper.dart';
import 'widgets/reveal_stage.dart';

class PackOpeningScreen extends ConsumerStatefulWidget {
  const PackOpeningScreen({super.key});

  @override
  ConsumerState<PackOpeningScreen> createState() => _PackOpeningScreenState();
}

class _PackOpeningScreenState extends ConsumerState<PackOpeningScreen> {
  int _index = 0;
  bool _packOpened = false;
  bool _summary = false;
  bool _tearing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(pendingPackOpeningProvider) == null) {
        context.go(AppRoutes.shop);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(pendingPackOpeningProvider);
    if (result == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_summary ? 'Pacchetto aperto' : result.pack.name),
          leading: IconButton(
            tooltip: 'Torna allo shop',
            icon: const Icon(Icons.close),
            onPressed: _finish,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.md),
            child: _summary
                ? _buildSummary(context, result)
                : _buildReveal(context, result),
          ),
        ),
      ),
    );
  }

  Widget _buildReveal(BuildContext context, result) {
    final card = result.cards[_index];
    return Column(
      children: [
        Expanded(
          child: Center(
            child: _packOpened
                ? RevealStage(
                    card: card,
                    revealed: true,
                    isNew: result.newCardIds.contains(card.id),
                    onTap: _advance,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      PackWrapper(
                        pack: result.pack,
                        shaking: _tearing,
                        onTap: _tearing ? null : _onPackTear,
                      ),
                      IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _tearing ? 1 : 0,
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? AppDuration.base
                              : AppDuration.fast,
                          child: const ColoredBox(
                            color: AppColors.cheese,
                            child: SizedBox.expand(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        Text('Carta ${_index + 1} di ${result.cards.length}'),
        const SizedBox(height: AppSpace.sm),
        Text(
          !_packOpened
              ? 'Tocca il pacco per aprirlo'
              : _index + 1 == result.cards.length
              ? 'Tocca la carta per vedere il riepilogo'
              : 'Tocca la carta per continuare',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, result) {
    final coins = ref.watch(coinsProvider) ?? 0;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Ecco le tue carte!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpace.md),
                PackSummaryGrid(
                  cards: result.cards,
                  newCardIds: result.newCardIds,
                ),
              ],
            ),
          ),
        ),
        if (coins >= result.pack.cost) ...[
          const SizedBox(height: AppSpace.sm),
          StickerButton(label: 'APRI ANCORA', onPressed: _buyAgain),
        ],
        const SizedBox(height: AppSpace.xs),
        TextButton(onPressed: _finish, child: const Text('FINE')),
      ],
    );
  }

  void _advance() {
    final result = ref.read(pendingPackOpeningProvider);
    if (result == null) return;
    setState(() {
      if (_index + 1 >= result.cards.length) {
        _summary = true;
      } else {
        _index++;
      }
    });
  }

  Future<void> _onPackTear() async {
    setState(() => _tearing = true);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? AppDuration.base
        : AppDuration.splash;
    await Future<void>.delayed(duration);
    if (!mounted) return;
    setState(() {
      _tearing = false;
      _packOpened = true;
    });
  }

  Future<void> _buyAgain() async {
    final result = ref.read(pendingPackOpeningProvider);
    if (result == null) return;
    try {
      await ref.read(shopControllerProvider.notifier).buy(result.pack.id);
      if (!mounted) return;
      setState(() {
        _index = 0;
        _packOpened = false;
        _summary = false;
      });
    } on InsufficientCoins {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Monete insufficienti')));
    }
  }

  void _finish() {
    ref.read(pendingPackOpeningProvider.notifier).clear();
    context.go(AppRoutes.shop);
  }
}
