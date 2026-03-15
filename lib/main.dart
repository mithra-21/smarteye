import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/blind_dashboard_screen.dart';
import 'screens/caretaker_dashboard_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Eye Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF48FB1)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final role = await authService.getUserRole(session.user.id);

      if (!mounted) return;

      if (role == 'blind') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BlindDashboardScreen()),
        );
      } else if (role == 'caretaker') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CaretakerDashboardScreen()),
        );
      }
      // If role is null/unknown, stay on HomeScreen (default below)
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
