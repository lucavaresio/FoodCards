import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final value = ref.watch(sharedPreferencesProvider).getString('theme_mode');
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    final saved = await ref
        .read(sharedPreferencesProvider)
        .setString('theme_mode', mode.name);
    if (!saved) throw StateError('Impossibile salvare la modalità tema');
    if (ref.mounted) state = mode;
  }
}
