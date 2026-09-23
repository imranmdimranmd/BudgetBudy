import 'package:daily_spending/models/pie_data.dart';
import 'package:daily_spending/models/transaction.dart';
import 'package:daily_spending/screens/transactions/category_transactions_screen.dart';
import 'package:daily_spending/widgets/pie_chart_widgets/indicators_widget.dart';
import 'package:daily_spending/widgets/pie_chart_widgets/pie_chart_sections.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyPieChart extends StatefulWidget {
  final List<PieData> pieData;

  /// The transactions the [pieData] slices were built from, and whether
  /// they were grouped by category or subcategory. When both are supplied,
  /// tapping a slice (or its legend entry) opens the list of transactions
  /// that make up that slice.
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryTransactionsScreen(
          title: sliceName,
          transactions: filtered,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidht = MediaQuery.of(context).size.width;
    final canDrillDown = widget.sourceTransactions != null;

    return Container(
      width: double.infinity,
      height: 430,
      child: Column(
        children: <Widget>[
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: IndicatorsWidget(
                pieData: widget.pieData,
                onTap: canDrillDown ? _openTransactionsFor : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
