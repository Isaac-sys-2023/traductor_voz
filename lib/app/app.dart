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
import 'package:traductor_voz/presentation/screens/historial/historial_screen.dart';
import '../core/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/screens/login/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0), // azul base (ajustable luego)
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traductor Voz a Voz',
      theme: ThemeData(
        useMaterial3: true, // ✅ Material 3
        colorScheme: colorScheme, // paleta derivada del seed
        textTheme:
            GoogleFonts.interTextTheme(), // ✅ Fuente Inter (limpia y legible)
        scaffoldBackgroundColor: colorScheme.surface, // fondo de pantalla
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50), // ancho completo
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const AuthWrapper(),
        '/doubleVia': (context) => DoubleViaSpeakScreen(),
        '/uniVia': (context) => UniViaSpeakScreen(),
        '/historial': (context) => const HistorialScreen(),
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
