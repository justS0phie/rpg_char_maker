import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xtubrmuzqzxhagzzzyat.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0dWJybXV6cXp4aGFnenp6eWF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNzQ4OTMsImV4cCI6MjA4ODg1MDg5M30._iboyZpKX2mCqrL34EY3OYYl6G6i3aNz_GuzUkKV8dM',
  );

  runApp(const RPGCharacterApp());
}

class RPGCharacterApp extends StatelessWidget {
  const RPGCharacterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}