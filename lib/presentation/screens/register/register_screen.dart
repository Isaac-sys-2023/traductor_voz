import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro Firebase")),
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
                try {
                  await _authService.registerWithEmail(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  _showMessage(
                    "Registro exitoso. Ahora puedes iniciar sesión.",
                  );
                  Navigator.pop(context); // Vuelve a LoginScreen
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'email-already-in-use') {
                    _showMessage("Este correo ya está registrado.");
                  } else if (e.code == 'weak-password') {
                    _showMessage("La contraseña es muy débil.");
                  } else {
                    _showMessage("Error: ${e.message}");
                  }
                }
              },
              child: const Text("Registrar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("¿Ya tienes cuenta? Inicia sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
