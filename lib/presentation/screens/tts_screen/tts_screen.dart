// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:url_launcher/url_launcher.dart';

// class TTSTestScreen extends StatefulWidget {
//   const TTSTestScreen({Key? key}) : super(key: key);

//   @override
//   State<TTSTestScreen> createState() => _TTSTestScreenState();
// }

// class _TTSTestScreenState extends State<TTSTestScreen> {
//   final FlutterTts flutterTts = FlutterTts();
//   final TextEditingController _textController = TextEditingController();

//   String _selectedLang = 'es-ES';
//   bool _isSpeaking = false;

//   List<String> supportedLanguages = [
//     'en-US',
//     'es-ES',
//     'fr-FR',
//     'it-IT',
//     'pt-PT',
//     'de-DE',
//   ];
//   Map<String, String> langNames = {
//     'en-US': 'English',
//     'es-ES': 'Español',
//     'fr-FR': 'Français',
//     'it-IT': 'Italiano',
//     'pt-PT': 'Português',
//     'de-DE': 'Deutsch',
//   };

//   List<dynamic> availableVoices = [];
//   bool _voiceAvailable = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadVoices();
//   }

//   Future<void> _loadVoices() async {
//     final voices = await flutterTts.getVoices;
//     setState(() {
//       availableVoices = voices;
//     });
//     _checkVoiceAvailability();
//   }

//   void _checkVoiceAvailability() {
//     final exists = availableVoices.any((voice) {
//       return voice['locale'] == _selectedLang;
//     });
//     setState(() {
//       _voiceAvailable = exists;
//     });
//   }

//   Future<void> _speak() async {
//     if (_textController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Escribe un texto para reproducir")),
//       );
//       return;
//     }

//     await flutterTts.setLanguage(_selectedLang);
//     await flutterTts.setPitch(1.0);
//     await flutterTts.setSpeechRate(0.9);

//     // await flutterTts.speak(_textController.text);
//     var result = await flutterTts.speak(_textController.text);
//     if (result == 1) {
//       setState(() {
//         _isSpeaking = true;
//       });
//     }
//   }

//   Future<void> _openTTSSettings() async {
//     const url = 'android.settings.TTS_SETTINGS';
//     // Abrir configuración de TTS en Android
//     try {
//       await launchUrl(
//         Uri.parse('intent://$url#Intent;scheme=package;end'),
//         mode: LaunchMode.externalApplication,
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("No se pudo abrir la configuración")),
//       );
//     }
//   }

//   Future<void> _stop() async {
//     var result = await flutterTts.stop();
//     if (result == 1) {
//       setState(() {
//         _isSpeaking = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Prueba TTS Offline")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Texto a reproducir:"),
//             TextField(
//               controller: _textController,
//               maxLines: 3,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: "Escribe algo aquí...",
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text("Selecciona idioma:"),
//             DropdownButton<String>(
//               value: _selectedLang,
//               items: supportedLanguages.map((lang) {
//                 return DropdownMenuItem(
//                   value: lang,
//                   child: Text(langNames[lang]!),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedLang = value!;
//                 });
//                 _checkVoiceAvailability();
//               },
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 Icon(
//                   _voiceAvailable ? Icons.check_circle : Icons.error,
//                   color: _voiceAvailable ? Colors.green : Colors.red,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   _voiceAvailable
//                       ? "Voz instalada para este idioma"
//                       : "Voz no disponible",
//                   style: TextStyle(
//                     color: _voiceAvailable ? Colors.green : Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             if (!_voiceAvailable)
//               ElevatedButton.icon(
//                 onPressed: _openTTSSettings,
//                 icon: const Icon(Icons.settings),
//                 label: const Text("Ir a configuración TTS"),
//               ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _voiceAvailable ? _speak : null,
//                 icon: const Icon(Icons.volume_up),
//                 label: const Text("Reproducir"),
//               ),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _isSpeaking ? _stop : null,
//                 icon: const Icon(Icons.stop),
//                 label: const Text("Detener"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_tts/flutter_tts.dart';
// // import 'package:url_launcher/url_launcher.dart';

// // class TTSTestScreen extends StatefulWidget {
// //   const TTSTestScreen({Key? key}) : super(key: key);

// //   @override
// //   State<TTSTestScreen> createState() => _TTSTestScreenState();
// // }

// // class _TTSTestScreenState extends State<TTSTestScreen> {
// //   final FlutterTts flutterTts = FlutterTts();
// //   final TextEditingController _textController = TextEditingController();

// //   String _selectedLang = 'es-ES';
// //   bool _isSpeaking = false;
// //   bool _isLoading = true;

// //   List<String> supportedLanguages = [
// //     'en-US',
// //     'es-ES',
// //     'fr-FR',
// //     'it-IT',
// //     'pt-PT',
// //     'de-DE',
// //   ];
// //   Map<String, String> langNames = {
// //     'en-US': 'English',
// //     'es-ES': 'Español',
// //     'fr-FR': 'Français',
// //     'it-IT': 'Italiano',
// //     'pt-PT': 'Português',
// //     'de-DE': 'Deutsch',
// //   };

// //   List<dynamic> availableVoices = [];
// //   bool _voiceAvailable = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initTTS();
// //   }

// //   Future<void> _initTTS() async {
// //     try {
// //       // Inicializar TTS
// //       await flutterTts.awaitSpeakCompletion(true);

// //       // Cargar voces disponibles
// //       final voices = await flutterTts.getVoices;

// //       setState(() {
// //         availableVoices = voices ?? [];
// //         _isLoading = false;
// //       });

// //       _checkVoiceAvailability();

// //     } catch (e) {
// //       print('Error inicializando TTS: $e');
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   void _checkVoiceAvailability() {
// //     final exists = availableVoices.any((voice) {
// //       return voice['locale'] == _selectedLang;
// //     });
// //     setState(() {
// //       _voiceAvailable = exists;
// //     });
// //   }

// //   Future<void> _speak() async {
// //     if (_textController.text.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Escribe un texto para reproducir")),
// //       );
// //       return;
// //     }

// //     try {
// //       await flutterTts.setLanguage(_selectedLang);
// //       await flutterTts.setPitch(1.0);
// //       await flutterTts.setSpeechRate(0.9);

// //       var result = await flutterTts.speak(_textController.text);
// //       if (result == 1) {
// //         setState(() {
// //           _isSpeaking = true;
// //         });
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Error al reproducir: $e")),
// //       );
// //     }
// //   }

// //   Future<void> _openTTSSettings() async {
// //     try {
// //       // Para Android
// //       const url = 'package:com.google.android.tts';

// //       if (await canLaunchUrl(Uri.parse(url))) {
// //         await launchUrl(Uri.parse(url));
// //       } else {
// //         // Intentar abrir configuración general de TTS
// //         await launchUrl(Uri.parse('intent:#Intent;action=android.settings.TEXT_TO_SPEECH_SETTINGS;end'));
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("No se pudo abrir la configuración TTS")),
// //       );
// //     }
// //   }

// //   Future<void> _stop() async {
// //     try {
// //       var result = await flutterTts.stop();
// //       if (result == 1) {
// //         setState(() {
// //           _isSpeaking = false;
// //         });
// //       }
// //     } catch (e) {
// //       print('Error al detener: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Prueba TTS Offline")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text("Texto a reproducir:"),
// //             TextField(
// //               controller: _textController,
// //               maxLines: 3,
// //               decoration: const InputDecoration(
// //                 border: OutlineInputBorder(),
// //                 hintText: "Escribe algo aquí...",
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             const Text("Selecciona idioma:"),
// //             DropdownButton<String>(
// //               value: _selectedLang,
// //               items: supportedLanguages.map((lang) {
// //                 return DropdownMenuItem(
// //                   value: lang,
// //                   child: Text(langNames[lang]!),
// //                 );
// //               }).toList(),
// //               onChanged: (value) {
// //                 setState(() {
// //                   _selectedLang = value!;
// //                 });
// //                 _checkVoiceAvailability();
// //               },
// //             ),
// //             const SizedBox(height: 10),

// //             if (_isLoading)
// //               const CircularProgressIndicator()
// //             else
// //               Row(
// //                 children: [
// //                   Icon(
// //                     _voiceAvailable ? Icons.check_circle : Icons.error,
// //                     color: _voiceAvailable ? Colors.green : Colors.red,
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Text(
// //                     _voiceAvailable
// //                         ? "Voz instalada para este idioma"
// //                         : "Voz no disponible",
// //                     style: TextStyle(
// //                       color: _voiceAvailable ? Colors.green : Colors.red,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ],
// //               ),

// //             const SizedBox(height: 20),
// //             if (!_voiceAvailable && !_isLoading)
// //               ElevatedButton.icon(
// //                 onPressed: _openTTSSettings,
// //                 icon: const Icon(Icons.settings),
// //                 label: const Text("Ir a configuración TTS"),
// //               ),
// //             const Spacer(),
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton.icon(
// //                 onPressed: _voiceAvailable ? _speak : null,
// //                 icon: const Icon(Icons.volume_up),
// //                 label: const Text("Reproducir"),
// //               ),
// //             ),
// //             const Spacer(),
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton.icon(
// //                 onPressed: _isSpeaking ? _stop : null,
// //                 icon: const Icon(Icons.stop),
// //                 label: const Text("Detener"),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTS Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TTSTestScreen(),
    );
  }
}

class TTSTestScreen extends StatefulWidget {
  const TTSTestScreen({Key? key}) : super(key: key);

  @override
  State<TTSTestScreen> createState() => _TTSTestScreenState();
}

class _TTSTestScreenState extends State<TTSTestScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  String _selectedLang = 'es-ES';
  bool _isSpeaking = false;
  bool _isLoading = true;
  String _ttsStatus = 'Inicializando...';

  List<String> supportedLanguages = [
    'en-US',
    'es-ES',
    'fr-FR',
    'it-IT',
    'pt-PT',
    'de-DE',
  ];

  Map<String, String> langNames = {
    'en-US': 'English (EEUU)',
    'es-ES': 'Español (España)',
    'fr-FR': 'Français (France)',
    'it-IT': 'Italiano (Italia)',
    'pt-PT': 'Português (Portugal)',
    'de-DE': 'Deutsch (Deutschland)',
  };

  List<dynamic> availableVoices = [];
  bool _voiceAvailable = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    try {
      // Configurar el TTS
      await flutterTts.awaitSpeakCompletion(true);

      // Establecer manejadores de eventos
      flutterTts.setStartHandler(() {
        setState(() {
          _isSpeaking = true;
          _ttsStatus = 'Reproduciendo...';
        });
      });

      flutterTts.setCompletionHandler(() {
        setState(() {
          _isSpeaking = false;
          _ttsStatus = 'Completado';
        });
      });

      flutterTts.setErrorHandler((msg) {
        setState(() {
          _isSpeaking = false;
          _ttsStatus = 'Error: $msg';
        });
      });

      // Cargar voces disponibles
      await _loadVoices();
    } catch (e) {
      setState(() {
        _ttsStatus = 'Error inicializando TTS: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVoices() async {
    try {
      final voices = await flutterTts.getVoices;

      setState(() {
        availableVoices = voices ?? [];
        _isLoading = false;
      });

      _checkVoiceAvailability();
    } catch (e) {
      setState(() {
        _ttsStatus = 'Error cargando voces: $e';
        _isLoading = false;
      });
    }
  }

  void _checkVoiceAvailability() {
    try {
      final exists = availableVoices.any((voice) {
        return voice['locale'] == _selectedLang;
      });

      setState(() {
        _voiceAvailable = exists;
        _ttsStatus = exists ? 'Voz disponible' : 'Voz no disponible';
      });
    } catch (e) {
      setState(() {
        _ttsStatus = 'Error verificando voz: $e';
      });
    }
  }

  Future<void> _speak() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe un texto para reproducir")),
      );
      return;
    }

    try {
      setState(() {
        _ttsStatus = 'Preparando...';
      });

      // Configurar el idioma
      await flutterTts.setLanguage(_selectedLang);
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(
        0.5,
      ); // Velocidad más lenta para mejor prueba

      // Reproducir el texto
      var result = await flutterTts.speak(_textController.text);

      if (result != 1) {
        setState(() {
          _ttsStatus = 'Error al iniciar la reproducción';
        });
      }
    } catch (e) {
      setState(() {
        _ttsStatus = 'Error: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al reproducir: $e")));
    }
  }

  Future<void> _openTTSSettings() async {
    try {
      // Intentar abrir configuración de TTS
      const url = 'app-settings:';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // Mensaje alternativo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No se pudo abrir la configuración. Por favor, ve a Ajustes > Accesibilidad > Texto a Voz",
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir la configuración")),
      );
    }
  }

  Future<void> _stop() async {
    try {
      var result = await flutterTts.stop();
      if (result == 1) {
        setState(() {
          _isSpeaking = false;
          _ttsStatus = 'Detenido';
        });
      }
    } catch (e) {
      setState(() {
        _ttsStatus = 'Error al detener: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prueba TTS Offline"),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto
            const Text(
              "Texto a reproducir:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Escribe algo aquí...",
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            const SizedBox(height: 20),

            // Selector de idioma
            const Text(
              "Selecciona idioma:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedLang,
              isExpanded: true,
              items: supportedLanguages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(langNames[lang]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLang = value!;
                });
                _checkVoiceAvailability();
              },
            ),

            const SizedBox(height: 16),

            // Estado del TTS
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLoading
                        ? Icons.hourglass_top
                        : _voiceAvailable
                        ? Icons.check_circle
                        : Icons.error,
                    color: _isLoading
                        ? Colors.blue
                        : _voiceAvailable
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoading
                              ? "Cargando..."
                              : _voiceAvailable
                              ? "Voz instalada"
                              : "Voz no disponible",
                          style: TextStyle(
                            color: _isLoading
                                ? Colors.blue
                                : _voiceAvailable
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(_ttsStatus, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón para configuraciones
            if (!_voiceAvailable && !_isLoading)
              ElevatedButton.icon(
                onPressed: _openTTSSettings,
                icon: const Icon(Icons.settings),
                label: const Text("Configurar voces TTS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),

            const Spacer(),

            // Botones de control
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _voiceAvailable && !_isLoading ? _speak : null,
                icon: const Icon(Icons.volume_up),
                label: Text(_isSpeaking ? "Reproduciendo..." : "Reproducir"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSpeaking ? _stop : null,
                icon: const Icon(Icons.stop),
                label: const Text("Detener"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
