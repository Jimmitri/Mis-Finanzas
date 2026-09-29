import 'package:flutter/material.dart';
import '../../database/transaction_repository.dart';
import '../../models/transaction.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/session.dart';
import '../../widgets/transaction_card.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionRepository _repository = TransactionRepository();
  final TextEditingController _searchController = TextEditingController();

  List<TransactionItem> _allTransactions = [];
  List<TransactionItem> _filteredTransactions = [];
  bool _isLoading = true;
  String _selectedFilter = "Todos"; // "Todos", "Ingreso", "Gasto"

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (Session.userId == null) return;

    final list = await _repository.getTransactionsByUser(Session.userId!);
    if (!mounted) return;

    setState(() {
      _allTransactions = list;
      _isLoading = false;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<TransactionItem> result = List.from(_allTransactions);

    // Filtro por tipo
    if (_selectedFilter == "Ingresos") {
      result = result.where((t) => t.type == TransactionType.income).toList();
    } else if (_selectedFilter == "Gastos") {
      result = result.where((t) => t.type == TransactionType.expense).toList();
    }

    // Filtro por texto de búsqueda
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.category.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredTransactions = result;
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
      _loadTransactions();
    }
  }

  Future<void> _deleteTransaction(TransactionItem item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Movimiento"),
          content: Text("¿Deseas eliminar el registro '${item.title}' por \$${item.amount.toStringAsFixed(2)}?"),
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
      _loadTransactions();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Movimiento eliminado correctamente"),
          backgroundColor: AppColors.income,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movimientos"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar por concepto o categoría...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => _applyFilters(),
            ),

            const SizedBox(height: 14),

            // Filtros rápidos horizontales
            Row(
              children: [
                _buildFilterChip("Todos"),
                const SizedBox(width: 8),
                _buildFilterChip("Ingresos"),
                const SizedBox(width: 8),
                _buildFilterChip("Gastos"),
              ],
            ),

            const SizedBox(height: 14),

            // Lista de transacciones
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "No hay movimientos registrados",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final item = _filteredTransactions[index];
                            return TransactionCard(
                              transaction: item,
                              onEdit: () => _openForm(item),
                              onDelete: () => _deleteTransaction(item),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = label;
          _applyFilters();
        });
      },
    );
  }
}
