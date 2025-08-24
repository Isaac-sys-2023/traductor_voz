import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:traductor_voz/core/auth_service.dart';
import 'package:traductor_voz/presentation/screens/login/login_screen.dart';
import 'package:traductor_voz/presentation/screens/home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? const LoginScreen() : HomeScreen(user: user);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
