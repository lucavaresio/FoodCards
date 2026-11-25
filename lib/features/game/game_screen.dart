import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_content.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const TabPlaceholderScreen(title: 'Gioco', currentIndex: 3);
}
