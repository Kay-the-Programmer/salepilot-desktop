import 'dart:convert';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/store_settings.dart';

class SettingsRepository {
  SettingsRepository({required this.api, required this.db});
  final ApiClient api;
  final AppDatabase db;

  static const _key = 'store_settings_json';

  Future<StoreSettings> load() async {
    final raw = await db.getSetting(_key);
    if (raw == null) return StoreSettings();
    try {
      return StoreSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return StoreSettings();
    }
  }

  Future<StoreSettings> pullFromServer() async {
    try {
      final res = await api.get('/settings');
      Map<String, dynamic> json;
      if (res is Map) {
        json = Map<String, dynamic>.from(res);
      } else {
        json = const {};
      }
      final settings = StoreSettings.fromJson(json);
      await db.setSetting(_key, jsonEncode(settings.toJson()));
      return settings;
    } on ApiException {
      // Endpoint may not exist or user lacks permission — fall back to defaults
      return load();
    }
  }
}
