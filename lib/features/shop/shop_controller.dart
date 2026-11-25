import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/game_constants.dart';
import '../../data/providers.dart';
import '../../data/session_providers.dart';
import 'pack_service.dart';

final pendingPackOpeningProvider =
    NotifierProvider<PendingPackOpening, PackDrawResult?>(
      PendingPackOpening.new,
    );

class PendingPackOpening extends Notifier<PackDrawResult?> {
  @override
  PackDrawResult? build() => null;

  void setResult(PackDrawResult result) => state = result;
  void clear() => state = null;
}

final shopControllerProvider = NotifierProvider<ShopController, bool>(
  ShopController.new,
);

class ShopController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<PackDrawResult> buy(String packId) async {
    if (state) throw StateError('Acquisto già in corso');
    state = true;
    try {
      final pack = GameConstants.packById(packId);
      final catalog = await ref.read(cardRepositoryProvider.future);
      final collection = ref.read(playerCollectionProvider).value;
      if (collection == null) {
        throw StateError('La collezione non è ancora caricata');
      }
      final result = PackService(
        catalog.all,
        random: Random(),
      ).drawResult(pack, owned: collection.owned);
      await ref
          .read(playerCollectionProvider.notifier)
          .purchasePack(
            pack.cost,
            result.cards.map((card) => card.id).toList(),
          );
      ref.read(pendingPackOpeningProvider.notifier).setResult(result);
      return result;
    } finally {
      state = false;
    }
  }
}
