import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:traductor_voz/widgets/auth_wrapper.dart';
import 'package:translator_plus/translator_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/local_storage.dart';
import '../../../core/conversation_service.dart';
import 'package:traductor_voz/presentation/screens/double_via_speak/domain/conversation_message.dart';
import 'package:provider/provider.dart';
import 'package:traductor_voz/providers/connectivity_provider.dart';
import 'package:traductor_voz/components/no_connection.dart';

class DoubleViaSpeakScreen extends StatefulWidget {
  const DoubleViaSpeakScreen({super.key});

  @override
  State<DoubleViaSpeakScreen> createState() => _DoubleViaSpeakScreenState();
}

class _DoubleViaSpeakScreenState extends State<DoubleViaSpeakScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentText = '';
  bool _speechAvailable = false;
  bool _permissionGranted = false;
  bool _isResetting = false;
  bool _isTranslating = false;
  bool _preventRestart = false;

  TextEditingController _currentTextController = TextEditingController();

  // Idiomas para cada usuario
  String _languageUserA = 'es';
  String _languageUserB = 'en';

  // Turno actual (A o B)
  String _currentTurn = 'A';

  String _buttonState = 'green'; // 'green', 'red', 'blue'

  // Historial de conversación
  final List<ConversationMessage> _conversationHistory = [];

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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _currentTextController = TextEditingController();
    _initSpeech();
    _initTts();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await LocalStorage.getLanguage();
    setState(() {
      _languageUserA = lang ?? 'es';
      _languageUserB = lang == 'en' ? 'es' : 'en'; // Idioma por defecto
    });
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && !_preventRestart && _isListening) {
          _restartListening();
        }
      },
      onError: (error) {
        if (!_preventRestart && _isListening) {
          _restartListening();
        }
      },
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _buttonState = 'green'; // Vuelve a verde automáticamente
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
        _buttonState = 'green'; // Vuelve a verde en caso de error
      });
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _languageUserA;
      _languageUserA = _languageUserB;
      _languageUserB = temp;
    });
    _clearConversation();
  }

  Future<void> _startListening() async {
    if (_buttonState != 'green') return;

    if (!_permissionGranted) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        return;
      }
      _permissionGranted = true;
    }

    setState(() {
      _isListening = true;
      _buttonState = 'red';
      // _currentText = 'Escuchando...';
      _currentText = '';
      _currentTextController.text = _currentText;
    });

    // Detener cualquier reconocimiento previo
    await _speech.stop();
    await Future.delayed(const Duration(milliseconds: 500));

    // Determinar idioma según el turno actual
    final listenLanguage = _currentTurn == 'A'
        ? _languageUserA
        : _languageUserB;
    print('Configurando idioma para usuario $_currentTurn: $listenLanguage');

    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && !_preventRestart && _isListening) {
          _restartListening();
        }
      },
      onError: (error) {
        if (!_preventRestart && _isListening) {
          _restartListening();
        }
      },
    );

    await _speech.listen(
      onResult: (result) async {
        setState(() {
          _currentText = result.recognizedWords;
          _currentTextController.text = _currentText;
        });
      },
      localeId: listenLanguage,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 10),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  Future<void> _processSpeech(String text) async {
    if (text.trim().isEmpty) {
      setState(() => _buttonState = 'green');
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final translator = GoogleTranslator();

      // Determinar idiomas según el turno
      final fromLanguage = _currentTurn == 'A'
          ? _languageUserA
          : _languageUserB;
      final toLanguage = _currentTurn == 'A' ? _languageUserB : _languageUserA;
      print('Traduciendo de $fromLanguage a $toLanguage');

      var translation = await translator.translate(
        text,
        from: fromLanguage,
        to: toLanguage,
      );

      // Crear nuevo mensaje en el historial
      final newMessage = ConversationMessage(
        speaker: _currentTurn,
        originalText: text,
        translatedText: translation.text,
        originalLanguage: fromLanguage,
        translatedLanguage: toLanguage,
        timestamp: DateTime.now(),
      );

      setState(() {
        _conversationHistory.add(newMessage);
        _isTranslating = false;
        _currentText = '';
      });

      // Reproducir traducción
      await _speakTranslatedText(translation.text, toLanguage);

      // Cambiar turno
      setState(() => _currentTurn = _currentTurn == 'A' ? 'B' : 'A');
    } catch (e) {
      print('Error en traducción: $e');
      setState(() {
        _isTranslating = false;
        _buttonState = 'green';
      });
    }
  }

  Future<void> _speakTranslatedText(String text, String language) async {
    if (text.isEmpty) return;

    final ttsLang = _ttsLanguages[language] ?? 'en-US';
    await _flutterTts.setLanguage(ttsLang);

    setState(() => _isSpeaking = true);
    await _flutterTts.speak(text);
  }

  Future<void> _stopListening() async {
    if (_buttonState != 'red') return;

    setState(() {
      _buttonState = 'blue';
      _isListening = false;
      _preventRestart = false;
    });

    await _speech.stop();

    if (_currentText.isNotEmpty /*&& _currentText != 'Escuchando...'*/ ) {
      await _processSpeech(_currentText);
    } else {
      // Si no hay texto, volver al estado verde
      setState(() => _buttonState = 'green');
    }
  }

  void _restartListening() async {
    if (_isListening && !_isResetting && !_isSpeaking && !_preventRestart) {
      setState(() => _isResetting = true);
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted && !_preventRestart) {
        await _startListening();
      }
      setState(() => _isResetting = false);
    }
  }

  void _clearConversation() {
    setState(() {
      _conversationHistory.clear();
      _currentText = '';
      _currentTurn = 'A';
    });
    _flutterTts.stop();
  }

  Future<void> _repeatMessage(ConversationMessage message) async {
    final ttsLang = _ttsLanguages[message.translatedLanguage] ?? 'en-US';
    await _flutterTts.setLanguage(ttsLang);
    await _flutterTts.speak(message.translatedText);
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
      setState(() => _conversationHistory.clear());

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
        doubleVia: true,
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
    _currentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = _buttonState == 'blue';
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return AbsorbPointer(
      absorbing: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Traductor de Conversaciones'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _conversationHistory.isEmpty
                    ? null
                    : _saveConversation,
                tooltip: 'Guardar conversación',
              ),

              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: _clearConversation,
                tooltip: 'Limpiar conversación',
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
                    // Idioma usuario A
                    Column(
                      children: [
                        Text(
                          'Usuario A',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentTurn == 'A'
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _languageUserA,
                          items: _languageNames.keys.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(_languageNames[value]!),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _languageUserA = newValue);
                            }
                          },
                        ),
                      ],
                    ),

                    // Botón para intercambiar idiomas
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: _swapLanguages,
                      tooltip: 'Intercambiar idiomas',
                    ),

                    // Idioma usuario B
                    Column(
                      children: [
                        Text(
                          'Usuario B',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentTurn == 'B'
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _languageUserB,
                          items: _languageNames.keys.map((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(_languageNames[value]!),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() => _languageUserB = newValue);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Indicador de turno actual
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: _currentTurn == 'A' ? Colors.blue[50] : Colors.green[50],
                child: Center(
                  child: Text(
                    _currentTurn == 'A'
                        ? 'Turno: Usuario A (${_languageNames[_languageUserA]})'
                        : 'Turno: Usuario B (${_languageNames[_languageUserB]})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // // Texto actual (parcial)
              // if (_isListening)
              //   Container(
              //     padding: const EdgeInsets.all(12),
              //     color: Colors.amber[50],
              //     child: Row(
              //       children: [
              //         const Icon(Icons.mic, color: Colors.red),
              //         const SizedBox(width: 10),
              //         Expanded(
              //           child: Text(
              //             _currentText,
              //             style: const TextStyle(fontSize: 16),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // Texto actual (parcial)
              if (_isListening)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.amber[50],
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        // child: Text(
                        //   _currentText,
                        //   style: const TextStyle(fontSize: 16),
                        // ),
                        child: SingleChildScrollView(
                          child: TextField(
                            controller: _currentTextController,
                            maxLines: null, // Permite múltiples líneas
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'El texto reconocido aparecerá aquí...',
                            ),
                            style: TextStyle(fontSize: 16),
                            onChanged: (value) {
                              setState(() {
                                _currentText =
                                    value; // Actualiza _currentText cuando el usuario edita
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Historial de conversación
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: _conversationHistory.length,
                  itemBuilder: (context, index) {
                    final message = _conversationHistory.reversed
                        .toList()[index];
                    final isUserA = message.speaker == 'A';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mensaje original
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUserA
                                        ? Colors.blue[50]
                                        : Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Usuario ${message.speaker} (${_languageNames[message.originalLanguage]})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(message.originalText),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Mensaje traducido
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Traducción (${_languageNames[message.translatedLanguage]})',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(message.translatedText),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.volume_up),
                                        onPressed: () =>
                                            _repeatMessage(message),
                                        tooltip: 'Repetir audio',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  if (_buttonState == 'green') {
                    _startListening();
                  } else if (_buttonState == 'red') {
                    _stopListening();
                  }
                  // En azul no responde
                },
                backgroundColor: _buttonState == 'red'
                    ? Colors.red
                    : _buttonState == 'blue'
                    ? Colors.blue
                    : _currentTurn == 'A'
                    ? Colors.blue
                    : Colors.green,
                child: Icon(
                  _buttonState == 'red'
                      ? Icons.mic
                      : _buttonState == 'blue'
                      ? Icons.volume_up
                      : Icons.mic_none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
