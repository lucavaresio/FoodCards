import 'package:flutter/material.dart';

import '../../router/app_routes.dart';
import '../../shared/widgets/placeholder_content.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const FullscreenPlaceholderScreen(
    title: 'Impostazioni',
    parentRoute: AppRoutes.home,
  );
}
