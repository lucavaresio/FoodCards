import 'package:flutter/material.dart';

import '../../router/app_routes.dart';
import '../../shared/widgets/placeholder_content.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) => const FullscreenPlaceholderScreen(
    title: 'Partita',
    parentRoute: AppRoutes.game,
  );
}
