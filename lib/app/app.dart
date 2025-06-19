import 'package:flutter/material.dart';
import 'package:traductor_voz/presentation/screens/home/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traductor Voz a Voz',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomeScreen(),
    );
  }
}
