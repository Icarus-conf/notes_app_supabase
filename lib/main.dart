import 'package:flutter/material.dart';
import 'package:notes_app_supabase/data/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kxzdrnjbjtmkbixpozsl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4emRybmpianRta2JpeHBvenNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzIzOTEyNDcsImV4cCI6MjA0Nzk2NzI0N30.ERVyFmPCZ5S-Det4UAt7BedekZo4XubJ8jpLUs2ZByc',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
