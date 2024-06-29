import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dementiapp_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE tasks(id INTEGER PRIMARY KEY, text TEXT, importance TEXT, done BOOL, deadline TEXT)',
    );

    await db.execute(
    '''
    CREATE TABLE metadata (
      id INTEGER PRIMARY KEY,
      revision INTEGER
    )
    ''',
    );

    await db.insert('metadata', {'id': 1, 'revision': 0});
  }
}