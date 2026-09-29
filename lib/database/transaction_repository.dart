import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';
import 'database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // CREATE: Agregar una nueva transacción
  Future<int> addTransaction(TransactionItem transaction) async {
    final Database db = await _databaseHelper.database;
    return await db.insert(
      DatabaseHelper.transactionTable,
      transaction.toMap(),
    );
  }

  // READ: Obtener todas las transacciones del usuario
  Future<List<TransactionItem>> getTransactionsByUser(int userId) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.transactionTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );

    return result.map((item) => TransactionItem.fromMap(item)).toList();
  }

  // UPDATE: Actualizar una transacción existente
  Future<int> updateTransaction(TransactionItem transaction) async {
    final Database db = await _databaseHelper.database;
    return await db.update(
      DatabaseHelper.transactionTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // DELETE: Eliminar una transacción por ID
  Future<int> deleteTransaction(int id) async {
    final Database db = await _databaseHelper.database;
    return await db.delete(
      DatabaseHelper.transactionTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // SEARCH: Buscar por título o categoría
  Future<List<TransactionItem>> searchTransactions(int userId, String query) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.transactionTable,
      where: 'userId = ? AND (title LIKE ? OR category LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'date DESC, id DESC',
    );

    return result.map((item) => TransactionItem.fromMap(item)).toList();
  }
}
