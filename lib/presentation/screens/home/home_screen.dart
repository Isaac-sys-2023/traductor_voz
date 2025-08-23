import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/historial');
              },
              child: const Text('Ir a Historial Screen'),
            ),
          ),
        ],
      ),
    );
  }
}
