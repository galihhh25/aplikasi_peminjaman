import 'package:flutter/material.dart';
import 'core/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uxyphzhesrdounmahrni.supabase.co',
    anonKey: 'sb_publishable_Fn3gYYlKZMFuZJZSHk0SjQ_5GeJ1KJW',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(), // ⬅️ PENTING
    );
  }
}
// test commit
