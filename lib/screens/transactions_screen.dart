import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/expense_provider.dart';
import '../utils/period_helper.dart';
import '../services/export_service.dart';

enum _Period { week, month, year, all }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _Period _period = _Period.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final dateFormat = DateFormat('MMM d, yyyy');

    final items = switch (_period) {
      _Period.week => provider.itemsForRange(
          PeriodHelper.currentWeek().start, PeriodHelper.currentWeek().end),
      _Period.month => provider.itemsForRange(
          PeriodHelper.currentMonth().start, PeriodHelper.currentMonth().end),
      _Period.year => provider.itemsForRange(
          PeriodHelper.currentYear().start, PeriodHelper.currentYear().end),
      _Period.all => provider.items,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export to Excel',
            onPressed: () => ExportService.exportAndShare(items, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SegmentedButton<_Period>(
              segments: const [
                ButtonSegment(value: _Period.week, label: Text('Week')),
                ButtonSegment(value: _Period.month, label: Text('Month')),
                ButtonSegment(value: _Period.year, label: Text('Year')),
                ButtonSegment(value: _Period.all, label: Text('All')),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No transactions in this period.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => provider.deleteItem(item.id!),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${provider.categoryName(provider.categoryIdForSubcategory(item.subcategoryId) ?? -1)} '
                            '› ${provider.subcategoryName(item.subcategoryId)} · ${dateFormat.format(item.date)}',
                          ),
                          trailing: Text(
                            item.amount.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
