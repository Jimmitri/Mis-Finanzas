import 'package:flutter/material.dart';
import '../../database/transaction_repository.dart';
import '../../models/transaction.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/session.dart';
import '../../widgets/transaction_card.dart';
import '../transactions/transaction_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToTransactions;

  const HomeScreen({
    super.key,
    required this.onNavigateToTransactions,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionItem> _transactions = [];
  bool _isLoading = true;

  double _totalIncome = 0;
  double _totalExpense = 0;
  double get _balance => _totalIncome - _totalExpense;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (Session.userId == null) return;

    final list = await _repository.getTransactionsByUser(Session.userId!);
    if (!mounted) return;

    double income = 0;
    double expense = 0;

    for (final item in list) {
      if (item.type == TransactionType.income) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    setState(() {
      _transactions = list;
      _totalIncome = income;
      _totalExpense = expense;
      _isLoading = false;
    });
  }

  Future<void> _openForm([TransactionItem? item]) async {
    final bool? refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(transaction: item),
      ),
    );

    if (refresh == true) {
      _loadDashboardData();
    }
  }

  Future<void> _deleteTransaction(TransactionItem item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Movimiento"),
          content: Text("¿Deseas eliminar '${item.title}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.expense,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirm == true && item.id != null) {
      await _repository.deleteTransaction(item.id!);
      _loadDashboardData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Movimiento eliminado"),
          backgroundColor: AppColors.income,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Finanzas"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saludo de usuario
                    Text(
                      "Hola, ${Session.userName ?? 'Usuario'} 👋",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Resumen general de tu estado financiero",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tarjeta Principal: Saldo Total
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Saldo Disponible",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "\$${_balance.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            "${_transactions.length} movimientos registrados en total",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Tarjetas de Ingresos y Gastos lado a lado
                    Row(
                      children: [
                        // Tarjeta Ingresos
                        Expanded(
                          child: _buildMetricCard(
                            title: "Ingresos",
                            amount: _totalIncome,
                            icon: Icons.arrow_upward_rounded,
                            color: AppColors.income,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Tarjeta Gastos
                        Expanded(
                          child: _buildMetricCard(
                            title: "Gastos",
                            amount: _totalExpense,
                            icon: Icons.arrow_downward_rounded,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Encabezado de Movimientos Recientes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Últimos Movimientos",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_transactions.isNotEmpty)
                          TextButton(
                            onPressed: widget.onNavigateToTransactions,
                            child: const Text("Ver todos"),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Lista de últimos movimientos (máximo 4)
                    if (_transactions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Aún no tienes movimientos registrados",
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _openForm(),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text("Registrar primer movimiento"),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._transactions.take(4).map((item) {
                        return TransactionCard(
                          transaction: item,
                          onEdit: () => _openForm(item),
                          onDelete: () => _deleteTransaction(item),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}