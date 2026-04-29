import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/article.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'newsly.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE saved_articles (
            url TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            content TEXT,
            imageUrl TEXT,
            sourceName TEXT,
            publishedAt TEXT,
            author TEXT
          )
        ''');
        
        await db.execute('''
          CREATE TABLE cache (
            endpoint TEXT PRIMARY KEY,
            data TEXT,
            timestamp INTEGER
          )
        ''');
      },
    );
  }

  // --- Saved Articles ---
  Future<void> saveArticle(Article article) async {
    final db = await database;
    await db.insert('saved_articles', article.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeSavedArticle(String url) async {
    final db = await database;
    await db.delete('saved_articles', where: 'url = ?', whereArgs: [url]);
  }

  Future<List<Article>> getSavedArticles() async {
    final db = await database;
    final maps = await db.query('saved_articles');
    return maps.map((map) => Article.fromMap(map)).toList();
  }

  Future<bool> isArticleSaved(String url) async {
    final db = await database;
    final result = await db.query('saved_articles', where: 'url = ?', whereArgs: [url]);
    return result.isNotEmpty;
  }

  // --- Caching ---
  Future<void> saveCache(String endpoint, dynamic data) async {
    final db = await database;
    await db.insert(
      'cache',
      {
        'endpoint': endpoint,
        'data': jsonEncode(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<dynamic> getCache(String endpoint) async {
    final db = await database;
    final maps = await db.query('cache', where: 'endpoint = ?', whereArgs: [endpoint]);
    if (maps.isNotEmpty) {
      return jsonDecode(maps.first['data'] as String);
    }
    return null;
  }
}
