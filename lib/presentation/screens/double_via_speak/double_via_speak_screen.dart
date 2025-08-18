import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Modelo para almacenar cada mensaje de la conversación
class ConversationMessage {
  final String speaker;
  final String originalText;
  final String translatedText;
  final String originalLanguage;
  final String translatedLanguage;
  final DateTime timestamp;

  ConversationMessage({
    required this.speaker,
    required this.originalText,
    required this.translatedText,
    required this.originalLanguage,
    required this.translatedLanguage,
    required this.timestamp,
  });
}

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

  // Idiomas para cada usuario
  String _languageUserA = 'es';
  String _languageUserB = 'en';

  // Turno actual (A o B)
  String _currentTurn = 'A';

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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initSpeech();
    _initTts();
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
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
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
    if (_isSpeaking) return;

    if (!_permissionGranted) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        return;
      }
      _permissionGranted = true;
    }

    setState(() {
      _isListening = true;
      _currentText = 'Escuchando...';
    });

    // Determinar idioma según el turno actual
    final listenLanguage = _currentTurn == 'A'
        ? _languageUserA
        : _languageUserB;

    await _speech.listen(
      onResult: (result) async {
        setState(() {
          _currentText = result.recognizedWords;

          if (result.finalResult) {
            _processSpeech(result.recognizedWords);
          }
        });
      },
      localeId: listenLanguage,
      listenFor: const Duration(minutes: 1),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  Future<void> _processSpeech(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final translator = GoogleTranslator();

      // Determinar idiomas según el turno
      final fromLanguage = _currentTurn == 'A'
          ? _languageUserA
          : _languageUserB;
      final toLanguage = _currentTurn == 'A' ? _languageUserB : _languageUserA;

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
      setState(() => _isTranslating = false);
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
    if (!_isListening) return;

    setState(() => _preventRestart = true);
    await _speech.stop();
    setState(() {
      _isListening = false;
      _preventRestart = false;
    });
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

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor de Conversaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearConversation,
            tooltip: 'Limpiar conversación',
          ),
        ],
      ),
      body: Column(
        children: [
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
                        color: _currentTurn == 'A' ? Colors.blue : Colors.black,
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
                        color: _currentTurn == 'B' ? Colors.blue : Colors.black,
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
                    child: Text(
                      _currentText,
                      style: const TextStyle(fontSize: 16),
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
                final message = _conversationHistory.reversed.toList()[index];
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                border: Border.all(color: Colors.grey[300]!),
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
                                    onPressed: () => _repeatMessage(message),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isSpeaking) return;
          if (_isListening) {
            _stopListening();
          } else {
            _startListening();
          }
        },
        backgroundColor: _isSpeaking
            ? Colors.grey
            : _isListening
            ? Colors.red
            : _currentTurn == 'A'
            ? Colors.blue
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
    );
  }
}
