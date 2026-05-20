class AppConfig {
  static const String defaultApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  static const String renderApiBaseUrl = 'https://s-back-q0gg.onrender.com/api';

  static const String appName = 'SalePilot POS';
  static const Duration apiTimeout = Duration(seconds: 20);
}
