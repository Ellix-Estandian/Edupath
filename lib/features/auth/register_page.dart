import 'package:flutter/material.dart';
import 'package:edupath/core/services/auth_service.dart';
import 'package:edupath/core/services/supabase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  String _role = "student";
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user != null) {
        await SupabaseService.client.from('profiles').insert({
          "id": user.id,
          "full_name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "role": _role,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Successful"),
            ),
          );

          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                ),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Minimum 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _role,
                items: const [
                  DropdownMenuItem(
                    value: "student",
                    child: Text("Student"),
                  ),
                  DropdownMenuItem(
                    value: "professor",
                    child: Text("Professor"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
