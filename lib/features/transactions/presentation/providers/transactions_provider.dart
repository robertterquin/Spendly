import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    ref.invalidateSelf();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repo.updateTransaction(transaction);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await _repo.deleteTransaction(id);
    ref.invalidateSelf();
  }
}
