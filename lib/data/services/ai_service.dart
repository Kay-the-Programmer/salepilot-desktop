import '../api/api_client.dart';

/// Thin client wrapper around the backend's `/ai/*` endpoints.
///
/// AI calls are online-only by design — they need the Gemini upstream and
/// don't make sense to queue. Callers should gate their UI on the sync
/// engine's `online` flag and handle [ApiException] gracefully.
class AiService {
  AiService({required this.api});

  final ApiClient api;

  /// Ask Gemini to write a 2-3 sentence marketing description for a product.
  /// Returns the description text, trimmed. Throws [ApiException] on
  /// network/quota errors so callers can show a useful message.
  ///
  /// The backend logs usage against the current user/store, so we don't
  /// pass any extra metadata.
  Future<String> generateDescription({
    required String productName,
    String? category,
  }) async {
    final body = {
      'productName': productName,
      'category':
          ?((category != null && category.isNotEmpty) ? category : null),
    };
    final res = await api.post('/ai/generate-description', body: body);
    if (res is Map && res['description'] is String) {
      return (res['description'] as String).trim();
    }
    // Some servers wrap as {data: {description: ...}}.
    if (res is Map && res['data'] is Map) {
      final inner = res['data'] as Map;
      if (inner['description'] is String) {
        return (inner['description'] as String).trim();
      }
    }
    throw ApiException(null, 'Unexpected AI response format');
  }

  /// Free-form chat against the store context. Returns the assistant's reply
  /// text. The backend tracks history server-side per session, so we don't
  /// need to thread it through here for a one-shot ask.
  Future<String> chat({
    required String query,
    Map<String, dynamic>? context,
  }) async {
    final res = await api.post('/ai/chat', body: {
      'query': query,
      'context': ?context,
    });
    if (res is Map) {
      // Common response shapes the backend uses.
      for (final key in ['reply', 'answer', 'message', 'text']) {
        if (res[key] is String) return (res[key] as String).trim();
      }
      if (res['data'] is Map) {
        final inner = res['data'] as Map;
        for (final key in ['reply', 'answer', 'message', 'text']) {
          if (inner[key] is String) return (inner[key] as String).trim();
        }
      }
    }
    throw ApiException(null, 'Unexpected AI chat response');
  }
}
