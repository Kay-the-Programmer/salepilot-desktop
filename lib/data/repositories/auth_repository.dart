import 'dart:convert';

import '../api/api_client.dart';
import '../models/user.dart';
import '../storage/secure_store.dart';

class AuthSession {
  AuthSession({required this.user, required this.token});
  final AppUser user;
  final String token;
}

class AuthRepository {
  AuthRepository({required this.api, required this.store});

  final ApiClient api;
  final SecureStore store;

  Future<AuthSession> login({required String email, required String password}) async {
    final res = await api.post('/auth/login', body: {'email': email, 'password': password});
    if (res is! Map) {
      throw ApiException(null, 'Unexpected login response');
    }
    final token = res['token']?.toString();
    final userJson = res['user'];
    if (token == null || token.isEmpty || userJson is! Map) {
      throw ApiException(null, 'Invalid login response');
    }
    final user = AppUser.fromJson(Map<String, dynamic>.from(userJson));
    await store.writeToken(token);
    await store.writeUserJson(jsonEncode(user.toJson()));
    return AuthSession(user: user, token: token);
  }

  Future<AuthSession?> restoreSession() async {
    final token = await store.readToken();
    final userRaw = await store.readUserJson();
    if (token == null || token.isEmpty || userRaw == null) return null;
    try {
      final user = AppUser.fromJson(jsonDecode(userRaw) as Map<String, dynamic>);
      return AuthSession(user: user, token: token);
    } catch (_) {
      await store.clearAuth();
      return null;
    }
  }

  Future<AppUser> fetchMe() async {
    final res = await api.get('/auth/me');
    if (res is! Map) {
      throw ApiException(null, 'Unexpected /auth/me response');
    }
    return AppUser.fromJson(Map<String, dynamic>.from(res));
  }

  Future<void> logout() => store.clearAuth();
}
