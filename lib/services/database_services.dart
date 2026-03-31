import 'dart:io';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final String _tableName = 'history_images';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentDirectory = await getApplicationCacheDirectory();
    String path = join(documentDirectory.path, "history_database.db");
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $_tableName(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      image_data BLOB,
      category TEXT,
      created_at TEXT,
      is_public INTEGER DEFAULT 0
    )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN category TEXT');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE $_tableName ADD COLUMN is_public INTEGER DEFAULT 0');
        print('✅ Database upgraded: is_public column added');
      } catch (e) {
        print('⚠️ is_public column might already exist: $e');
      }
    }
  }

  Future<int> insertImage({
    required String name,
    required Uint8List imageData,
    String? description,
    String? category,
    bool isPublic = false,
  }) async {
    Database db = await database;
    Map<String, dynamic> row = {
      'name': name,
      'image_data': imageData,
      'description': description ?? '',
      'category': category ?? '',
      'is_public': isPublic ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    };
    return await db.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> getAllImages() async {
    Database db = await database;
    return await db.query(_tableName, orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getImageById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateImage({
    required int id,
    String? name,
    String? description,
    Uint8List? imageData,
  }) async {
    Database db = await database;
    Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (imageData != null) updates['image_data'] = imageData;
    return await db.update(
      _tableName,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateImagePublicStatus(int id, bool isPublic) async {
    Database db = await database;
    return await db.update(
      _tableName,
      {'is_public': isPublic ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteImage(int id) async {
    Database db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllImages() async {
    Database db = await database;
    return await db.delete(_tableName);
  }

  Future<int> getImageCount() async {
    Database db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    ) ?? 0;
  }

  Future<List<Map<String, dynamic>>> searchImages(String query) async {
    Database db = await database;
    return await db.query(
      _tableName,
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
  }
}