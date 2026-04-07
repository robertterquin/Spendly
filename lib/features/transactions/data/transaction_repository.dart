import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/features/transactions/domain/transaction_model.dart';

class TransactionRepository {
  static const _transactionsKey = 'transactions';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final prefs = await _prefs;
    final data = prefs.getString(_transactionsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .cast<Map<String, dynamic>>()
        .map(TransactionModel.fromJson)
        .where((t) => t.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final prefs = await _prefs;
    final data = prefs.getString(_transactionsKey);
    final list = data != null
        ? (jsonDecode(data) as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    list.add(transaction.toJson());
    await prefs.setString(_transactionsKey, jsonEncode(list));
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final prefs = await _prefs;
    final data = prefs.getString(_transactionsKey);
    if (data == null) return;
    final list = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
    final index = list.indexWhere((t) => t['id'] == transaction.id);
    if (index != -1) {
      list[index] = transaction.toJson();
      await prefs.setString(_transactionsKey, jsonEncode(list));
    }
  }

  Future<void> deleteTransaction(String id) async {
    final prefs = await _prefs;
    final data = prefs.getString(_transactionsKey);
    if (data == null) return;
    final list = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
    list.removeWhere((t) => t['id'] == id);
    await prefs.setString(_transactionsKey, jsonEncode(list));
  }
}
