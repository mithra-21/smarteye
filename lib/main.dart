import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/blind_dashboard_screen.dart';
import 'screens/caretaker_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://llchskoxgnahykorabhh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsY2hza294Z25haHlrb3JhYmhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2NDUzMzQsImV4cCI6MjA4ODIyMTMzNH0.oV7VbPZ-HZ3sFiTmK-0qkhbOQCe8BaKuWILYV4SOjgY',
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
      final userId = session.user.id;
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      
      final role = response['role'] as String?;
      
      if (!mounted) return;

      if (role == 'blind') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BlindDashboardScreen()),
        );
      } else if (role == 'caretaker') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CaretakerDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
