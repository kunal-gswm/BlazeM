import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../config/app_config.dart';

/// Initializes and provides the sqflite database.
///
/// Cache-only. Not source of truth. Drop and re-fetch on breaking changes.
/// Every table stores raw_json for full response hydration.
class LocalDatabase {
  LocalDatabase._();

  static Database? _db;

  /// Get or create the database instance.
  static Future<Database> get instance async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConfig.dbName);

    return openDatabase(
      path,
      version: AppConfig.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // IPO cache
    batch.execute('''
      CREATE TABLE ipo_cache (
        id TEXT PRIMARY KEY,
        status TEXT,
        event_date TEXT,
        source TEXT,
        fetched_at INTEGER,
        raw_json TEXT NOT NULL
      )
    ''');

    // Corporate actions cache
    batch.execute('''
      CREATE TABLE corporate_action_cache (
        id TEXT PRIMARY KEY,
        type TEXT,
        event_date TEXT,
        source TEXT,
        fetched_at INTEGER,
        raw_json TEXT NOT NULL
      )
    ''');

    // Bond cache
    batch.execute('''
      CREATE TABLE bond_cache (
        id TEXT PRIMARY KEY,
        event_date TEXT,
        source TEXT,
        fetched_at INTEGER,
        raw_json TEXT NOT NULL
      )
    ''');

    // News cache
    batch.execute('''
      CREATE TABLE news_cache (
        id TEXT PRIMARY KEY,
        published_at TEXT,
        source TEXT,
        fetched_at INTEGER,
        raw_json TEXT NOT NULL
      )
    ''');

    // Timeline events cache
    batch.execute('''
      CREATE TABLE timeline_cache (
        id TEXT PRIMARY KEY,
        event_type TEXT,
        entity_type TEXT,
        date TEXT,
        status TEXT,
        importance TEXT,
        fetched_at INTEGER,
        raw_json TEXT NOT NULL
      )
    ''');

    // Watchlist (local-first, synced)
    batch.execute('''
      CREATE TABLE watchlist (
        event_id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        added_at INTEGER NOT NULL
      )
    ''');

    // Indexes for common queries
    batch.execute(
      'CREATE INDEX idx_timeline_date ON timeline_cache(date)',
    );
    batch.execute(
      'CREATE INDEX idx_timeline_status ON timeline_cache(status)',
    );
    batch.execute(
      'CREATE INDEX idx_ipo_status ON ipo_cache(status)',
    );

    await batch.commit(noResult: true);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Cache is disposable. On schema change, drop everything.
    await db.execute('DROP TABLE IF EXISTS ipo_cache');
    await db.execute('DROP TABLE IF EXISTS corporate_action_cache');
    await db.execute('DROP TABLE IF EXISTS bond_cache');
    await db.execute('DROP TABLE IF EXISTS news_cache');
    await db.execute('DROP TABLE IF EXISTS timeline_cache');
    await db.execute('DROP TABLE IF EXISTS watchlist');
    await _onCreate(db, newVersion);
  }

  /// Check if cached data is still fresh.
  static bool isFresh(int? fetchedAtMs, Duration ttl) {
    if (fetchedAtMs == null) return false;
    final fetchedAt = DateTime.fromMillisecondsSinceEpoch(fetchedAtMs);
    return DateTime.now().difference(fetchedAt) < ttl;
  }

  /// Close the database.
  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
