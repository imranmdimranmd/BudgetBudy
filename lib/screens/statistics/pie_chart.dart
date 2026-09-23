import 'package:daily_spending/models/pie_data.dart';
import 'package:daily_spending/models/transaction.dart';
import 'package:daily_spending/screens/transactions/category_transactions_screen.dart';
import 'package:daily_spending/widgets/pie_chart_widgets/pie_chart_sections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyPieChart extends StatefulWidget {
  final List<PieData> pieData;

  /// The transactions the [pieData] slices were built from, and whether
  /// they were grouped by category or subcategory. When both are supplied,
  /// Tapping a slice opens the list of transactions that make up that slice.
  final List<Transaction>? sourceTransactions;
  final bool byCategory;

  const MyPieChart({
    Key? key,
    required this.pieData,
    this.sourceTransactions,
    this.byCategory = true,
  }) : super(key: key);

  @override
  _MyPieChartState createState() => _MyPieChartState();
}

class _MyPieChartState extends State<MyPieChart> {
  int touchedIndex = -1;

  void _openTransactionsFor(int index) {
    final source = widget.sourceTransactions;
    if (source == null || index < 0 || index >= widget.pieData.length) return;

    final sliceName = widget.pieData[index].name;
    final filtered = source.where((trx) {
      if (widget.byCategory) {
        return trx.category == sliceName;
      }
      final subcategory = (trx.subcategory?.trim().isNotEmpty == true)
          ? trx.subcategory!
          : 'Unspecified';
      return subcategory == sliceName;
    }).toList();

    _openTransactionList(sliceName, filtered);
  }

  void _openTransactionList(String title, List<Transaction> transactions) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryTransactionsScreen(
          title: title,
          transactions: transactions,
        ),
      ),
    );
  }

  Map<String, List<Transaction>> _transactionsBy(
    Iterable<Transaction> transactions,
    String Function(Transaction transaction) keyFor,
  ) {
    final grouped = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      final key = keyFor(transaction);
      grouped.putIfAbsent(key, () => []).add(transaction);
    }
    return grouped;
  }

  void _showDetails() {
    final transactions = widget.sourceTransactions;
    if (transactions == null || transactions.isEmpty) return;

    final categoryTransactions = _transactionsBy(
      transactions,
      (transaction) => transaction.category,
    );
    final subcategoryTransactions = _transactionsBy(
      transactions,
      (transaction) => transaction.subcategory?.trim().isNotEmpty == true
          ? transaction.subcategory!
          : 'Unspecified',
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Category details'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailsSection('Categories', categoryTransactions, context),
                const SizedBox(height: 20),
                _detailsSection(
                  'Subcategories',
                  subcategoryTransactions,
                  context,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailsSection(
    String title,
    Map<String, List<Transaction>> groupedTransactions,
    BuildContext dialogContext,
  ) {
    final entries = groupedTransactions.entries.toList()
      ..sort((a, b) => _total(b.value).compareTo(_total(a.value)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        for (final entry in entries)
          InkWell(
            onTap: () {
              Navigator.of(dialogContext).pop();
              _openTransactionList(entry.key, entry.value);
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text('₹${_total(entry.value)}'),
                  const SizedBox(width: 8),
                  const Text(
                    'View transactions',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.open_in_new, size: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }

  int _total(List<Transaction> transactions) =>
      transactions.fold(0, (sum, transaction) => sum + transaction.amount);

  @override
  Widget build(BuildContext context) {
    final screenWidht = MediaQuery.of(context).size.width;
    final canDrillDown = widget.sourceTransactions != null;

    return Container(
      width: double.infinity,
      height: 390,
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'View category and subcategory amounts',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.info_outline),
              onPressed: canDrillDown ? _showDetails : null,
            ),
          ),
          Expanded(
            child: GestureDetector(
              // The pieTouchData callback below already tracks which slice
              // is under the pointer as it moves, so a plain tap-up here is
              // enough to know which slice was tapped.
              onTap: canDrillDown && touchedIndex != -1
                  ? () => _openTransactionsFor(touchedIndex)
                  : null,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? response) {
                      setState(() {
                        if (response == null) {
                          touchedIndex = -1;
                        } else {
                          touchedIndex =
                              response.touchedSection?.touchedSectionIndex ??
                                  -1;
                        }
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections:
                      getSections(touchedIndex, widget.pieData, screenWidht),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
