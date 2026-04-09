import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/accounts/data/account_repository.dart';
import 'package:spendly/features/accounts/domain/account_model.dart';
import 'package:spendly/features/auth/presentation/providers/auth_provider.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<AccountModel>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<AccountModel>> {
  AccountRepository get _repo => ref.read(accountRepositoryProvider);

  @override
  Future<List<AccountModel>> build() async {
    final user = ref.watch(authProvider).valueOrNull;
    if (user == null) return <AccountModel>[];
    return _repo.getAccounts(user.id);
  }

  Future<void> add(AccountModel account) async {
    await _repo.addAccount(account);
    ref.invalidateSelf();
  }

  Future<void> updateAccount(AccountModel account) async {
    await _repo.updateAccount(account);
    ref.invalidateSelf();
  }

  Future<void> adjustBalance(String accountId, double amount) async {
    final accounts = state.valueOrNull ?? <AccountModel>[];
    final account = accounts.firstWhere((a) => a.id == accountId);
    final updated = account.copyWith(balance: account.balance + amount);
    await _repo.updateAccount(updated);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await _repo.deleteAccount(id);
    ref.invalidateSelf();
  }
}

final totalAccountsBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? <AccountModel>[];
  return accounts.fold(0.0, (sum, a) => sum + a.balance);
});
