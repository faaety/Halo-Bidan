import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:halobidan/chat/model_chat_massage.dart';

class ChatDatabase {
  static final ChatDatabase instance = ChatDatabase._init();
  static Database? _database;

  ChatDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("chat.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memberId TEXT,
        sender TEXT,
        text TEXT,
        timestamp TEXT,
        isEdited INTEGER,
        replyTo TEXT,
        replySender TEXT
      )
    ''');
  }

  Future<int> insertMessage(ChatMessage msg, String memberId) async {
    final db = await instance.database;
    return await db.insert("messages", {
      "memberId": memberId,
      "sender": msg.sender,
      "text": msg.text,
      "timestamp": msg.timestamp.toIso8601String(),
      "isEdited": msg.isEdited ? 1 : 0,
      "replyTo": msg.replyTo,
      "replySender": msg.replySender,
    });
  }

  Future<List<Map<String, dynamic>>> getRawMessages(String memberId) async {
    final db = await instance.database;
    return await db.query(
      "messages",
      where: "memberId = ?",
      whereArgs: [memberId],
      orderBy: "timestamp ASC",
    );
  }

  Future<void> updateMessage(int id, String newText) async {
    final db = await instance.database;
    await db.update(
      "messages",
      {
        "text": newText,
        "isEdited": 1,
        "timestamp": DateTime.now().toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteMessage(int id) async {
    final db = await instance.database;
    await db.delete("messages", where: "id = ?", whereArgs: [id]);
  }
}
