import 'package:flutter/material.dart';
import 'features/auth/login_page.dart';

class EduPathApp extends StatelessWidget {
  const EduPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduPath',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
