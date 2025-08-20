import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Firebase")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _authService.loginWithEmail(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
              },
              child: const Text("Iniciar Sesión"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _authService.registerWithEmail(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
              },
              child: const Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }
}
