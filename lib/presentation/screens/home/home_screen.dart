import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:traductor_voz/components/custom_buttons.dart';
import 'package:traductor_voz/core/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:traductor_voz/providers/connectivity_provider.dart';
import 'package:traductor_voz/components/no_connection.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isConnected == false) SinConexion(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/doubleVia');
                    },
                    child: const Text('Ir a Double Via Speak Screen'),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/uniVia');
                    },
                    child: const Text('Ir a Uni Via Speak Screen'),
                  ),
                ),
                const SizedBox(height: 20),
                AppButtons.blue(
                  text: 'Historial',
                  onPressed: () {
                    Navigator.pushNamed(context, '/historial');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
