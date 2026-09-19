import 'package:flutter/foundation.dart';

import '../db/db_helper.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/expense_item.dart';
import '../utils/period_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Subcategory> _subcategories = [];
  List<ExpenseItem> _items = [];
  bool _loading = false;

  List<Category> get categories => List.unmodifiable(_categories);
  List<Subcategory> get subcategories => List.unmodifiable(_subcategories);
  List<ExpenseItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _categories = await DBHelper.getCategories();
    _subcategories = await DBHelper.getSubcategories();
    _items = await DBHelper.getItems();
    _loading = false;
    notifyListeners();
  }

  List<Subcategory> subcategoriesFor(int categoryId) =>
      _subcategories.where((s) => s.categoryId == categoryId).toList();

  Future<void> addCategory(String name) async {
    await DBHelper.insertCategory(Category(name: name));
    await loadAll();
  }

  Future<void> addSubcategory(int categoryId, String name) async {
    await DBHelper.insertSubcategory(Subcategory(categoryId: categoryId, name: name));
    await loadAll();
  }

  Future<void> deleteCategory(int id) async {
    await DBHelper.deleteCategory(id);
    await loadAll();
  }

  Future<void> deleteSubcategory(int id) async {
    await DBHelper.deleteSubcategory(id);
    await loadAll();
  }

  Future<void> addItem(ExpenseItem item) async {
    await DBHelper.insertItem(item);
    await loadAll();
  }

  Future<void> deleteItem(int id) async {
    await DBHelper.deleteItem(id);
    await loadAll();
  }

  double totalForRange(DateTime start, DateTime end) {
    return _items
        .where((i) => !i.date.isBefore(start) && i.date.isBefore(end))
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  List<ExpenseItem> itemsForRange(DateTime start, DateTime end) {
    return _items.where((i) => !i.date.isBefore(start) && i.date.isBefore(end)).toList();
  }

  double get weeklyTotal {
    final r = PeriodHelper.currentWeek();
    return totalForRange(r.start, r.end);
  }

  double get monthlyTotal {
    final r = PeriodHelper.currentMonth();
    return totalForRange(r.start, r.end);
  }

  double get yearlyTotal {
    final r = PeriodHelper.currentYear();
    return totalForRange(r.start, r.end);
  }

  /// Total spend per top-level category within [start, end).
  Map<String, double> categoryBreakdown(DateTime start, DateTime end) {
    final Map<int, double> subTotals = {};
    for (final i in _items) {
      if (!i.date.isBefore(start) && i.date.isBefore(end)) {
        subTotals[i.subcategoryId] = (subTotals[i.subcategoryId] ?? 0) + i.amount;
      }
    }
    final Map<String, double> result = {};
    for (final entry in subTotals.entries) {
      final sub = _subcategories.firstWhere(
        (s) => s.id == entry.key,
        orElse: () => Subcategory(id: entry.key, categoryId: -1, name: 'Unknown'),
      );
      final catName = categoryName(sub.categoryId);
      result[catName] = (result[catName] ?? 0) + entry.value;
    }
    return result;
  }

  String categoryName(int categoryId) => _categories
      .firstWhere((c) => c.id == categoryId, orElse: () => Category(id: -1, name: 'Unknown'))
      .name;

  String subcategoryName(int subcategoryId) => _subcategories
      .firstWhere((s) => s.id == subcategoryId,
          orElse: () => Subcategory(id: -1, categoryId: -1, name: 'Unknown'))
      .name;

  int? categoryIdForSubcategory(int subcategoryId) {
    final match = _subcategories.where((s) => s.id == subcategoryId);
    return match.isEmpty ? null : match.first.categoryId;
  }
}
