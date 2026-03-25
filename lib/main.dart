import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ggullfnmtyalcssimdbq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdndWxsZm5tdHlhbGNzc2ltZGJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyMDMwODIsImV4cCI6MjA4OTc3OTA4Mn0.sQyTEfdSAnnaZPqyaFDgxjPGPIVHJhJEkv20Anv0LQ4',
  );

  runApp(const MyApp());
}

// Helper to access Supabase anywhere in the app
final supabase = Supabase.instance.client;

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
      home: const HomeScreen(), 
    );
  }
}
