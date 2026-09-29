import 'package:flutter/material.dart';
import '../../database/transaction_repository.dart';
import '../../models/transaction.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/session.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionItem? transaction;

  const TransactionFormScreen({
    super.key,
    this.transaction,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransactionRepository _repository = TransactionRepository();

  bool get isEditing => widget.transaction != null;

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedType = TransactionType.expense;
  String selectedCategory = TransactionCategories.expenseCategories.first;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.transaction!;
      titleController.text = t.title;
      amountController.text = t.amount.toString();
      descriptionController.text = t.description;
      selectedType = t.type;
      selectedCategory = t.category;
      try {
        selectedDate = DateTime.parse(t.date);
      } catch (_) {
        selectedDate = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  List<String> get _currentCategories {
    return selectedType == TransactionType.income
        ? TransactionCategories.incomeCategories
        : TransactionCategories.expenseCategories;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final double? amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingrese un monto numérico válido mayor a 0"),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    if (Session.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de sesión. Vuelve a iniciar sesión.")),
      );
      return;
    }

    final item = TransactionItem(
      id: isEditing ? widget.transaction!.id : null,
      userId: Session.userId!,
      title: titleController.text.trim(),
      amount: amount,
      type: selectedType,
      category: selectedCategory,
      date: _formatDate(selectedDate),
      description: descriptionController.text.trim(),
    );

    try {
      if (isEditing) {
        await _repository.updateTransaction(item);
      } else {
        await _repository.addTransaction(item);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? "Movimiento actualizado correctamente"
                : "Movimiento registrado correctamente",
          ),
          backgroundColor: AppColors.income,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar: $e"),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Movimiento" : "Nuevo Movimiento"),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Selector de tipo (Gasto / Ingreso)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text("Gasto"),
                    icon: Icon(Icons.arrow_downward, color: AppColors.expense),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text("Ingreso"),
                    icon: Icon(Icons.arrow_upward, color: AppColors.income),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedType = newSelection.first;
                    selectedCategory = _currentCategories.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Concepto / Título
              CustomTextField(
                controller: titleController,
                label: "Concepto / Título",
                icon: Icons.edit_note_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Ingrese el concepto del movimiento";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Monto
              CustomTextField(
                controller: amountController,
                label: "Monto (\$)",
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Ingrese el monto";
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return "Ingrese un monto mayor a cero";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Categoría Dropdown
              DropdownButtonFormField<String>(
                initialValue: _currentCategories.contains(selectedCategory)
                    ? selectedCategory
                    : _currentCategories.first,
                decoration: const InputDecoration(
                  labelText: "Categoría",
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _currentCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedCategory = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Selector de Fecha
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Fecha: ${_formatDate(selectedDate)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Descripción / Nota adicional
              CustomTextField(
                controller: descriptionController,
                label: "Descripción / Nota (Opcional)",
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              // Botón Guardar
              CustomButton(
                text: isEditing ? "Actualizar Movimiento" : "Guardar Movimiento",
                icon: Icons.save_rounded,
                onPressed: _saveTransaction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
