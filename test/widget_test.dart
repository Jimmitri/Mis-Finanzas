import 'package:flutter_test/flutter_test.dart';
import 'package:mis_finanzas/models/transaction.dart';
import 'package:mis_finanzas/models/user.dart';

void main() {
  test('User model toMap and fromMap test', () {
    final user = User(
      id: 1,
      name: 'Adrian',
      email: 'adrian@example.com',
      password: 'password123',
    );

    final map = user.toMap();
    final fromMapUser = User.fromMap(map);

    expect(fromMapUser.id, 1);
    expect(fromMapUser.name, 'Adrian');
    expect(fromMapUser.email, 'adrian@example.com');
    expect(fromMapUser.password, 'password123');
  });

  test('TransactionItem model toMap and fromMap test', () {
    final transaction = TransactionItem(
      id: 1,
      userId: 1,
      title: 'Almuerzo',
      amount: 15.50,
      type: 'Gasto',
      category: 'Comida',
      date: '2026-09-28',
      description: 'Menú ejecutivo',
    );

    final map = transaction.toMap();
    final fromMapItem = TransactionItem.fromMap(map);

    expect(fromMapItem.id, 1);
    expect(fromMapItem.title, 'Almuerzo');
    expect(fromMapItem.amount, 15.50);
    expect(fromMapItem.type, 'Gasto');
    expect(fromMapItem.category, 'Comida');
  });
}
