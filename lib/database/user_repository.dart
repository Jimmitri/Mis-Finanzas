import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import 'database_helper.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> registerUser(User user) async {
    final Database db = await _databaseHelper.database;

    return await db.insert(
      DatabaseHelper.userTable,
      user.toMap(),
    );
  }

  Future<User?> loginUser(String email, String password) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.userTable,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.userTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }

  Future<User?> getUserById(int id) async {
    final Database db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.userTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }
}