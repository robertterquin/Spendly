import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/auth/data/auth_repository.dart';
import 'package:spendly/features/auth/domain/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() => const AsyncData(null);

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> checkSession() async {
    state = const AsyncLoading();
    try {
      final user = await _repo.getCurrentUser();
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await _repo.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      state = AsyncData(user);
    } on AuthException catch (e) {
      state = AsyncError(Exception(e.message), StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.register(
        name: name,
        email: email,
        password: password,
      );
      state = const AsyncData(null);
    } on AuthException catch (e) {
      state = AsyncError(Exception(e.message), StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = const AsyncLoading();
    try {
      await _repo.sendPasswordReset(email: email);
      state = const AsyncData(null);
    } on AuthException catch (e) {
      state = AsyncError(Exception(e.message), StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
  }

  Future<void> updateProfile({required String name}) async {
    try {
      final user = await _repo.updateProfile(name: name);
      state = AsyncData(user);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _repo.updatePassword(newPassword: newPassword);
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }
}
