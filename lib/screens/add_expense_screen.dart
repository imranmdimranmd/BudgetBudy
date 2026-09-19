import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/expense_item.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  Category? _selectedCategory;
  Subcategory? _selectedSubcategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _itemNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save(ExpenseProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubcategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and subcategory')),
      );
      return;
    }

    final item = ExpenseItem(
      subcategoryId: _selectedSubcategory!.id!,
      name: _itemNameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );
    await provider.addItem(item);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final subcategories =
        _selectedCategory == null ? <Subcategory>[] : provider.subcategoriesFor(_selectedCategory!.id!);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Category>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: provider.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (c) => setState(() {
                  _selectedCategory = c;
                  _selectedSubcategory = null;
                }),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Subcategory>(
                initialValue: _selectedSubcategory,
                decoration: const InputDecoration(labelText: 'Subcategory'),
                items: subcategories
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (s) => setState(() => _selectedSubcategory = s),
                validator: (v) => v == null ? 'Select a subcategory' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(labelText: 'Item name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter an item name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter an amount';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text('${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(provider),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
