// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import 'features/theme_preview_screen.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodCards',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const ThemePreviewScreen(),
    );
  }
}
