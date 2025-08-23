import 'package:flutter/material.dart';
import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';

class DetalleConversacionScreen extends StatelessWidget {
  final Conversacion conversacion;
  const DetalleConversacionScreen({Key? key, required this.conversacion})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(conversacion.title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: conversacion.messages.length,
        itemBuilder: (context, index) {
          final msg = conversacion.messages[index];
          final isA = msg.speaker == 'A';
          return Align(
            alignment: isA ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isA ? Colors.blue[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${isA ? 'Sujeto A' : 'Sujeto B'}: ${msg.originalText}'),
                  const SizedBox(height: 4),
                  Text(
                    'Traducción: ${msg.translatedText}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
