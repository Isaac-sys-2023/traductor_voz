import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../presentation/screens/double_via_speak/domain/conversation_message.dart';
import 'package:traductor_voz/presentation/screens/double_via_speak/domain/conversation_message.dart';

class ConversationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveConversation({
    required String title,
    required List<ConversationMessage> messages,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("Usuario no autenticado");
    }

    // Convertir mensajes a formato Map para Firestore
    final messagesList = messages
        .map(
          (msg) => {
            'speaker': msg.speaker,
            'originalText': msg.originalText,
            'translatedText': msg.translatedText,
            'originalLanguage': msg.originalLanguage,
            'translatedLanguage': msg.translatedLanguage,
            'timestamp': msg.timestamp.toIso8601String(),
          },
        )
        .toList();

    await _db.collection('usuarios').doc(uid).collection('conversaciones').add({
      'title': title,
      'timestamp': FieldValue.serverTimestamp(),
      'messages': messagesList,
    });
  }
}
