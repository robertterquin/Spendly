import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class CategorySpending {
  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  final String category;
  final double amount;
  final double percentage;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
    this.topExpenseCategories = const <CategorySpending>[],
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionModel> recentTransactions;
  final List<CategorySpending> topExpenseCategories;
}

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final txState = ref.watch(transactionsProvider);
  final totalAccountsBalance = ref.watch(totalAccountsBalanceProvider);
  return txState.when(
    data: (transactions) {
      final now = DateTime.now();
      final monthTx = transactions.where((t) =>
          t.date.month == now.month && t.date.year == now.year);

      final totalIncome = monthTx
          .where((t) => t.isIncome)
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = monthTx
          .where((t) => t.isExpense)
          .fold(0.0, (sum, t) => sum + t.amount);

      final expenseMap = <String, double>{};
      for (final t in monthTx.where((t) => t.isExpense)) {
        expenseMap[t.category] = (expenseMap[t.category] ?? 0) + t.amount;
      }
      final sorted = expenseMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final List<CategorySpending> topCategories = sorted.take(4).map<CategorySpending>((e) => CategorySpending(
            category: e.key,
            amount: e.value,
            percentage: totalExpense > 0 ? (e.value / totalExpense) * 100 : 0.0,
          )).toList();

      return AsyncData(DashboardSummary(
        totalBalance: totalAccountsBalance,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        recentTransactions: transactions.take(5).toList(),
        topExpenseCategories: topCategories,
      ));
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});
