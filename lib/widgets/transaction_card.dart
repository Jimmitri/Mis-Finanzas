import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class TransactionCard extends StatelessWidget {
  final TransactionItem transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Comida":
        return Icons.restaurant_rounded;
      case "Transporte":
        return Icons.directions_bus_rounded;
      case "Vivienda":
        return Icons.home_rounded;
      case "Servicios":
        return Icons.lightbulb_rounded;
      case "Entretenimiento":
        return Icons.movie_rounded;
      case "Salud":
        return Icons.medical_services_rounded;
      case "Educación":
        return Icons.school_rounded;
      case "Sueldo":
        return Icons.payments_rounded;
      case "Ventas":
        return Icons.storefront_rounded;
      case "Inversiones":
        return Icons.trending_up_rounded;
      case "Premios / Regalos":
        return Icons.card_giftcard_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == TransactionType.income;
    final Color amountColor = isIncome ? AppColors.income : AppColors.expense;
    final String amountPrefix = isIncome ? "+ \$" : "- \$";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Contenedor de ícono según categoría
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: amountColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Título, categoría y fecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transaction.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Text(
                        " • ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        transaction.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Monto formateado
            Text(
              "$amountPrefix${transaction.amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),

            // Menú de opciones (Editar / Eliminar)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text("Editar"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.expense),
                      SizedBox(width: 10),
                      Text("Eliminar"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
