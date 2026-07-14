import 'package:sqflite/sqflite.dart';

import '../models/book.dart';
import 'database_helper.dart';

class BookRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> addBook(Book book) async {
    final Database db = await _databaseHelper.database;

    return await db.insert(
      DatabaseHelper.bookTable,
      book.toMap(),
    );
  }

  Future<List<Book>> getBooksByUser(int userId) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.bookTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'title ASC',
    );

    return result.map((book) => Book.fromMap(book)).toList();
  }

  Future<int> updateBook(Book book) async {
    final Database db = await _databaseHelper.database;

    return await db.update(
      DatabaseHelper.bookTable,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final Database db = await _databaseHelper.database;

    return await db.delete(
      DatabaseHelper.bookTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Book>> searchBooks(int userId, String search) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.bookTable,
      where: 'userId = ? AND title LIKE ?',
      whereArgs: [userId, '%$search%'],
    );

    return result.map((book) => Book.fromMap(book)).toList();
  }

  Future<int> updateFavorite(int id, bool favorite) async {
    final Database db = await _databaseHelper.database;

    return await db.update(
      DatabaseHelper.bookTable,
      {
        'favorite': favorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}