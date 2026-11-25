import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_cards/constants/game_constants.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/data/session_providers.dart';

import '../shop/pack_service.dart';
import '../shop/shop_controller.dart';

final dailyPackControllerProvider = NotifierProvider<DailyPackController, bool>(
  DailyPackController.new,
);

class DailyPackController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<PackDrawResult> claim() async {
    if (state) throw StateError('Il premio giornaliero è già in preparazione');
    state = true;
    try {
      final collection = ref.read(playerCollectionProvider).value;
      if (collection == null) {
        throw StateError('La collezione non è ancora caricata');
      }
      if (collection.dailyRewardClaimed) {
        throw StateError('Il premio giornaliero è già stato ritirato');
      }

      final catalog = await ref.read(cardRepositoryProvider.future);
      final result = PackService(
        catalog.all,
        random: Random(),
      ).openFree(GameConstants.dailyFreePack, owned: collection.owned);
      await ref
          .read(playerCollectionProvider.notifier)
          .claimDailyReward(result.cards.map((card) => card.id).toList());
      ref.read(pendingPackOpeningProvider.notifier).setResult(result);
      return result;
    } finally {
      state = false;
    }
  }
}
