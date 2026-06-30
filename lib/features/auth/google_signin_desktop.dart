import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../core/config.dart';
import '../../core/logger.dart';

/// Raised when the desktop Google sign-in flow fails or is cancelled.
class GoogleSignInException implements Exception {
  GoogleSignInException(this.message);
  final String message;
  @override
  String toString() => 'GoogleSignInException: $message';
}

/// Desktop ("Installed app") Google sign-in.
///
/// Flow:
///  1. Start a one-shot loopback HTTP server on 127.0.0.1 (random port).
///  2. Open the system browser to Google's OAuth consent screen with that
///     loopback as the redirect URI.
///  3. Capture the `code` Google redirects back with.
///  4. Exchange the code for a Google ID token at the token endpoint.
///  5. Exchange the Google ID token for a Firebase ID token via the
///     Identity Toolkit `signInWithIdp` endpoint — that's the token shape the
///     backend's POST /auth/google expects.
///
/// Returns the Firebase ID token. The caller posts it to /auth/google.
class GoogleSignInDesktop {
  GoogleSignInDesktop({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _authEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
  static const _tokenEndpoint = 'https://oauth2.googleapis.com/token';

  /// Runs the full flow and returns a Firebase ID token.
  Future<String> obtainFirebaseIdToken() async {
    if (!AppConfig.googleSignInConfigured) {
      throw GoogleSignInException(
        'Google sign-in is not configured. Set GOOGLE_OAUTH_CLIENT_ID '
        '(and secret) via --dart-define.',
      );
    }

    // 1. Loopback server on an OS-assigned free port.
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirectUri = 'http://127.0.0.1:${server.port}';
    final state = _randomString(24);

    try {
      // 2. Open the browser to the consent screen.
      final authUrl = Uri.parse(_authEndpoint).replace(queryParameters: {
        'client_id': AppConfig.googleOAuthClientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': 'openid email profile',
        'state': state,
        'prompt': 'select_account',
      });
      await _openInBrowser(authUrl.toString());

      // 3. Wait for Google to redirect back (2-minute ceiling).
      final code = await _awaitRedirect(server, state)
          .timeout(const Duration(minutes: 2), onTimeout: () {
        throw GoogleSignInException('Timed out waiting for Google sign-in.');
      });

      // 4. Code → Google ID token.
      final googleIdToken = await _exchangeCodeForIdToken(code, redirectUri);

      // 5. Google ID token → Firebase ID token.
      return await _exchangeForFirebaseToken(googleIdToken, redirectUri);
    } finally {
      await server.close(force: true);
    }
  }

  /// Resolves with the `code` query param once the browser hits the loopback.
  Future<String> _awaitRedirect(HttpServer server, String expectedState) async {
    await for (final request in server) {
      final params = request.uri.queryParameters;
      final error = params['error'];
      final code = params['code'];
      final state = params['state'];

      // Respond to the browser so the user sees a friendly closing page.
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write(_closingPageHtml(success: error == null && code != null));
      await request.response.close();

      if (error != null) {
        throw GoogleSignInException('Google denied the request: $error');
      }
      if (state != expectedState) {
        throw GoogleSignInException('State mismatch — possible CSRF, aborting.');
      }
      if (code == null || code.isEmpty) {
        throw GoogleSignInException('No authorization code returned.');
      }
      return code;
    }
    throw GoogleSignInException('Sign-in window closed before completing.');
  }

  Future<String> _exchangeCodeForIdToken(String code, String redirectUri) async {
    try {
      final res = await _dio.post(
        _tokenEndpoint,
        options: Options(contentType: Headers.formUrlEncodedContentType),
        data: {
          'code': code,
          'client_id': AppConfig.googleOAuthClientId,
          if (AppConfig.googleOAuthClientSecret.isNotEmpty)
            'client_secret': AppConfig.googleOAuthClientSecret,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
        },
      );
      final idToken = res.data is Map ? res.data['id_token'] as String? : null;
      if (idToken == null || idToken.isEmpty) {
        throw GoogleSignInException('Google did not return an ID token.');
      }
      return idToken;
    } on DioException catch (e) {
      log.e('Google token exchange failed: ${e.response?.data}');
      throw GoogleSignInException(_dioMessage(e, 'Could not complete Google sign-in.'));
    }
  }

  Future<String> _exchangeForFirebaseToken(
      String googleIdToken, String redirectUri) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=${AppConfig.firebaseApiKey}';
    try {
      final res = await _dio.post(url, data: {
        'postBody': 'id_token=$googleIdToken&providerId=google.com',
        'requestUri': redirectUri,
        'returnIdpCredential': true,
        'returnSecureToken': true,
      });
      final firebaseIdToken =
          res.data is Map ? res.data['idToken'] as String? : null;
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw GoogleSignInException('Firebase did not return an ID token.');
      }
      return firebaseIdToken;
    } on DioException catch (e) {
      log.e('Firebase signInWithIdp failed: ${e.response?.data}');
      throw GoogleSignInException(_dioMessage(e, 'Could not verify Google account.'));
    }
  }

  Future<void> _openInBrowser(String url) async {
    try {
      if (Platform.isWindows) {
        // `start` is a cmd builtin; the empty "" is the window title arg so
        // URLs with spaces/& are handled. runInShell lets cmd resolve it.
        await Process.start('cmd', ['/c', 'start', '', url], runInShell: true);
      } else if (Platform.isMacOS) {
        await Process.start('open', [url]);
      } else {
        await Process.start('xdg-open', [url]);
      }
    } catch (e) {
      throw GoogleSignInException('Could not open the browser for sign-in.');
    }
  }

  String _dioMessage(DioException e, String fallback) {
    final body = e.response?.data;
    if (body is Map && body['error'] is Map && body['error']['message'] is String) {
      return body['error']['message'] as String;
    }
    if (body is Map && body['message'] is String) return body['message'] as String;
    return fallback;
  }

  String _randomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  String _closingPageHtml({required bool success}) {
    final title = success ? 'Signed in' : 'Sign-in failed';
    final body = success
        ? 'You can close this tab and return to SalePilot.'
        : 'Something went wrong. Return to SalePilot and try again.';
    return '''
<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>$title</title>
<style>
  body{font-family:system-ui,Segoe UI,Roboto,sans-serif;background:#0f0e1a;
       color:#fff;display:flex;height:100vh;margin:0;align-items:center;
       justify-content:center;text-align:center}
  .card{background:rgba(255,255,255,.05);padding:40px 48px;border-radius:16px;
        border:1px solid rgba(255,255,255,.1)}
  h1{font-size:20px;margin:0 0 8px}
  p{color:rgba(255,255,255,.7);margin:0}
</style></head>
<body><div class="card"><h1>$title</h1><p>$body</p></div></body></html>''';
  }
}
