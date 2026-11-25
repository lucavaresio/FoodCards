import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_content.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const TabPlaceholderScreen(title: 'Home', currentIndex: 0);
}
