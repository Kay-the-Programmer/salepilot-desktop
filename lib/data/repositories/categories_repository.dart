import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/category.dart';

const _uuid = Uuid();

class CategoriesRepository {
  CategoriesRepository({required this.api, required this.db});
  final ApiClient api;
  final AppDatabase db;

  Stream<List<Category>> watchAll() => db.watchCategories().map(
        (rows) => rows
            .map((r) => Category(
                  id: r.id,
                  name: r.name,
                  parentId: r.parentId,
                ))
            .toList(),
      );

  Future<List<Category>> listAll() async {
    final rows = await db.allCategories();
    return rows
        .map((r) => Category(id: r.id, name: r.name, parentId: r.parentId))
        .toList();
  }

  Future<Category?> findById(String id) async {
    final rows = await db.allCategories();
    for (final r in rows) {
      if (r.id == id) {
        return Category(id: r.id, name: r.name, parentId: r.parentId);
      }
    }
    return null;
  }

  Future<int> pullFromServer() async {
    final res = await api.get('/categories');
    final list = res is List
        ? res
        : (res is Map && res['data'] is List)
            ? res['data'] as List
            : const [];
    final rows = list.map((j) {
      final c = Category.fromJson(Map<String, dynamic>.from(j as Map));
      return CategoriesCompanion.insert(
        id: c.id,
        name: c.name,
        parentId: Value(c.parentId),
      );
    }).toList();
    await db.upsertCategories(rows);
    return rows.length;
  }

  /// Create a new category. Online: server creates + we upsert the returned
  /// row. Offline: fall back to a local-only row with `local-*` id so the
  /// user can attach it immediately; reconciliation happens on next pull.
  Future<Category> createCategory({required String name}) async {
    final body = {'name': name};
    try {
      final res = await api.post('/categories', body: body);
      final json = res is Map
          ? Map<String, dynamic>.from(res)
          : <String, dynamic>{};
      final inner = (json['data'] is Map)
          ? Map<String, dynamic>.from(json['data'] as Map)
          : json;
      final created = Category.fromJson(inner.isEmpty ? body : inner);
      final id = created.id.isEmpty ? 'local-${_uuid.v4()}' : created.id;
      await db.upsertCategories([
        CategoriesCompanion.insert(
          id: id,
          name: created.name,
          parentId: Value(created.parentId),
        ),
      ]);
      return Category(id: id, name: created.name, parentId: created.parentId);
    } on ApiException {
      final localId = 'local-${_uuid.v4()}';
      await db.upsertCategories([
        CategoriesCompanion.insert(id: localId, name: name),
      ]);
      return Category(id: localId, name: name);
    }
  }
}
