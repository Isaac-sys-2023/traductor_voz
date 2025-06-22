import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentText = '';
  String _fullText = '';
  String _translatedText = '';
  bool _speechAvailable = false;
  bool _permissionGranted = false;
  DateTime? _lastSpeechTime;
  bool _isResetting = false;
  bool _isTranslating = false;
  bool _shouldSpeakAfterStop = false; // Nueva variable de control

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
        print('Estado: $status');
        //
        if (status == 'done') {
          _restartListening();
        }
        //
      },
      onError: (error) {
        print('Error: ${error.errorMsg}');
        //
        _restartListening();
        //
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
      _shouldSpeakAfterStop = true; // Habilitar reproducción al detener
    });

    await _speech.listen(
      onResult: (result) async {
        setState(() {
          _currentText = result.recognizedWords;
          _lastSpeechTime = DateTime.now();

          if (result.finalResult) {
            _fullText += ' ${result.recognizedWords}';
            // Solo traducir durante la grabación, no reproducir aún
            if (_isListening) {
              _translateText(_fullText, speak: false);
            }
          }
        });
      },
      localeId: 'es-ES',
      listenFor: Duration(minutes: 1),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _translateText(String text, {bool speak = true}) async {
    if (text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final translator = GoogleTranslator();
      var translation = await translator.translate(text, from: 'es', to: 'en');

      setState(() {
        _translatedText = translation.text;
        _isTranslating = false;
      });

      // Reproducir solo si está permitido y no estamos grabando
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

    await _speech.stop();
    setState(() => _isListening = false);

    // Solo traducir y reproducir si hay texto y está permitido
    if (_fullText.isNotEmpty && _shouldSpeakAfterStop) {
      await _translateText(_fullText, speak: true);
    }
    _shouldSpeakAfterStop = false; // Resetear el flag
  }

  Future<void> _speakTranslatedText() async {
    if (_translatedText.isEmpty || _isListening) return;

    setState(() => _isSpeaking = true);
    await _flutterTts.speak(_translatedText);
  }

  void _restartListening() async {
    if (_isListening && !_isResetting && !_isSpeaking) {
      setState(() => _isResetting = true);
      await _speech.stop();
      await Future.delayed(Duration(milliseconds: 300));
      if (mounted) {
        await _startListening();
        setState(() => _isResetting = false);
      }
    }
  }

  void _clearText() {
    setState(() {
      _currentText = '';
      _fullText = '';
      _translatedText = '';
      _shouldSpeakAfterStop = false;
    });
    _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
      _isListening = false;
    });
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
        title: const Text('Traductor Voz a Voz - Español/Inglés'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearText,
            tooltip: 'Limpiar texto',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Texto Original (Español):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _currentText,
                      style: TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                    SizedBox(height: 20),
                    Text(_fullText, style: TextStyle(fontSize: 16)),
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
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traducción (Inglés):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                    Text(
                      _translatedText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green[800],
                        fontStyle: _isSpeaking
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
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
            child: Icon(
              _isSpeaking
                  ? Icons.volume_up
                  : _isListening
                  ? Icons.mic
                  : Icons.mic_none,
            ),
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
          ),
          SizedBox(height: 10),
          if (_isListening && !_isSpeaking)
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
