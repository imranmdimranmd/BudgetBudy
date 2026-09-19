import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../models/category.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _addCategoryDialog(BuildContext context, ExpenseProvider provider) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.addCategory(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSubcategoryDialog(
    BuildContext context,
    ExpenseProvider provider,
    Category category,
  ) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Subcategory in ${category.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Subcategory name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.addSubcategory(category.id!, controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCategoryDialog(context, provider),
        child: const Icon(Icons.add),
      ),
      body: provider.categories.isEmpty
          ? const Center(child: Text('No categories yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                final subcategories = provider.subcategoriesFor(category.id!);
                return ExpansionTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => provider.deleteCategory(category.id!),
                  ),
                  children: [
                    ...subcategories.map(
                      (sub) => ListTile(
                        title: Text(sub.name),
                        contentPadding: const EdgeInsets.only(left: 32, right: 16),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => provider.deleteSubcategory(sub.id!),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: TextButton.icon(
                        onPressed: () => _addSubcategoryDialog(context, provider, category),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add subcategory'),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
