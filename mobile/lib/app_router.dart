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
import 'package:mobile/pages/settings.dart';
import 'package:mobile/pages/session.dart';
import 'package:mobile/pages/session_plan.dart';
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
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
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

        // ── Settings (outside shell — full-screen page) ──────────────────────
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
          ),
        ),

        // ── Session planning + active session ────────────────────────────────
        GoRoute(
          path: '/plan',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SessionPlan(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
          ),
        ),
        GoRoute(
          path: '/session/active',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final exercises = extra['exercises'] as List<Exercise>? ?? [];
            final workoutType = extra['workoutType'] as String? ?? 'running';
            final intensity = extra['intensity'] as String? ?? 'moderate';
            final duration = extra['duration'] as int? ?? 30;
            final estimatedCalories = extra['estimatedCalories'] as int? ?? 0;

            return CustomTransitionPage(
              key: state.pageKey,
              child: Session(
                exercises: exercises,
                workoutType: workoutType,
                intensity: intensity,
                duration: duration,
                estimatedCalories: estimatedCalories,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
            );
          },
        ),

        // ── Live running session UI (quick-start from FAB) ───────────────────
        GoRoute(
          path: '/session',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RunningSessionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
          ),
        ),

        // ── Main shell with bottom nav ────────────────────────────────────────
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
      ],
    );
  }
}
