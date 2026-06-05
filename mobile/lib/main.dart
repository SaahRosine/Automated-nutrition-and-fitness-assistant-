import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:mobile/app_router.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/workout_provider.dart';

void main() async {
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
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
      await context.read<UserProvider>().init();
      if (context.read<UserProvider>().isAuthenticated) {
        context.read<WorkoutProvider>().fetchWorkouts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final router = AppRouter.create(userProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Stride',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.black,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black,
        ),
      ),
      routerConfig: router,
    );
  }
}