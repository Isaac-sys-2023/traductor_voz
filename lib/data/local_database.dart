import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';

class LocalDatabase {
  static Database? _db;

  static Future<void> init() async {
    final path = join(await getDatabasesPath(), 'translations.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversaciones (
            id TEXT PRIMARY KEY,
            title TEXT,
            timestamp TEXT,
            double_via INTEGER,
            messages TEXT
          )
        ''');
      },
    );
  }

  static Future<void> saveConversacion(Conversacion conv) async {
    if (_db == null) return;
    await _db!.insert('conversaciones', {
      'id': conv.id,
      'title': conv.title,
      'timestamp': conv.timestamp?.toIso8601String(),
      'double_via': conv.double_via ? 1 : 0,
      'messages': jsonEncode(conv.messages.map((m) => m.toMap()).toList()),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Mantener solo las últimas 20 conversaciones
    await _db!.execute('''
      DELETE FROM conversaciones WHERE id NOT IN (
        SELECT id FROM conversaciones ORDER BY timestamp DESC LIMIT 20
      )
    ''');
  }

  static Future<List<Conversacion>> getConversaciones() async {
    if (_db == null) return [];
    final result = await _db!.query(
      'conversaciones',
      orderBy: 'timestamp DESC',
    );
    return result.map((row) {
      final messages = (jsonDecode(row['messages'] as String) as List)
          .map((m) => Mensaje.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      return Conversacion(
        id: row['id'] as String,
        title: row['title'] as String,
        timestamp: row['timestamp'] != null
            ? DateTime.tryParse(row['timestamp'] as String)
            : null,
        double_via: (row['double_via'] as int) == 1,
        messages: messages,
      );
    }).toList();
  }

  static Future<void> deleteConversacion(String id) async {
    if (_db == null) return;
    await _db!.delete('conversaciones', where: 'id = ?', whereArgs: [id]);
  }
}
