import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? supabaseUrl;
  String? supabaseAnonKey;

  try {
    await dotenv.load(fileName: '.env');
    supabaseUrl = dotenv.env['SUPABASE_URL'];
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  } catch (_) {
    supabaseUrl = null;
    supabaseAnonKey = null;
  }

  if (supabaseUrl == null || supabaseUrl.trim().isEmpty) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Missing SUPABASE_URL in .env. Add your project URL before launching the app.',
            ),
          ),
        ),
      ),
    );
    return;
  }

  if (supabaseAnonKey == null || supabaseAnonKey.trim().isEmpty) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Missing SUPABASE_ANON_KEY in .env. Add your project anon key before launching the app.',
            ),
          ),
        ),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl.trim(),
    anonKey: supabaseAnonKey.trim(),
  );

  runApp(const EduPathApp());
}
