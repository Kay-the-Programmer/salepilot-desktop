class AppConfig {
  static const String defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  static const String renderApiBaseUrl = 'https://s-back-q0gg.onrender.com/api';

  static const String appName = 'SalePilot POS';
  static const Duration apiTimeout = Duration(seconds: 20);

  // ---------------------------------------------------------------------------
  // Google / Firebase sign-in.
  //
  // Firebase project: `salepilot-ae09f` (shared with the web/mobile apps and the
  // s-back backend). FIREBASE_API_KEY below defaults to that project's Web API
  // key — the same one the backend verifies tokens against — so it needs no
  // override (Firebase Web API keys are not secrets).
  //
  // The desktop loopback flow needs its OWN OAuth client of type *Desktop app*
  // in project `salepilot-ae09f` — the existing Web/iOS/Android clients won't
  // work (Web clients reject loopback random-port redirects). Create one in the
  // Google Cloud Console, then supply it at build/run time so it isn't committed:
  //
  //   flutter run -d windows \
  //     --dart-define=GOOGLE_OAUTH_CLIENT_ID=xxxx.apps.googleusercontent.com \
  //     --dart-define=GOOGLE_OAUTH_CLIENT_SECRET=yyyy
  //
  // Because the client lives in the same project, Firebase's signInWithIdp
  // accepts its id tokens automatically.
  // ---------------------------------------------------------------------------
  static const String googleOAuthClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_ID',
    defaultValue: '',
  );

  static const String googleOAuthClientSecret = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_SECRET',
    defaultValue: '',
  );

  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBqcS-rap5P5jRl7nhfdESKWEJtZb4Zy8c',
  );

  /// True when the desktop Google sign-in flow has everything it needs.
  static bool get googleSignInConfigured =>
      googleOAuthClientId.isNotEmpty && firebaseApiKey.isNotEmpty;
}
