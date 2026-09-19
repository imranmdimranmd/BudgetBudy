import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../models/expense_item.dart';
import '../providers/expense_provider.dart';

class ExportService {
  /// Builds an .xlsx file from [items], saves it to the app documents
  /// directory and opens the native share sheet so the user can save/send it.
  static Future<void> exportAndShare(
    List<ExpenseItem> items,
    ExpenseProvider provider,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];
    excel.setDefaultSheet('Transactions');

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Category'),
      TextCellValue('Subcategory'),
      TextCellValue('Item'),
      TextCellValue('Amount'),
      TextCellValue('Note'),
    ]);

    final dateFormat = DateFormat('yyyy-MM-dd');
    for (final item in items) {
      final categoryId = provider.categoryIdForSubcategory(item.subcategoryId);
      final categoryName = categoryId != null ? provider.categoryName(categoryId) : 'Unknown';
      sheet.appendRow([
        TextCellValue(dateFormat.format(item.date)),
        TextCellValue(categoryName),
        TextCellValue(provider.subcategoryName(item.subcategoryId)),
        TextCellValue(item.name),
        DoubleCellValue(item.amount),
        TextCellValue(item.note ?? ''),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'budgetbudy_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'BudgetBudy expense export',
    );
  }
}
