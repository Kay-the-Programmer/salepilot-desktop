import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/sale.dart';
import 'products_repository.dart';

const _uuid = Uuid();

class SalesRepository {
  SalesRepository({
    required this.api,
    required this.db,
    required this.products,
  });

  final ApiClient api;
  final AppDatabase db;
  final ProductsRepository products;

  /// Builds a Sale with a client-generated transactionId and current timestamp.
  Sale buildSale({
    required List<CartItem> cart,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required double amountPaid,
    required String paymentStatus,
    String? customerId,
    String? customerName,
    double storeCreditUsed = 0,
    double? cashReceived,
    double? changeDue,
    List<Payment> payments = const [],
  }) {
    return Sale(
      transactionId: _uuid.v4(),
      timestamp: DateTime.now().toUtc().toIso8601String(),
      cart: cart,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      total: total,
      amountPaid: amountPaid,
      paymentStatus: paymentStatus,
      storeCreditUsed: storeCreditUsed,
      customerId: customerId,
      customerName: customerName,
      cashReceived: cashReceived,
      changeDue: changeDue,
      payments: payments,
    );
  }

  /// Persists the sale locally + enqueues it for sync, then attempts an
  /// immediate push. The sale is considered "complete" the moment it lands
  /// in local SQLite — sync is best-effort from there.
  Future<Sale> finalizeSale(Sale sale) async {
    final payload = jsonEncode(sale.toJson());

    await db.transaction(() async {
      await db.insertSale(SalesCompanion.insert(
        transactionId: sale.transactionId,
        timestamp: sale.timestamp,
        payloadJson: payload,
        total: sale.total,
        customerName: Value(sale.customerName),
      ));
      await db.enqueueSync(SyncQueueCompanion.insert(
        endpoint: '/sales',
        bodyJson: payload,
        refKey: Value(sale.transactionId),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    });

    // Local stock decrement (best-effort; server is source of truth on re-pull).
    final decrements = <String, double>{};
    for (final item in sale.cart) {
      decrements.update(item.productId, (q) => q + item.quantity, ifAbsent: () => item.quantity);
    }
    await products.decrementLocalStock(decrements);

    return sale;
  }

  /// Try to push a single queue entry. Returns true on success.
  /// Treats 200/201/2xx and 409 (already exists / idempotent conflict) as success.
  Future<bool> pushQueueEntry(SyncQueueRow entry) async {
    try {
      await api.post(entry.endpoint, body: jsonDecode(entry.bodyJson));
      if (entry.refKey != null) {
        await db.markSaleSynced(entry.refKey!);
      }
      await db.deleteSyncEntry(entry.id);
      return true;
    } on ApiException catch (e) {
      // Idempotency: 409 means server has this transaction already.
      if (e.statusCode == 409) {
        if (entry.refKey != null) {
          await db.markSaleSynced(entry.refKey!);
        }
        await db.deleteSyncEntry(entry.id);
        return true;
      }
      // 4xx other than 409 → likely a data bug; retry with long backoff anyway.
      final next = _nextAttempt(entry.retries + 1);
      await db.updateSyncFailure(entry.id, e.message, next);
      return false;
    } catch (e) {
      final next = _nextAttempt(entry.retries + 1);
      await db.updateSyncFailure(entry.id, e.toString(), next);
      return false;
    }
  }

  static int _nextAttempt(int retries) {
    // Exponential backoff capped at 5 minutes.
    final seconds = (1 << retries).clamp(2, 300);
    return DateTime.now().millisecondsSinceEpoch + seconds * 1000;
  }
}
