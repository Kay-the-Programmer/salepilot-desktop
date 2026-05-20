import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../data/api/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/storage/secure_store.dart';

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());

final apiBaseUrlProvider = StateProvider<String>((ref) => AppConfig.defaultApiBaseUrl);

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final store = ref.watch(secureStoreProvider);
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return ApiClient(
    baseUrl: baseUrl,
    tokenProvider: () => store.readToken(),
    onUnauthorized: () async {
      await store.clearAuth();
      ref.read(authStateProvider.notifier).clear();
    },
  );
});

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(api: ref.watch(apiClientProvider), store: ref.watch(secureStoreProvider));
});

class AuthState {
  const AuthState({this.session, this.loading = false, this.error});
  final AuthSession? session;
  final bool loading;
  final String? error;

  bool get isAuthed => session != null;

  AuthState copyWith({AuthSession? session, bool? loading, String? error, bool clearError = false, bool clearSession = false}) {
    return AuthState(
      session: clearSession ? null : (session ?? this.session),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<void> restore() async {
    final session = await _repo.restoreSession();
    if (session != null) state = state.copyWith(session: session);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final session = await _repo.login(email: email, password: password);
      state = AuthState(session: session);
    } on ApiException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState();
  }

  void clear() {
    state = const AuthState();
  }
}

final StateNotifierProvider<AuthController, AuthState> authStateProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
