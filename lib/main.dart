// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import for checking release mode
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:ideathon_monitor/screen/dashboard_screen.dart';
import 'package:ideathon_monitor/screen/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl;
  String supabaseAnonKey;

  // Check if the app is running in release mode (like on Vercel)
  if (kReleaseMode) {
    // --- For Production on Vercel ---
    // Use the environment variables provided by the build process
    supabaseUrl = const String.fromEnvironment('FLUTTER_PUBLIC_SUPABASE_URL');
    supabaseAnonKey = const String.fromEnvironment(
      'FLUTTER_PUBLIC_SUPABASE_ANON_KEY',
    );
  } else {
    // --- For Local Development ---
    // Load keys from your .env file
    await dotenv.load(fileName: ".env");
    supabaseUrl = dotenv.env['SUPABASE_URL']!;
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
  }

  // Initialize Supabase with the correct keys
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ideathon Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data?.session != null) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
