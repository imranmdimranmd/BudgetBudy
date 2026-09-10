import 'package:flutter/foundation.dart';

import '../DBhelp/dbhelper.dart';

class Categories with ChangeNotifier {
  List<String> _categories = [];

  List<String> get categories => List.unmodifiable(_categories);

  Future<void> load() async {
    _categories = await DBHelper.fetchCategories();
    notifyListeners();
  }

  Future<bool> add(String name) async {
    final cleaned = name.trim();
    if (cleaned.isEmpty || _categories.any((c) => c.toLowerCase() == cleaned.toLowerCase())) {
      return false;
    }

    final result = await DBHelper.insertCategory(cleaned);
    if (result == 0) return false;

    _categories = await DBHelper.fetchCategories();
    notifyListeners();
    return true;
  }

  Future<void> remove(String name) async {
    await DBHelper.deleteCategory(name);
    _categories = await DBHelper.fetchCategories();
    notifyListeners();
  }
}
