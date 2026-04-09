import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';

class TransactionRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final data = await _client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .toList();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _client.from('transactions').insert(transaction.toJson());
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _client
        .from('transactions')
        .update(transaction.toJson())
        .eq('id', transaction.id);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.from('transactions').delete().eq('id', id);
  }
}
