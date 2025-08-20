import 'package:flutter/material.dart';
import '../../../core/auth_service.dart';
import '../register/register_screen.dart';
import '../../../core/local_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    final data = await _authService.loginWithEmailAndGetData(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (data != null) {
      await LocalStorage.saveLanguage(data['idioma']);
      _showMessage("Bienvenido ${data['nombre']} (Idioma: ${data['idioma']})");

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/main',
      ); // Ir a pantalla principal
    } else {
      _showMessage("Error al iniciar sesión");
    }
  }

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
              onPressed: _login,
              child: const Text("Iniciar Sesión"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("¿No tienes cuenta? Regístrate"),
            ),
          ],
        ),
      ),
    );
  }
}
