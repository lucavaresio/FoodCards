import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    this.coins,
    this.actions = const [],
    super.key,
  });

  final String title;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final int? coins;
  final List<Widget> actions;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
    NavigationDestination(
      icon: Icon(Icons.collections_bookmark_outlined),
      label: 'Collezione',
    ),
    NavigationDestination(icon: Icon(Icons.style_outlined), label: 'Mazzi'),
    NavigationDestination(
      icon: Icon(Icons.sports_esports_outlined),
      label: 'Gioco',
    ),
    NavigationDestination(
      icon: Icon(Icons.shopping_bag_outlined),
      label: 'Negozio',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).extension<AppThemeExtras>()!.outline;
    final horizontalPadding =
        MediaQuery.sizeOf(context).width >= AppBreakpoint.tablet
        ? AppSpace.lg
        : AppSpace.md;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: body,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: outline, width: AppStroke.base),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: _destinations,
        ),
      ),
    );
  }
}
