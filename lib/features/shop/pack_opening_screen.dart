import 'package:flutter/material.dart';

import '../../router/app_routes.dart';
import '../../shared/widgets/placeholder_content.dart';

class PackOpeningScreen extends StatelessWidget {
  const PackOpeningScreen({super.key});

  @override
  Widget build(BuildContext context) => const FullscreenPlaceholderScreen(
    title: 'Apertura pacchetto',
    parentRoute: AppRoutes.shop,
  );
}
