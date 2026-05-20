import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  SecureStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user_json';
  static const _kApiBase = 'api_base_url';

  Future<String?> readToken() => _storage.read(key: _kToken);
  Future<void> writeToken(String token) => _storage.write(key: _kToken, value: token);
  Future<void> deleteToken() => _storage.delete(key: _kToken);

  Future<String?> readUserJson() => _storage.read(key: _kUser);
  Future<void> writeUserJson(String json) => _storage.write(key: _kUser, value: json);
  Future<void> deleteUserJson() => _storage.delete(key: _kUser);

  Future<String?> readApiBase() => _storage.read(key: _kApiBase);
  Future<void> writeApiBase(String url) => _storage.write(key: _kApiBase, value: url);

  Future<void> clearAuth() async {
    await deleteToken();
    await deleteUserJson();
  }
}
