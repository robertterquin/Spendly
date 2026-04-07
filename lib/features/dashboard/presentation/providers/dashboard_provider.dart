import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';
import 'package:spendly/features/transactions/presentation/providers/transactions_provider.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionModel> recentTransactions;
}

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final txState = ref.watch(transactionsProvider);
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

      return AsyncData(DashboardSummary(
        totalBalance: totalIncome - totalExpense,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        recentTransactions: transactions.take(5).toList(),
      ));
    },
    loading: () => const AsyncLoading(),
    error: (e, st) => AsyncError(e, st),
  );
});
