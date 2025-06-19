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

  bool _isResetting = false;

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

  // void _restartListening() async {
  //   if (_isListening) {
  //     _stopListening();
  //     await Future.delayed(
  //       Duration(milliseconds: 500),
  //     ); //Minimo 300 para evitar errores
  //     _startListening();
  //   }
  // }
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
            // child: Icon(_isListening ? Icons.stop : Icons.mic),
            // backgroundColor: _isListening ? Colors.red : Colors.green,
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
