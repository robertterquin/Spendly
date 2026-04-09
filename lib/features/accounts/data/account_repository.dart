import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/features/accounts/domain/account_model.dart';

class AccountRepository {
  static const _accountsKey = 'accounts';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<AccountModel>> getAccounts(String userId) async {
    final prefs = await _prefs;
    final data = prefs.getString(_accountsKey);
    if (data == null) return <AccountModel>[];
    final list = jsonDecode(data) as List;
    return list
        .cast<Map<String, dynamic>>()
        .map(AccountModel.fromJson)
        .where((a) => a.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addAccount(AccountModel account) async {
    final prefs = await _prefs;
    final data = prefs.getString(_accountsKey);
    final list = data != null
        ? (jsonDecode(data) as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    list.add(account.toJson());
    await prefs.setString(_accountsKey, jsonEncode(list));
  }

  Future<void> updateAccount(AccountModel account) async {
    final prefs = await _prefs;
    final data = prefs.getString(_accountsKey);
    if (data == null) return;
    final list = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
    final index = list.indexWhere((a) => a['id'] == account.id);
    if (index != -1) {
      list[index] = account.toJson();
      await prefs.setString(_accountsKey, jsonEncode(list));
    }
  }

  Future<void> deleteAccount(String id) async {
    final prefs = await _prefs;
    final data = prefs.getString(_accountsKey);
    if (data == null) return;
    final list = (jsonDecode(data) as List).cast<Map<String, dynamic>>();
    list.removeWhere((a) => a['id'] == id);
    await prefs.setString(_accountsKey, jsonEncode(list));
  }
}
