import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class ChartCategoryData {
  const ChartCategoryData({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  final String category;
  final double amount;
  final double percentage;
}

class ChartSummary {
  const ChartSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
    required this.incomeByCategory,
  });

  final double totalIncome;
  final double totalExpense;
  final List<ChartCategoryData> expenseByCategory;
  final List<ChartCategoryData> incomeByCategory;
}

final chartDataProvider = Provider<AsyncValue<ChartSummary>>((ref) {
  final txState = ref.watch(transactionsProvider);
  return txState.when(
    data: (transactions) {
      final now = DateTime.now();
      final monthTx = transactions
          .where((t) => t.date.month == now.month && t.date.year == now.year);

      final totalIncome = monthTx
          .where((t) => t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = monthTx
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);

      final expenseByCategory =
          _groupByCategory(monthTx.where((t) => t.isExpense).toList());
      final incomeByCategory =
          _groupByCategory(monthTx.where((t) => t.isIncome).toList());

      return AsyncData(ChartSummary(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        expenseByCategory: expenseByCategory,
        incomeByCategory: incomeByCategory,
      ));
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});

List<ChartCategoryData> _groupByCategory(List<TransactionModel> transactions) {
  if (transactions.isEmpty) return [];

  final map = <String, double>{};
  for (final tx in transactions) {
    map[tx.category] = (map[tx.category] ?? 0) + tx.amount;
  }

  final total = map.values.fold(0.0, (a, b) => a + b);

  final list = map.entries
      .map((e) => ChartCategoryData(
            category: e.key,
            amount: e.value,
            percentage: total > 0 ? (e.value / total) * 100 : 0,
          ))
      .toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return list;
}
