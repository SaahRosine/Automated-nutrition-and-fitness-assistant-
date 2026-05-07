import 'package:flutter/material.dart';
import 'package:mobile/pages/camera.dart';
import 'package:mobile/pages/session_plan.dart';
import 'package:mobile/pages/settings.dart';
import 'package:mobile/widgets/big_button.dart';
import 'package:mobile/core/constants/app_styles.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Fitness & Nutrition",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to the Menu!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                "This is where you can access all the features of the app.",
                style: TextStyle(fontSize: 16),
              ),
              BigButton(
                text: "Plan from photo",
                color: AppColors.blueGrey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
              ),

              const SizedBox(height: 20),

              BigButton(
                text: "Session Plan",
                color: AppColors.blueGrey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SessionPlan()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
