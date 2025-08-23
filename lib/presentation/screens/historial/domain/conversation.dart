// import 'package:cloud_firestore/cloud_firestore.dart';

// class Conversacion {
//   final String id;
//   final String title;
//   final List<Mensaje> messages;
//   final DateTime? timestamp;

//   Conversacion({
//     required this.id,
//     required this.title,
//     required this.messages,
//     required this.timestamp,
//   });

//   factory Conversacion.fromFirestore(Map<String, dynamic> data, String id) {
//     return Conversacion(
//       id: id,
//       title: data['titulo'] ?? 'Sin título',
//       messages: (data['messages'] != null)
//           ? (data['messages'] as List).map((m) => Mensaje.fromMap(m)).toList()
//           : [],
//       timestamp: data['timestamp'] != null
//           ? (data['timestamp'] as Timestamp).toDate()
//           : null,
//     );
//   }
// }

// class Mensaje {
//   final String speaker;
//   final String originalText;
//   final String originalLanguage;
//   final String translatedLanguage;
//   final String translatedText;
//   final DateTime timestamp;

//   Mensaje({
//     required this.speaker,
//     required this.originalText,
//     required this.translatedLanguage,
//     required this.translatedText,
//     required this.originalLanguage,
//     required this.timestamp,
//   });

//   factory Mensaje.fromMap(Map<String, dynamic> map) {
//     return Mensaje(
//       speaker: map['speaker'],
//       originalText: map['originalText'],
//       translatedText: map['translatedText'],
//       originalLanguage: map['originalLanguage'],
//       translatedLanguage: map['translatedLanguage'],
//       timestamp: (map['timestamp'] as Timestamp).toDate(),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class Conversacion {
  final String id;
  final String title;
  final List<Mensaje> messages;
  final DateTime? timestamp;

  Conversacion({
    required this.id,
    required this.title,
    required this.messages,
    required this.timestamp,
  });

  factory Conversacion.fromFirestore(Map<String, dynamic> data, String id) {
    return Conversacion(
      id: id,
      title: data['title'] ?? 'Sin título',
      messages: (data['messages'] != null)
          ? (data['messages'] as List)
                .map((m) => Mensaje.fromMap(Map<String, dynamic>.from(m)))
                .toList()
          : [],
      timestamp: _convertToDateTime(data['timestamp']),
    );
  }
}

class Mensaje {
  final String speaker;
  final String originalText;
  final String originalLanguage;
  final String translatedLanguage;
  final String translatedText;
  final DateTime timestamp;

  Mensaje({
    required this.speaker,
    required this.originalText,
    required this.translatedLanguage,
    required this.translatedText,
    required this.originalLanguage,
    required this.timestamp,
  });

  factory Mensaje.fromMap(Map<String, dynamic> map) {
    return Mensaje(
      speaker: map['speaker'],
      originalText: map['originalText'],
      translatedText: map['translatedText'],
      originalLanguage: map['originalLanguage'],
      translatedLanguage: map['translatedLanguage'],
      timestamp: _convertToDateTime(map['timestamp'])!,
    );
  }
}

DateTime? _convertToDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String) return DateTime.tryParse(value);
  return null;
}
