import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:traductor_voz/core/auth_service.dart';

import 'package:provider/provider.dart';
import 'package:traductor_voz/providers/connectivity_provider.dart';
import 'package:traductor_voz/components/no_connection.dart';
import 'package:traductor_voz/components/alert_modal.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final AuthService _authService = AuthService();

  String _selectedLanguage = 'es';
  final List<Map<String, String>> _languages = [
    {'code': 'es', 'name': 'Español'},
    {'code': 'en', 'name': 'Inglés'},
    {'code': 'fr', 'name': 'Francés'},
    {'code': 'de', 'name': 'Alemán'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Portugués'},
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showMessage("Por favor, completa todos los campos");
      return;
    }

    try {
      await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _selectedLanguage,
      );
      _showMessage("Registro exitoso. Ahora puedes iniciar sesión.");
      if (!mounted) return;
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
  }

  void _mostrarDialogoSinInternet(BuildContext context) {
    ModalAlerta.mostrar(
      context: context,
      titulo: "Sin conexión",
      contenido: "No puedes registrarte sin internet.",
      textoBoton: "OK",
      icono: Icons.wifi_off,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return Scaffold(
      appBar: AppBar(title: const Text("Registro Firebase")),
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
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  items: _languages.map((lang) {
                    return DropdownMenuItem<String>(
                      value: lang['code']!,
                      child: Text(lang['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (isConnected) {
                      _register();
                    } else {
                      _mostrarDialogoSinInternet(context);
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
        ],
      ),
    );
  }
}
