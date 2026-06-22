import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DbService {
  static Database? _db;

  Future<Database?> get db async {
    // SQLite לא עובד ב-Web, נחזיר null
    if (kIsWeb) return null;
    _db ??= await _initDb();
    return _db;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'favorites.db');
    return openDatabase(path, version: 1, onCreate: (db, _) {
      db.execute('''CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        userId TEXT,
        userName TEXT,
        title TEXT,
        description TEXT,
        imageUrl TEXT,
        location TEXT,
        createdAt TEXT
      )''');
    });
  }

  Future<void> addFavorite(Post post) async {
    if (kIsWeb) return; // ב-Web לא שומרים מועדפים
    final d = await db;
    if (d == null) return;
    await d.insert('favorites', {
      'id': post.id,
      'userId': post.userId,
      'userName': post.userName,
      'title': post.title,
      'description': post.description,
      'imageUrl': post.imageUrl,
      'location': post.location,
      'createdAt': post.createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(String id) async {
    if (kIsWeb) return;
    final d = await db;
    if (d == null) return;
    await d.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Post>> getFavorites() async {
    if (kIsWeb) return []; // ב-Web לא מחזירים מועדפים
    final d = await db;
    if (d == null) return [];
    final maps = await d.query('favorites');
    return maps.map((m) => Post(
      id: m['id'] as String,
      userId: m['userId'] as String,
      userName: m['userName'] as String,
      title: m['title'] as String,
      description: m['description'] as String,
      imageUrl: m['imageUrl'] as String,
      location: m['location'] as String,
      createdAt: DateTime.parse(m['createdAt'] as String),
    )).toList();
  }

  Future<bool> isFavorite(String id) async {
    if (kIsWeb) return false;
    final d = await db;
    if (d == null) return false;
    final res = await d.query('favorites', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty;
  }
}
