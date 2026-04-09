import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/accounts/domain/account_model.dart';

class AccountRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AccountModel>> getAccounts(String userId) async {
    final data = await _client
        .from('accounts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(AccountModel.fromJson)
        .toList();
  }

  Future<void> addAccount(AccountModel account) async {
    await _client.from('accounts').insert(account.toJson());
  }

  Future<void> updateAccount(AccountModel account) async {
    await _client
        .from('accounts')
        .update(account.toJson())
        .eq('id', account.id);
  }

  Future<void> deleteAccount(String id) async {
    await _client.from('accounts').delete().eq('id', id);
  }
}
