import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traductor_voz/core/auth_service.dart';
import 'package:traductor_voz/presentation/screens/register/register_screen.dart';
import 'package:traductor_voz/core/local_storage.dart';

import 'package:traductor_voz/providers/connectivity_provider.dart';
import 'package:traductor_voz/components/no_connection.dart';
import 'package:traductor_voz/components/alert_modal.dart';

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

  void _mostrarDialogoSinInternet(BuildContext context) {
    ModalAlerta.mostrar(
      context: context,
      titulo: "Sin conexión",
      contenido: "No puedes iniciar sesión sin internet.",
      textoBoton: "OK",
      icono: Icons.wifi_off,
    );
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
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return Scaffold(
      appBar: AppBar(title: const Text("Login Firebase")),
      body: Column(
        children: [
          if (isConnected == false) SinConexion(),
          Padding(
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
                  onPressed: () {
                    if (isConnected) {
                      _login();
                    } else {
                      _mostrarDialogoSinInternet(context);
                    }
                  },
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
        ],
      ),
    );
  }
}
