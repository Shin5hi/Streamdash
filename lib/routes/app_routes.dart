import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/sign_up_login_screen/sign_up_login_screen.dart';
import '../presentation/stream_dashboard_screen/stream_dashboard_screen.dart';
import '../presentation/twitch_dashboard_screen/twitch_dashboard_screen.dart';
import '../widgets/app_scaffold.dart';
import '../presentation/bot_settings_screen/bot_settings_screen.dart';
import '../presentation/yt_live_chat_screen/yt_live_chat_screen.dart';
import '../presentation/yt_analytics_screen/yt_analytics_screen.dart';
import '../presentation/yt_channel_connect_screen/yt_channel_connect_screen.dart';
import '../presentation/streamer_account_screen/streamer_account_screen.dart';
import '../presentation/stream_history_screen/stream_history_screen.dart';
import '../presentation/twitch_live_chat_screen/twitch_live_chat_screen.dart';
import '../presentation/twitch_analytics_screen/twitch_analytics_screen.dart';
import '../presentation/twitch_channel_connect_screen/twitch_channel_connect_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String streamDashboardScreen = '/stream-dashboard-screen';
  static const String signUpLoginScreen = '/sign-up-login-screen';
  static const String botSettingsScreen = '/bot-settings-screen';
  static const String ytLiveChatScreen = '/yt-live-chat';
  static const String ytAnalyticsScreen = '/yt-analytics';
  static const String ytChannelConnectScreen = '/yt-channel-connect';
  static const String streamerAccountScreen = '/streamer-account';
  static const String streamHistoryScreen = '/stream-history';
  // Twitch routes
  static const String twitchDashboardScreen = '/twitch-dashboard';
  static const String twitchLiveChatScreen = '/twitch-live-chat';
  static const String twitchAnalyticsScreen = '/twitch-analytics';
  static const String twitchChannelConnectScreen = '/twitch-channel-connect';
}

GoRouter buildRouter(bool isLoggedIn) {
  return GoRouter(
    initialLocation: isLoggedIn
        ? AppRoutes.streamDashboardScreen
        : AppRoutes.initial,
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpLoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 280),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.streamDashboardScreen,
                builder: (context, state) => const StreamDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.twitchDashboardScreen,
                builder: (context, state) => const TwitchDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.botSettingsScreen,
                builder: (context, state) => const BotSettingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.streamerAccountScreen,
                builder: (context, state) => const StreamerAccountScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.streamHistoryScreen,
                builder: (context, state) => const StreamHistoryScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.signUpLoginScreen,
        builder: (context, state) => const SignUpLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.ytLiveChatScreen,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const YtLiveChatScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: AppRoutes.ytAnalyticsScreen,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const YtAnalyticsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: AppRoutes.ytChannelConnectScreen,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const YtChannelConnectScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 320),
        ),
      ),
      GoRoute(
        path: AppRoutes.twitchLiveChatScreen,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TwitchLiveChatScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: AppRoutes.twitchAnalyticsScreen,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TwitchAnalyticsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: AppRoutes.twitchChannelConnectScreen,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TwitchChannelConnectScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 320),
        ),
      ),
    ],
  );
}

// Keep backward-compatible appRouter for any existing references
final GoRouter appRouter = buildRouter(false);
