// lib/main.dart

import 'package:flutter/material.dart';
import 'package:ideathon_monitor/screen/dashboard_screen.dart';
import 'package:ideathon_monitor/screen/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Define the variables using String.fromEnvironment
  // Vercel will provide these values during the build process.
  const supabaseUrl = String.fromEnvironment('FLUTTER_PUBLIC_SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment(
    'FLUTTER_PUBLIC_SUPABASE_ANON_KEY',
  );

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

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
    // This stream builder listens to authentication state changes
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // If the user's session is active, show the dashboard
        if (snapshot.hasData && snapshot.data?.session != null) {
          return const DashboardScreen();
        }
        // Otherwise, show the login screen
        else {
          return const LoginScreen();
        }
      },
    );
  }
}
