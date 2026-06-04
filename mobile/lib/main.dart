import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mobile/app_router.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/providers/preferences_provider.dart';
import 'package:mobile/providers/theme_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/workout_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Restore auth state
      await context.read<UserProvider>().init();
      // Restore preferences
      await context.read<PreferencesProvider>().init();
      // Fetch workouts if already logged in
      if (context.read<UserProvider>().isAuthenticated) {
        context.read<WorkoutProvider>().fetchWorkouts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final userProvider = context.watch<UserProvider>();
        final router = AppRouter.create(userProvider);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Stride',
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: router,
        );
      },
    );
  }
}
