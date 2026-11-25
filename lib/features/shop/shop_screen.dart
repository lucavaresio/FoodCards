import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/game_constants.dart';
import '../../data/models/card_pack.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/session_providers.dart';
import '../../router/app_routes.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import 'shop_controller.dart';
import 'widgets/drop_rates_sheet.dart';
import 'widgets/pack_tile.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinsProvider) ?? 0;
    final busy = ref.watch(shopControllerProvider);
    final size = MediaQuery.sizeOf(context).width >= AppBreakpoint.tablet
        ? AppSpace.lg
        : AppSpace.md;
    return AppScaffold(
      title: 'Shop',
      currentIndex: 4,
      coins: coins,
      onDestinationSelected: (index) => context.go(AppRoutes.tabAt(index)),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: size),
        itemCount: GameConstants.packs.length,
        itemBuilder: (context, index) {
          final pack = GameConstants.packs[index];
          return PackTile(
            pack: pack,
            coins: coins,
            busy: busy,
            onRates: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => DropRatesSheet(pack: pack),
            ),
            onOpen: () => _confirmAndBuy(context, ref, pack),
          );
        },
      ),
    );
  }

  Future<void> _confirmAndBuy(
    BuildContext context,
    WidgetRef ref,
    CardPack pack,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Aprire il pacchetto?'),
        content: Text('Spenderai ${pack.cost} monete per ${pack.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ANNULLA'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('APRI'),
          ),
        ],
      ),
    );
    if (accepted != true || !context.mounted) return;
    try {
      await ref.read(shopControllerProvider.notifier).buy(pack.id);
      if (!context.mounted) return;
      context.go(AppRoutes.packOpening);
    } on InsufficientCoins {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: AppDuration.snackbar,
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning),
              SizedBox(width: AppSpace.xs),
              Text('Monete insufficienti'),
            ],
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile aprire il pacchetto: $error')),
      );
    }
  }
}
