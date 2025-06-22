import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:translator/translator.dart'; // Paquete para traducción

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
  String _translatedText = '';
  bool _speechAvailable = false;
  bool _permissionGranted = false;
  DateTime? _lastSpeechTime;
  bool _isResetting = false;
  bool _isTranslating = false;

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
          _restartListening();
        }
      },
      onError: (error) {
        print('Error: ${error.errorMsg}');
        _restartListening();
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
      onResult: (result) async {
        setState(() {
          _currentText = result.recognizedWords;
          _lastSpeechTime = DateTime.now();

          if (result.finalResult) {
            _fullText += ' ${result.recognizedWords}';
            _translateText(_fullText); // Traducir cuando hay resultado final
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

  Future<void> _translateText(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final translator = GoogleTranslator();
      var translation = await translator.translate(text, from: 'es', to: 'en');

      setState(() {
        _translatedText = translation.text;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'Error en la traducción: $e';
        _isTranslating = false;
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _restartListening() async {
    if (_isListening && !_isResetting) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor Voz a Texto - Español/Inglés'),
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
          // Sección de texto original (español)
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

          // Sección de texto traducido (inglés)
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
                    Text(
                      _translatedText,
                      style: TextStyle(fontSize: 16, color: Colors.green[800]),
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
            onPressed: _isListening ? _stopListening : _startListening,
            child: Icon(
              _isListening || _isResetting ? Icons.mic : Icons.mic_none,
            ),
            backgroundColor: _isListening || _isResetting
                ? Colors.red
                : Colors.green,
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
