import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/session_providers.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/collection/collection_screen.dart';
import '../features/deck_builder/deck_builder_screen.dart';
import '../features/deck_builder/deck_edit_screen.dart';
import '../features/game/game_screen.dart';
import '../features/game/match_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shop/pack_opening_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/splash_screen.dart';
import '../shared/widgets/placeholder_content.dart';
import '../theme/app_tokens.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);
  final router = createAppRouter(
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final readiness = ref.read(appReadyProvider);
      if (readiness.isLoading || readiness.hasError) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final user = ref.read(sessionProvider).value;
      const publicRoutes = {
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      };
      if (user == null) {
        return publicRoutes.contains(path) ? null : AppRoutes.login;
      }
      if (path == AppRoutes.splash || publicRoutes.contains(path)) {
        return AppRoutes.home;
      }
      return null;
    },
  );
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createAppRouter({
  String initialLocation = AppRoutes.splash,
  Listenable? refreshListenable,
  GoRouterRedirect? redirect,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: refreshListenable,
    redirect: redirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.collection,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const CollectionScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.deck,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const DeckBuilderScreen(),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.deckEditSegment,
                    pageBuilder: (context, state) => NoTransitionPage<void>(
                      key: state.pageKey,
                      child: DeckEditScreen(
                        deckId: state.pathParameters['deckId']!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.game,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const GameScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shop,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const ShopScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.packOpening,
        pageBuilder: (context, state) =>
            _transitionPage(context, state, const PackOpeningScreen()),
      ),
      GoRoute(
        path: AppRoutes.match,
        pageBuilder: (context, state) =>
            _transitionPage(context, state, const MatchScreen()),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) =>
            _transitionPage(context, state, const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) =>
            _transitionPage(context, state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) =>
            _transitionPage(context, state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) =>
            _transitionPage(context, state, const ForgotPasswordScreen()),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.gallery,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const GalleryScreen(),
          ),
        ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}

CustomTransitionPage<void> _transitionPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  final duration = MediaQuery.disableAnimationsOf(context)
      ? AppDuration.base
      : AppDuration.slow;

  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
