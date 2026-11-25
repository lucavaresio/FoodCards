import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_content.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const TabPlaceholderScreen(title: 'Collezione', currentIndex: 1);
}
