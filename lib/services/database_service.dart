import 'package:rick_morty/models/character.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static const String _favoritesTable = 'favorites';
  static const String _charactersTable = 'characters';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rick_and_morty.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_favoritesTable(
            id INTEGER PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE $_charactersTable(
            id INTEGER PRIMARY KEY,
            name TEXT,
            status TEXT,
            species TEXT,
            type TEXT,
            gender TEXT,
            image TEXT,
            location TEXT,
            timestamp INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE $_charactersTable(
              id INTEGER PRIMARY KEY,
              name TEXT,
              status TEXT,
              species TEXT,
              type TEXT,
              gender TEXT,
              image TEXT,
              location TEXT,
              timestamp INTEGER
            )
          ''');
        }
      },
    );
  }

  // Favorites methods
  Future<void> addFavorite(int id) async {
    final db = await database;
    await db.insert(_favoritesTable, {'id': id}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFavorite(int id) async {
    final db = await database;
    await db.delete(_favoritesTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<int>> getFavorites() async {
    final db = await database;
    final maps = await db.query(_favoritesTable);
    return List<int>.from(maps.map((map) => map['id'] as int));
  }

  // Characters cache methods
  Future<void> cacheCharacters(List<Character> characters) async {
    final db = await database;
    final batch = db.batch();
    
    for (final character in characters) {
      batch.insert(
        _charactersTable,
        {
          ...character.toJson(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit();
  }

  Future<List<Character>> getCachedCharacters(int page) async {
    final db = await database;
    const limit = 20;
    final offset = (page - 1) * limit;
    
    final maps = await db.query(
      _charactersTable,
      limit: limit,
      offset: offset,
      orderBy: 'timestamp DESC',
    );
    
    return maps.map((map) => Character.fromJson(map)).toList();
  }

  Future<List<Character>> getCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    
    final db = await database;
    final maps = await db.query(
      _charactersTable,
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
    
    return maps.map((map) => Character.fromJson(map)).toList();
  }

  Future<List<Character>> searchCachedCharacters(String query) async {
    final db = await database;
    final maps = await db.query(
      _charactersTable,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    
    return maps.map((map) => Character.fromJson(map)).toList();
  }
}