import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/pages/app_shell.dart';
import 'package:mobile/pages/dashboard_screen.dart';
import 'package:mobile/pages/login_screen.dart';
import 'package:mobile/pages/onboarding_screen.dart';
import 'package:mobile/pages/profile_screen.dart';
import 'package:mobile/pages/register_screen.dart';
import 'package:mobile/pages/running_session_screen.dart';
import 'package:mobile/pages/statistics_screen.dart';
import 'package:mobile/pages/workout_programs_screen.dart';
import 'package:mobile/pages/splash_screen.dart';

class AppRouter {
  static GoRouter create(UserProvider userProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: userProvider,
      debugLogDiagnostics: false,
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = userProvider.isAuthenticated;
        final isAuthRoute = state.location == '/login' || state.location == '/register';
        final isFlowRoute = state.location == '/splash' || state.location == '/onboarding';

        if (!loggedIn && !isAuthRoute && !isFlowRoute) return '/login';
        if (loggedIn && (isAuthRoute || isFlowRoute)) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
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
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/programs',
              builder: (context, state) => const WorkoutProgramsScreen(),
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
        GoRoute(
          path: '/session',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RunningSessionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
                child: child,
              );
            },
          ),
        ),
      ],
    );
  }
}
