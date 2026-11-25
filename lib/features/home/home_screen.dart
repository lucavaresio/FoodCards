import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../shared/widgets/placeholder_content.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_error_messages.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TabPlaceholderScreen(
    title: 'Home',
    currentIndex: 0,
    actions: [
      IconButton(
        tooltip: 'Esci',
        icon: const Icon(Icons.logout),
        onPressed: () async {
          try {
            await ref.read(authControllerProvider.notifier).signOut();
          } catch (error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: AppSpace.xs),
                    Expanded(child: Text(authErrorMessage(error))),
                  ],
                ),
              ),
            );
          }
        },
      ),
    ],
  );
}
