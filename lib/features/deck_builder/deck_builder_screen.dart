import 'package:flutter/material.dart';

import '../../shared/widgets/placeholder_content.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({this.isEditing = false, super.key});

  final bool isEditing;

  @override
  Widget build(BuildContext context) => TabPlaceholderScreen(
    title: isEditing ? 'Modifica mazzo' : 'Mazzi',
    currentIndex: 2,
  );
}
