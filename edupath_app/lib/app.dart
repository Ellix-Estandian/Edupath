import 'package:flutter/material.dart';

import 'features/auth/login_page.dart';
import 'core/theme/app_theme.dart';

class EduPathApp extends StatelessWidget {
  const EduPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduPath',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
