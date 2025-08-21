// import 'package:flutter/material.dart';
// import 'package:traductor_voz/presentation/screens/home/home_screen.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Traductor Voz a Voz',
//       theme: ThemeData(primarySwatch: Colors.deepPurple),
//       home: HomeScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:traductor_voz/presentation/screens/home/home_screen.dart';
import 'package:traductor_voz/presentation/screens/double_via_speak/double_via_speak_screen.dart';
import 'package:traductor_voz/presentation/screens/uni_via_speak/uni_via_speak_screen.dart';

import '../core/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/screens/login/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traductor Voz a Voz',
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const AuthWrapper(),
        '/doubleVia': (context) => DoubleViaSpeakScreen(),
        '/uniVia': (context) => UniViaSpeakScreen(),
      },
    );
  }
}

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
