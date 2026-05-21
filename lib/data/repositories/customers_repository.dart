import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/customer.dart';

const _uuid = Uuid();

class CustomersRepository {
  CustomersRepository({required this.api, required this.db});
  final ApiClient api;
  final AppDatabase db;

  Stream<List<Customer>> watchAll() => db.watchCustomers().map(
        (rows) => rows
            .map((r) => Customer(
                  id: r.id,
                  name: r.name,
                  email: r.email,
                  phone: r.phone,
                  storeCredit: r.storeCredit,
                  accountBalance: r.accountBalance,
                ))
            .toList(),
      );

  /// Creates a customer on the server. The local cache is updated with the
  /// server-issued ID so subsequent lookups by ID work everywhere.
  ///
  /// Offline behavior: if the server is unreachable, we insert a local-only
  /// row with a client-generated `local-*` ID so the cashier can attach this
  /// customer to the current sale immediately. The server reconciliation on
  /// the next pull will replace it with the canonical record (the local one
  /// remains harmless; sales just carry whichever ID they were tagged with).
  Future<Customer> createCustomer({
    required String name,
    String? email,
    String? phone,
  }) async {
    final body = {
      'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };
    try {
      final res = await api.post('/customers', body: body);
      final json = res is Map ? Map<String, dynamic>.from(res) : (res is Map && res['data'] is Map ? Map<String, dynamic>.from(res['data'] as Map) : <String, dynamic>{});
      // Some servers wrap responses in {data: {...}}.
      final inner = (json['data'] is Map) ? Map<String, dynamic>.from(json['data'] as Map) : json;
      final created = Customer.fromJson(inner.isEmpty ? body : inner);
      await db.upsertCustomers([
        CustomersCompanion.insert(
          id: created.id.isEmpty ? 'local-${_uuid.v4()}' : created.id,
          name: created.name,
          email: Value(created.email),
          phone: Value(created.phone),
          storeCredit: Value(created.storeCredit),
          accountBalance: Value(created.accountBalance),
        ),
      ]);
      return created;
    } on ApiException {
      // Fall back to local-only insert.
      final localId = 'local-${_uuid.v4()}';
      final fallback = Customer(id: localId, name: name, email: email, phone: phone);
      await db.upsertCustomers([
        CustomersCompanion.insert(
          id: localId,
          name: name,
          email: Value(email),
          phone: Value(phone),
        ),
      ]);
      return fallback;
    }
  }

  Future<int> pullFromServer() async {
    final res = await api.get('/customers');
    final list = res is List
        ? res
        : (res is Map && res['data'] is List)
            ? res['data'] as List
            : const [];
    final rows = list.map((j) {
      final c = Customer.fromJson(Map<String, dynamic>.from(j as Map));
      return CustomersCompanion.insert(
        id: c.id,
        name: c.name,
        email: Value(c.email),
        phone: Value(c.phone),
        storeCredit: Value(c.storeCredit),
        accountBalance: Value(c.accountBalance),
      );
    }).toList();
    await db.upsertCustomers(rows);
    return rows.length;
  }
}
