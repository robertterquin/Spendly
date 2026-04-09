import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/auth/domain/user_model.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  GoTrueClient get _auth => _client.auth;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    return UserModel(
      id: user.id,
      name: name,
      email: email,
    );
  }

  Future<UserModel> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Invalid email or password.');
    }

    final name = user.userMetadata?['name'] as String? ?? '';
    return UserModel(
      id: user.id,
      name: name,
      email: user.email ?? email,
    );
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final name = user.userMetadata?['name'] as String? ?? '';
    return UserModel(
      id: user.id,
      name: name,
      email: user.email ?? '',
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _auth.resetPasswordForEmail(email);
  }
}
