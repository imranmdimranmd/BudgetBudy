import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/categories.dart';

class CategoriesScreen extends StatefulWidget {
  static const routeName = '/categories';

  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final success = await context.read<Categories>().add(name);
    if (!mounted) return;

    if (success) {
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category already exists or is invalid')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Consumer<Categories>(
        builder: (context, categories, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'New category',
                          hintText: 'e.g. Subscriptions',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _addCategory(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'Add category',
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add_circle),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: categories.categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final category = categories.categories[index];
                    return ListTile(
                      leading: const Icon(Icons.label_outline),
                      title: Text(category),
                      trailing: category == 'Other'
                          ? const SizedBox.shrink()
                          : IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await categories.remove(category);
                              },
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
