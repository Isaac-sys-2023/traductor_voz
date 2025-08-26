import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:traductor_voz/presentation/screens/double_via_speak/domain/conversation_message.dart';
import 'package:traductor_voz/widgets/auth_wrapper.dart';
import 'package:translator_plus/translator_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:traductor_voz/core/local_storage.dart';
import 'package:traductor_voz/providers/connectivity_provider.dart';
import 'package:traductor_voz/components/no_connection.dart';
import 'package:traductor_voz/core/conversation_service.dart';

class UniViaSpeakScreen extends StatefulWidget {
  const UniViaSpeakScreen({super.key});

  @override
  State<UniViaSpeakScreen> createState() => _UniViaSpeakScreenState();
}

class _UniViaSpeakScreenState extends State<UniViaSpeakScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentText = 'Presiona el boton verde para hablar...';
  String _fullText = '';
  String _translatedText = '';
  bool _speechAvailable = false;
  bool _permissionGranted = false;
  DateTime? _lastSpeechTime;
  bool _isResetting = false;
  bool _isTranslating = false;
  bool _shouldSpeakAfterStop = false;
  bool _preventRestart = false;
  // Añade este controlador en tu estado
  TextEditingController _fullTextController = TextEditingController();

  String _sourceLanguage = 'es';
  String _targetLanguage = 'en';
  final Map<String, String> _languageNames = {
    'es': 'Español',
    'en': 'Inglés',
    'fr': 'Francés',
    'de': 'Alemán',
    'it': 'Italiano',
    'pt': 'Portugués',
  };

  final Map<String, String> _ttsLanguages = {
    'es': 'es-ES',
    'en': 'en-US',
    'fr': 'fr-FR',
    'de': 'de-DE',
    'it': 'it-IT',
    'pt': 'pt-BR',
  };

  final ConversationService _conversationService = ConversationService();
  final List<ConversationMessage> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _fullTextController = TextEditingController(); // Inicializa el controlador
    _initSpeech();
    _initTts();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await LocalStorage.getLanguage();
    setState(() {
      _sourceLanguage = lang ?? 'es';
      _targetLanguage = lang == 'en' ? 'es' : 'en'; // Idioma por defecto
    });
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        print('Estado: $status');
        if (status == 'done' && !_preventRestart) {
          _restartListening();
        }
      },
      onError: (error) {
        print('Error: ${error.errorMsg}');
        if (!_preventRestart) {
          _restartListening();
        }
      },
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
        _translatedText = 'Error en reproducción: $msg';
      });
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
    _clearText();
  }

  Future<void> _startListening() async {
    if (_isSpeaking) return;

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
      _shouldSpeakAfterStop = true;
    });

    await _speech.listen(
      onResult: (result) async {
        setState(() {
          _currentText = result.recognizedWords;
          _lastSpeechTime = DateTime.now();

          if (result.finalResult) {
            _fullText += ' ${result.recognizedWords}';
            _fullTextController.text = _fullText; // Actualiza el controlador
            if (_isListening) {
              _translateText(_fullText, speak: false);
            }
          }
        });
      },
      localeId: _sourceLanguage,
      listenFor: Duration(minutes: 1),
      pauseFor: Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  Future<void> _translateText(String text, {bool speak = true}) async {
    if (text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final translator = GoogleTranslator();
      var translation = await translator.translate(
        text,
        from: _sourceLanguage,
        to: _targetLanguage,
      );

      setState(() {
        _translatedText = translation.text;
        _isTranslating = false;
      });

      if (speak && !_isListening && _shouldSpeakAfterStop) {
        await _speakTranslatedText();
      }
    } catch (e) {
      setState(() {
        _translatedText = 'Error en la traducción: $e';
        _isTranslating = false;
      });
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    setState(() => _preventRestart = true);

    await _speech.stop();
    setState(() {
      _isListening = false;
      _preventRestart = false;
    });

    if (_fullText.isNotEmpty && _shouldSpeakAfterStop) {
      await _translateText(_fullText, speak: true);
      _currentText = 'Presiona el boton verde para hablar...';
    }
    _shouldSpeakAfterStop = false;
  }

  Future<void> _speakTranslatedText() async {
    if (_translatedText.isEmpty || _isListening) return;

    final ttsLang = _ttsLanguages[_targetLanguage] ?? 'en-US';
    await _flutterTts.setLanguage(ttsLang);

    setState(() => _isSpeaking = true);
    await _flutterTts.speak(_translatedText);
  }

  void _restartListening() async {
    if (_isListening && !_isResetting && !_isSpeaking && !_preventRestart) {
      setState(() => _isResetting = true);
      await _speech.stop();
      await Future.delayed(Duration(milliseconds: 300));
      if (mounted && !_preventRestart) {
        await _startListening();
      }
      setState(() => _isResetting = false);
    }
  }

  void _clearText() {
    setState(() {
      // _currentText = '';
      _currentText = 'Presiona el boton verde para hablar...';
      _fullText = '';
      _translatedText = '';
      _fullTextController.clear(); // Limpia el controlador
      _shouldSpeakAfterStop = false;
    });
    _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _isListening = false;
    });
  }

  Future<void> _saveConversation() async {
    final titleController = TextEditingController();
    final scaffoldContext = context; // Contexto seguro del State

    // Mostrar diálogo para ingresar título
    final result = await showDialog<String>(
      context: scaffoldContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Guardar Conversación'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Título de la conversación',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Cerrar diálogo
                titleController.dispose();
                _conversationHistory.clear();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Debe ingresar un título')),
                  );
                  return;
                }
                Navigator.pop(dialogContext, title); // Retornar el título
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    // Si se canceló o no se ingresó título, no hacer nada
    if (result == null || result.isEmpty) return;

    // Guardar conversación en Firestore
    try {
      await _saveConversationToFirestore(result);

      // Vaciar lista de mensajes
      if (!mounted) return;
      setState(() {
        _conversationHistory.clear();
        _isTranslating = false;
        _fullText = '';
        _fullTextController.clear(); // Limpia el controlador
        _translatedText = '';
        // _currentText = '';
        _currentText = 'Presiona el boton verde para hablar...';
      });

      // Mostrar confirmación
      ScaffoldMessenger.of(
        scaffoldContext,
      ).showSnackBar(const SnackBar(content: Text('Conversación guardada')));

      // Navegar a AuthWrapper
      if (!mounted) return;
      Navigator.pushReplacement(
        scaffoldContext,
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
      );
    } catch (e) {
      print('Error al guardar: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Error al guardar la conversación')),
      );
    } finally {
      titleController.dispose();
    }
  }

  Future<void> _saveConversationToFirestore(String title) async {
    try {
      await _conversationService.saveConversation(
        title: title,
        messages: _conversationHistory,
        doubleVia: false,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Conversación guardada')));
    } catch (e) {
      print('Error al guardar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la conversación')),
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _fullTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor Voz a Voz - Español/Inglés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_fullText.isEmpty ||
                  _isListening == true ||
                  _isSpeaking == true) {
                return null;
              } else {
                // Crear nuevo mensaje en el historial
                final newMessage = ConversationMessage(
                  speaker: "Yo",
                  originalText: _fullText,
                  translatedText: _translatedText,
                  originalLanguage: _sourceLanguage,
                  translatedLanguage: _targetLanguage,
                  timestamp: DateTime.now(),
                );

                setState(() {
                  _conversationHistory.add(newMessage);
                });

                _saveConversation();
              }
            },
            tooltip: 'Guardar conversación',
          ),

          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearText,
            tooltip: 'Limpiar texto',
          ),
        ],
      ),
      body: Column(
        children: [
          if (isConnected == false) SinConexion(),
          // Selectores de idioma
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Selector idioma origen
                DropdownButton<String>(
                  value: _sourceLanguage,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _sourceLanguage = newValue);
                      _clearText();
                    }
                  },
                  items: _languageNames.keys.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_languageNames[value]!),
                    );
                  }).toList(),
                ),

                // Botón para intercambiar idiomas
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                  tooltip: 'Intercambiar idiomas',
                ),

                // Selector idioma destino
                DropdownButton<String>(
                  value: _targetLanguage,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _targetLanguage = newValue);
                      _clearText();
                    }
                  },
                  items: _languageNames.keys.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_languageNames[value]!),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              // child: SingleChildScrollView(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Texto Original (${_languageNames[_sourceLanguage]})',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 16,
              //         ),
              //       ),
              //       SizedBox(height: 10),
              //       Text(
              //         _currentText,
              //         style: TextStyle(fontSize: 18, color: Colors.blue),
              //       ),
              //       SizedBox(height: 20),
              //       // Text(_fullText, style: TextStyle(fontSize: 16)),
              //       TextField(
              //         controller: _fullTextController,
              //         maxLines: null, // Permite múltiples líneas
              //         keyboardType: TextInputType.multiline,
              //         decoration: InputDecoration(
              //           border: OutlineInputBorder(),
              //           hintText: 'El texto reconocido aparecerá aquí...',
              //         ),
              //         style: TextStyle(fontSize: 16),
              //         onChanged: (value) {
              //           setState(() {
              //             _fullText =
              //                 value; // Actualiza _fullText cuando el usuario edita
              //           });
              //         },
              //       ),

              //       SizedBox(height: 10),
              //       ElevatedButton(
              //         onPressed: () async {
              //           await _translateText(_fullText, speak: false);
              //           _speakTranslatedText();
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.blue,
              //           foregroundColor: Colors.white,
              //         ),
              //         child: Text('Retraducir'),
              //       ),

              //       if (_lastSpeechTime != null)
              //         Padding(
              //           padding: const EdgeInsets.only(top: 10),
              //           child: Text(
              //             'Última actualización: ${_lastSpeechTime!.toLocal()}',
              //             style: TextStyle(fontSize: 12, color: Colors.grey),
              //           ),
              //         ),
              //     ],
              //   ),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Texto Original (${_languageNames[_sourceLanguage]})',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _currentText,
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                  SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _fullTextController,
                        maxLines: null, // Permite múltiples líneas
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'El texto reconocido aparecerá aquí...',
                        ),
                        style: TextStyle(fontSize: 16),
                        onChanged: (value) {
                          setState(() {
                            _fullText =
                                value; // Actualiza _fullText cuando el usuario edita
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _translateText(_fullText, speak: false);
                      _speakTranslatedText();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Retraducir'),
                  ),

                  if (_lastSpeechTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Última actualización: ${_lastSpeechTime!.toLocal()}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              // child: SingleChildScrollView(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Traducción (${_languageNames[_targetLanguage]}):',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 16,
              //         ),
              //       ),
              //       SizedBox(height: 10),
              //       if (_isTranslating)
              //         Padding(
              //           padding: const EdgeInsets.symmetric(vertical: 10),
              //           child: Row(
              //             children: [
              //               CircularProgressIndicator(),
              //               SizedBox(width: 10),
              //               Text('Traduciendo...'),
              //             ],
              //           ),
              //         ),
              //       if (_isSpeaking)
              //         Padding(
              //           padding: const EdgeInsets.symmetric(vertical: 10),
              //           child: Row(
              //             children: [
              //               Icon(Icons.volume_up, color: Colors.blue),
              //               SizedBox(width: 10),
              //               Text('Reproduciendo...'),
              //             ],
              //           ),
              //         ),
              //       Text(
              //         _translatedText,
              //         style: TextStyle(
              //           fontSize: 16,
              //           color: Colors.green[800],
              //           fontStyle: _isSpeaking
              //               ? FontStyle.italic
              //               : FontStyle.normal,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Traducción (${_languageNames[_targetLanguage]}):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  if (_isTranslating)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 10),
                          Text('Traduciendo...'),
                        ],
                      ),
                    ),
                  if (_isSpeaking)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.volume_up, color: Colors.blue),
                          SizedBox(width: 10),
                          Text('Reproduciendo...'),
                        ],
                      ),
                    ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _translatedText,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[800],
                          fontStyle: _isSpeaking
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (_isSpeaking) return;
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
            backgroundColor: _isSpeaking
                ? Colors.blue
                : _isListening
                ? Colors.red
                : Colors.green,
            tooltip: _isSpeaking
                ? 'Reproduciendo audio'
                : _isListening
                ? 'Detener escucha'
                : 'Comenzar escucha',
            child: Icon(
              _isSpeaking
                  ? Icons.volume_up
                  : _isListening
                  ? Icons.mic
                  : Icons.mic_none,
            ),
          ),
          SizedBox(height: 10),
          if (_isListening && !_isSpeaking)
            FloatingActionButton.small(
              onPressed: _restartListening,
              backgroundColor: Colors.orange,
              child: Icon(Icons.refresh),
            ),
        ],
      ),
    );
  }
}
