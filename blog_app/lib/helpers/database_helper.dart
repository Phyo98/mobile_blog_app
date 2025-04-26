import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    await _addCreatedAtColumn(_database!);
    await _addDescriptionColumn(_database!);
    return _database!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'messages.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        imagePath TEXT,
        createdAt TEXT,
        description TEXT
      )
    ''');
  }

  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('messages');
    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });
  }

  Future<int> deleteMessage(int id) async {
    final db = await database;
    return await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  Future<int> updateMessage(Message message) async {
    final db = await database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<void> deleteMultipleMessages(List<int> ids) async {
    final db = await database;
    final idsString = ids.join(','); // "1,2,3"
    await db.rawDelete('DELETE FROM messages WHERE id IN ($idsString)');
  }

  Future<List<Message>> searchMessages(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'content LIKE ?',
      whereArgs: ['%$query%'],
    );
    return List.generate(maps.length, (i) {
      return Message.fromMap(maps[i]);
    });
  }

  Future<void> _addCreatedAtColumn(Database db) async {
    final res = await db.rawQuery("PRAGMA table_info(messages)");
    final hasCreatedAt = res.any((col) => col['name'] == 'createdAt');

    if (!hasCreatedAt) {
      await db.execute("ALTER TABLE messages ADD COLUMN createdAt TEXT");
    }
  }

  Future<void> _addDescriptionColumn(Database db) async {
    final res = await db.rawQuery("PRAGMA table_info(messages)");
    final hasDescription = res.any((col) => col['name'] == 'description');

    if (!hasDescription) {
      await db.execute("ALTER TABLE messages ADD COLUMN description TEXT");
    }
  }
}
