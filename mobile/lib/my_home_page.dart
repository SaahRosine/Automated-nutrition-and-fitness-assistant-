import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final storage = const FlutterSecureStorage();
  
  // Use same baseUrl as login.dart
  Future<String?> get _baseUrl async {
    // Load from .env file
    await dotenv.load(fileName: '.env');
    return dotenv.env['BASE_URL'] ;
  }

  Future<void> _logout() async {
    try {
      // Get stored token
      final token = await storage.read(key: 'auth_token');
      
      if (token != null) {
        // Call logout API
        await http.post(
          Uri.parse('$_baseUrl/auth/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );
      }
      
      // Delete stored token
      await storage.delete(key: 'auth_token');
      
      if (mounted) {
        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } catch (e) {
      // Still navigate to login even if API fails
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: Colors.red,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Page!'),
            
          ],
        ),
      ),
    );
  }
}
