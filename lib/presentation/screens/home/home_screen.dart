// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _texto = 'Presiona y mantén el micrófono para hablar';
//   bool _speechAvailable = false;
//   bool _permissionGranted = false;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _initSpeech();
//   }

//   Future<void> _initSpeech() async {
//     // Verificar disponibilidad del servicio de reconocimiento de voz
//     _speechAvailable = await _speech.initialize(
//       onStatus: (status) => print('Estado: $status'),
//       onError: (error) => print('Error: ${error.errorMsg}'),
//     );

//     if (!_speechAvailable) {
//       setState(() {
//         _texto =
//             'El reconocimiento de voz no está disponible en este dispositivo';
//       });
//     }
//   }

//   Future<void> _toggleListening() async {
//     if (!_speechAvailable) return;

//     // Pedir permiso la primera vez
//     if (!_permissionGranted) {
//       final status = await Permission.microphone.request();
//       if (!status.isGranted) {
//         setState(() {
//           _texto = 'Se necesitan permisos de micrófono para continuar';
//         });
//         return;
//       }
//       _permissionGranted = true;
//     }

//     if (_isListening) {
//       _stopListening();
//     } else {
//       _startListening();
//     }
//   }

//   Future<void> _startListening() async {
//     setState(() {
//       _isListening = true;
//       _texto = 'Escuchando...';
//     });

//     await _speech.listen(
//       onResult: (result) {
//         if (result.finalResult) {
//           setState(() {
//             _texto = result.recognizedWords.isEmpty
//                 ? 'No se detectó voz'
//                 : result.recognizedWords;
//           });
//         }
//       },
//       localeId: 'es-ES', // o 'es-BO' si prefieres español de Bolivia
//       listenMode: stt.ListenMode.dictation,
//       cancelOnError: true,
//       partialResults: true,
//       onSoundLevelChange: (level) {
//         // Opcional: puedes usar esto para mostrar un indicador de nivel de sonido
//       },
//     );
//   }

//   void _stopListening() {
//     _speech.stop();
//     setState(() => _isListening = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Traductor Voz a Voz')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Text(
//             _texto,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 20),
//           ),
//         ),
//       ),
//       floatingActionButton: GestureDetector(
//         onLongPressStart: (_) => _toggleListening(),
//         onLongPressEnd: (_) => _stopListening(),
//         child: FloatingActionButton(
//           onPressed: null, // Deshabilitamos el press simple
//           child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 30),
//           backgroundColor: _isListening ? Colors.red : Colors.blue,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _currentText = '';
  String _fullText = '';
  bool _speechAvailable = false;
  bool _permissionGranted = false;
  DateTime? _lastSpeechTime;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        print('Estado: $status');
        if (status == 'done') {
          _restartListening(); // Reinicia automáticamente
        }
      },
      onError: (error) {
        print('Error: ${error.errorMsg}');
        _restartListening(); // Intenta recuperarse de errores
      },
    );
  }

  Future<void> _startListening() async {
    if (!_permissionGranted) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        setState(() => _currentText = 'Permiso de micrófono denegado');
        return;
      }
      _permissionGranted = true;
    }

    setState(() {
      _isListening = true;
      _currentText = 'Escuchando...';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _currentText = result.recognizedWords;
          _lastSpeechTime = DateTime.now();

          if (result.finalResult) {
            _fullText += ' ${result.recognizedWords}';
          }
        });
      },
      localeId: 'es-ES',
      listenFor: Duration(minutes: 1), // 1 minuto continuo
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _restartListening() async {
    if (_isListening) {
      _stopListening();
      await Future.delayed(Duration(milliseconds: 500));
      _startListening();
    }
  }

  void _clearText() {
    setState(() {
      _currentText = '';
      _fullText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor Voz a Voz - Largo'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearText,
            tooltip: 'Limpiar texto',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _currentText,
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            SizedBox(height: 20),
            Text(_fullText, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            if (_lastSpeechTime != null)
              Text(
                'Última actualización: ${_lastSpeechTime!.toLocal()}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            child: Icon(_isListening ? Icons.stop : Icons.mic),
            backgroundColor: _isListening ? Colors.red : Colors.green,
          ),
          SizedBox(height: 10),
          if (_isListening)
            FloatingActionButton.small(
              onPressed: _restartListening,
              child: Icon(Icons.refresh),
              backgroundColor: Colors.orange,
            ),
        ],
      ),
    );
  }
}
