import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_cards/data/local/storage_service.dart';
import 'package:food_cards/data/repositories/collection_repository.dart';
import 'package:food_cards/data/providers.dart';
import 'package:food_cards/theme/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'il regalo giornaliero è unico per giorno UTC e persiste le carte',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final repository = CollectionRepository(
        StorageService(preferences, uid: 'daily-user'),
      );
      await repository.initializeForNewUser();
      final claimDate = DateTime.utc(2025, 6, 12, 23, 30);

      expect(repository.hasClaimedDailyRewardAt(claimDate), isFalse);
      await repository.claimDailyReward(['apple', 'bread'], at: claimDate);
      expect(repository.quantityOf('apple'), 1);
      expect(repository.quantityOf('bread'), 1);
      expect(repository.hasClaimedDailyRewardAt(claimDate), isTrue);
      await expectLater(
        repository.claimDailyReward(['apple'], at: claimDate),
        throwsStateError,
      );

      final sameUtcDay = DateTime.parse('2025-06-13T01:00:00+02:00');
      expect(repository.hasClaimedDailyRewardAt(sameUtcDay), isTrue);
      final nextDay = DateTime.utc(2025, 6, 13);
      expect(repository.hasClaimedDailyRewardAt(nextDay), isFalse);

      final reloaded = CollectionRepository(
        StorageService(preferences, uid: 'daily-user'),
      );
      await reloaded.load();
      expect(reloaded.hasClaimedDailyRewardAt(claimDate), isTrue);
      expect(reloaded.quantityOf('apple'), 1);
    },
  );

  test('la modalità tema viene salvata e ripristinata', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final first = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    expect(first.read(themeModeProvider), ThemeMode.system);
    await first.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    expect(first.read(themeModeProvider), ThemeMode.dark);
    first.dispose();

    final restored = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(restored.dispose);
    expect(restored.read(themeModeProvider), ThemeMode.dark);
  });
}
