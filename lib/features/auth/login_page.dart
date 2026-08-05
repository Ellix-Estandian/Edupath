import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/supabase_service.dart';
import '../professor/professor_dashboard.dart';
import '../student/student_dashboard.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _auth = AuthService();

  bool loading = false;

  Future<void> login() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await _auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user == null) return;

      final profile = await SupabaseService.client
          .from("profiles")
          .select()
          .eq("id", user.id)
          .single();

      if (!mounted) return;

      if (profile["role"] == "professor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfessorDashboard(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const StudentDashboard(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                  ),
                );
              },
              child: const Text("Create Account"),
            )
          ],
        ),
      ),
    );
  }
}
