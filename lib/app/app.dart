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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traductor Voz a Voz',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/doubleVia': (context) => DoubleViaSpeakScreen(),
        '/uniVia': (context) => UniViaSpeakScreen(),
      },
    );
  }
}
