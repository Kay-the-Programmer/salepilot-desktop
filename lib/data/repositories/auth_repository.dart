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

  /// Exchange a Firebase ID token (from the desktop Google flow) for an app
  /// session. The backend's POST /auth/google returns a flattened camelCase
  /// user with the app token embedded as `token` (not `{token, user}` like
  /// /auth/login), so parse it from the single object.
  Future<AuthSession> loginWithGoogle({required String idToken, String? role}) async {
    final res = await api.post('/auth/google', body: {
      'idToken': idToken,
      ?'role': role,
    });
    if (res is! Map) {
      throw ApiException(null, 'Unexpected Google login response');
    }
    final map = Map<String, dynamic>.from(res);
    final token = map['token']?.toString();
    if (token == null || token.isEmpty) {
      throw ApiException(null, 'Invalid Google login response');
    }
    final user = AppUser.fromJson(map);
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
