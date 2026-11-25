import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/session_providers.dart';
import '../../theme/app_tokens.dart';

class DevToolsSheet extends ConsumerWidget {
  const DevToolsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return const SizedBox.shrink();
    final catalog = ref.watch(cardRepositoryProvider).value;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Strumenti di sviluppo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpace.sm),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(playerCollectionProvider.notifier).addCoins(500);
              },
              icon: const Icon(Icons.monetization_on_outlined),
              label: const Text('+500 monete'),
            ),
            OutlinedButton.icon(
              onPressed: catalog == null
                  ? null
                  : () async {
                      final cards = catalog.all;
                      final random = Random();
                      final ids = List.generate(
                        10,
                        (_) => cards[random.nextInt(cards.length)].id,
                      );
                      await ref
                          .read(playerCollectionProvider.notifier)
                          .addCards(ids);
                    },
              icon: const Icon(Icons.style_outlined),
              label: const Text('Aggiungi 10 carte casuali'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                await ref
                    .read(playerCollectionProvider.notifier)
                    .clearOwnedCards();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Azzera collezione'),
            ),
          ],
        ),
      ),
    );
  }
}
