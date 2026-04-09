import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:spendly/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendly/features/transactions/data/transaction_repository.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<List<TransactionModel>> {
  TransactionRepository get _repo => ref.read(transactionRepositoryProvider);

  @override
  Future<List<TransactionModel>> build() async {
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return [];
    return _repo.getTransactions(user.id);
  }

  Future<void> add(TransactionModel transaction) async {
    await _repo.addTransaction(transaction);
    // Adjust account balance if an account is linked
    if (transaction.accountId != null) {
      final adjustment = transaction.isIncome
          ? transaction.amount
          : -transaction.amount;
      await ref
          .read(accountsProvider.notifier)
          .adjustBalance(transaction.accountId!, adjustment);
    }
    ref.invalidateSelf();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    // Get the old transaction to reverse its effect
    final oldTransactions = state.valueOrNull ?? [];
    final oldTx = oldTransactions.where((t) => t.id == transaction.id).firstOrNull;

    if (oldTx != null && oldTx.accountId != null) {
      // Reverse old transaction effect on old account
      final reversal = oldTx.isIncome ? -oldTx.amount : oldTx.amount;
      await ref
          .read(accountsProvider.notifier)
          .adjustBalance(oldTx.accountId!, reversal);
    }

    await _repo.updateTransaction(transaction);

    // Apply new transaction effect on new account
    if (transaction.accountId != null) {
      final adjustment = transaction.isIncome
          ? transaction.amount
          : -transaction.amount;
      await ref
          .read(accountsProvider.notifier)
          .adjustBalance(transaction.accountId!, adjustment);
    }

    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    // Reverse the transaction effect on account balance
    final transactions = state.valueOrNull ?? [];
    final tx = transactions.where((t) => t.id == id).firstOrNull;
    if (tx != null && tx.accountId != null) {
      final reversal = tx.isIncome ? -tx.amount : tx.amount;
      await ref
          .read(accountsProvider.notifier)
          .adjustBalance(tx.accountId!, reversal);
    }

    await _repo.deleteTransaction(id);
    ref.invalidateSelf();
  }
}
