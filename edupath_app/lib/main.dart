import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://szfjxbrgdyfzqfukzysl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6Zmp4YnJnZHlmenFmdWt6eXNsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU4ODUwNDYsImV4cCI6MjEwMTQ2MTA0Nn0.grpUqsQcKpFYpiFY_hjcj5aN9BFblBmyWI8M9ff5W4w',
  );

  runApp(const EduPathApp());
}
