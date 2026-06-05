import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/pages/app_shell.dart';
import 'package:mobile/pages/activity_screen.dart';
import 'package:mobile/pages/dashboard_screen.dart';
import 'package:mobile/pages/login_screen.dart';
import 'package:mobile/pages/onboarding_screen.dart';
import 'package:mobile/pages/profile_screen.dart';
import 'package:mobile/pages/register_screen.dart';
import 'package:mobile/pages/session_plan.dart';
import 'package:mobile/pages/splash_screen.dart';
import 'package:mobile/pages/statistics_screen.dart';
import 'package:mobile/pages/nutrition_screen.dart';

class AppRouter {
  static GoRouter create(UserProvider userProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: userProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = userProvider.isAuthenticated;
        final loc = state.matchedLocation;
        final isAuthRoute = loc == '/login' || loc == '/register';
        final isFlowRoute = loc == '/splash' || loc == '/onboarding';

        if (!loggedIn && !isAuthRoute && !isFlowRoute) return '/login';
        if (loggedIn && (isAuthRoute || isFlowRoute)) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/plan',
          builder: (context, state) => const SessionPlan(),
        ),
        GoRoute(
          path: '/activity_screen',
          builder: (context, state) => const ActivityScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/nutrition',
              builder: (context, state) => const NutritionScreen(),
            ),
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatisticsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }
}