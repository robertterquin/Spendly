import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/features/auth/domain/user_model.dart';

class AuthRepository {
  static const _usersKey = 'registered_users';
  static const _sessionKey = 'current_user';
  static const _rememberKey = 'remember_me';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await _prefs;
    final users = _getUsers(prefs);

    if (users.any((u) => u['email'] == email)) {
      throw Exception('An account with this email already exists.');
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };

    users.add(user);
    await prefs.setString(_usersKey, jsonEncode(users));

    return UserModel.fromJson(user);
  }

  Future<UserModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final prefs = await _prefs;
    final users = _getUsers(prefs);

    final match = users.where(
      (u) => u['email'] == email && u['password'] == password,
    );

    if (match.isEmpty) {
      throw Exception('Invalid email or password.');
    }

    final userData = match.first;
    await prefs.setString(_sessionKey, jsonEncode(userData));
    await prefs.setBool(_rememberKey, rememberMe);

    return UserModel.fromJson(userData);
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await _prefs;
    final data = prefs.getString(_sessionKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionKey);
    await prefs.remove(_rememberKey);
  }

  Future<void> sendPasswordReset({required String email}) async {
    final prefs = await _prefs;
    final users = _getUsers(prefs);

    if (!users.any((u) => u['email'] == email)) {
      throw Exception('No account found with this email.');
    }

    // In a real app this would send an email.
    // For now we just validate the email exists.
  }

  List<Map<String, dynamic>> _getUsers(SharedPreferences prefs) {
    final data = prefs.getString(_usersKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.cast<Map<String, dynamic>>();
  }
}
