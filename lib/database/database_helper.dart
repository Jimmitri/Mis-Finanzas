import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String databaseName = "bookshelf.db";

  static const int databaseVersion = 1;

  static const String userTable = "users";
  static const String bookTable = "books";

  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, databaseName);

    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE $userTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');


    await db.execute('''
      CREATE TABLE $bookTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        category TEXT NOT NULL,
        year INTEGER NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        pdfPath TEXT NOT NULL,
        status TEXT NOT NULL,
        favorite INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(userId) REFERENCES $userTable(id)
      )
    ''');
  }
}