import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pokemon_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb(); 
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'groups.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    /// INFO: tabel grup
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT
      )
    ''');

    /// INFO: tabel anggota
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        imagePath TEXT,
        groupName TEXT
      )
    ''');
  }

  /// INFO: Tambah anggota
  Future<int> insertMember(PokemonModel member, String groupName) async {
    final db = await database;
    return await db.insert(
      'members',
      {
        'name': member.name,
        'description': member.description,
        'imagePath': member.imagePath,
        'groupName': groupName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// INFO: Ambil semua anggota berdasarkan grup
  Future<List<PokemonModel>> getMembers(String groupName) async {
    final db = await database;
    final maps = await db.query(
      'members',
      where: 'groupName = ?',
      whereArgs: [groupName],
    );

    return List.generate(maps.length, (i) {
      return PokemonModel(
        id: maps[i]['id'].toString(),
        name: maps[i]['name'] as String,
        description: maps[i]['description'] as String,
        imagePath: maps[i]['imagePath'] as String,
      );
    });
  }

  /// INFO:Pindah anggota ke grup lain
  Future<int> moveMember(String fromGroup, String toGroup, String memberName) async {
    final db = await database;
    return await db.update(
      "members",
      {"groupName": toGroup},
      where: "groupName = ? AND name = ?",
      whereArgs: [fromGroup, memberName],
    );
  }

  /// INFO: Gabungkan semua anggota dari grup lama ke grup baru, lalu hapus grup lama
  Future<void> mergeGroups(String fromGroup, String toGroup) async {
    final db = await database;

    /// INFO: Pindahkan semua member dari grup asal ke grup tujuan
    await db.update(
      'members',
      {'groupName': toGroup},
      where: 'groupName = ?',
      whereArgs: [fromGroup],
    );

    /// INFO: Opsional: hapus entri grup asal jika ada di tabel groups
    await db.delete(
      'groups',
      where: 'name = ?',
      whereArgs: [fromGroup],
    );
  }

  ///INFO: Hapus anggota DB
  Future<void> deleteMember(int id) async {
    final db = await database;
    await db.delete('members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  /// INFO: Ambil semua nama grup dari tabel 'groups'
  Future<List<String>> getAllGroupNames() async {
    final db = await database;

    try {
      final result = await db.query('groups', columns: ['name']);

      /// INFO: Jika tidak ada data, kembalikan list kosong
      if (result.isEmpty) {
        print("LOG => Tidak ada grup ditemukan di tabel groups.");
        return [];
      }

      /// INFO: Ambil nama-nama grup dari hasil query
      final groupNames = result.map((e) => e['name'].toString()).toList();
      print("LOG => getAllGroupNames() hasil: $groupNames");
      return groupNames;
    } catch (e) {
      print("ERROR => Gagal mengambil daftar grup: $e");
      return [];
    }
  }

  Future<void> resetDataMember() async {
    final db = await database;
    await db.execute("DELETE FROM members");
  }
}
