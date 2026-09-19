import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/expense_provider.dart';
import '../utils/period_helper.dart';
import '../services/export_service.dart';
import 'add_expense_screen.dart';
import 'categories_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _colors = [
    Colors.teal,
    Colors.orange,
    Colors.indigo,
    Colors.pink,
    Colors.green,
    Colors.brown,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final monthRange = PeriodHelper.currentMonth();
    final breakdown = provider.categoryBreakdown(monthRange.start, monthRange.end);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BudgetBudy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categories',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CategoriesScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Transactions',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TransactionsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export to Excel',
            onPressed: () => ExportService.exportAndShare(provider.items, provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: _SummaryCard(label: 'This Week', amount: provider.weeklyTotal)),
                      const SizedBox(width: 8),
                      Expanded(child: _SummaryCard(label: 'This Month', amount: provider.monthlyTotal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SummaryCard(label: 'This Year', amount: provider.yearlyTotal, wide: true),
                  const SizedBox(height: 24),
                  Text('Spend by Category (This Month)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (breakdown.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No expenses recorded this month yet.')),
                    )
                  else
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: _buildSections(breakdown),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  if (breakdown.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        for (final entry in breakdown.entries.toList().asMap().entries)
                          _LegendChip(
                            color: _colors[entry.key % _colors.length],
                            label: '${entry.value.key}: ${entry.value.value.toStringAsFixed(2)}',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _buildSections(Map<String, double> breakdown) {
    final total = breakdown.values.fold(0.0, (a, b) => a + b);
    final entries = breakdown.entries.toList();
    return [
      for (final e in entries.asMap().entries)
        PieChartSectionData(
          value: e.value.value,
          title: total == 0 ? '' : '${(e.value.value / total * 100).toStringAsFixed(0)}%',
          color: _colors[e.key % _colors.length],
          radius: 70,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final bool wide;

  const _SummaryCard({required this.label, required this.amount, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              amount.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
