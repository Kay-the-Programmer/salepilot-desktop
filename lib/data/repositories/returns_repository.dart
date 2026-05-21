import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../db/app_database.dart';
import '../models/return_record.dart';
import '../models/sale.dart';
import 'products_repository.dart';

const _uuid = Uuid();

class ReturnsRepository {
  ReturnsRepository({required this.api, required this.db, required this.products});

  final ApiClient api;
  final AppDatabase db;
  final ProductsRepository products;

  /// Look up a sale by transactionId in the local cache. Returns null if not
  /// known locally (the desktop cache only holds recent sales).
  Future<Sale?> findLocalSale(String transactionId) async {
    final rows = await db.recentSales(limit: 1000);
    for (final r in rows) {
      if (r.transactionId == transactionId) {
        try {
          final json = jsonDecode(r.payloadJson) as Map<String, dynamic>;
          return _saleFromJson(json);
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  /// Returns the most recent sales held in the local cache.
  Future<List<Sale>> recentSales({int limit = 50}) async {
    final rows = await db.recentSales(limit: limit);
    final list = <Sale>[];
    for (final r in rows) {
      try {
        list.add(_saleFromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>));
      } catch (_) {/* skip malformed */}
    }
    return list;
  }

  /// Persist + enqueue a return. Updates local stock for restocked items,
  /// annotates the original sale's payload with refund metadata, and queues
  /// a `POST /returns` request for the sync engine to drain.
  Future<ReturnRecord> createReturn({
    required Sale originalSale,
    required List<ReturnLineItem> items,
    required double taxRefund,
    required String refundMethod,
    DateTime? when,
  }) async {
    final ts = (when ?? DateTime.now()).toUtc().toIso8601String();
    final subtotal = items.fold<double>(0, (s, i) => s + i.lineRefund);
    final refundTotal = subtotal + taxRefund;
    final record = ReturnRecord(
      id: _uuid.v4(),
      originalSaleId: originalSale.transactionId,
      timestamp: ts,
      returnedItems: items,
      subtotalAmount: subtotal,
      taxAmount: taxRefund,
      refundAmount: refundTotal,
      refundMethod: refundMethod,
    );

    await db.transaction(() async {
      // 1) Mark the original sale as returned (full/partial) in the local cache.
      final newPayload = _annotateSaleWithReturn(originalSale, record);
      final originalRefund = (originalSale.toJson()['totalRefunded'] as num? ?? 0).toDouble();
      final isFully = (originalRefund + refundTotal) >= originalSale.total - 1e-6;
      await db.customUpdate(
        'UPDATE sales SET payload_json = ? WHERE transaction_id = ?',
        variables: [
          Variable.withString(newPayload),
          Variable.withString(originalSale.transactionId),
        ],
        updates: {db.sales},
      );
      // 2) Queue the server POST.
      await db.enqueueSync(SyncQueueCompanion.insert(
        endpoint: '/returns',
        bodyJson: jsonEncode(record.toJson()),
        refKey: Value('return-${record.id}'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
      // (Surface to logger: which sale this affects.)
      // No-op return value to keep the closure happy.
      // ignore: unused_local_variable
      final _ = isFully;
    });

    // 3) Restock locally for items the cashier marked as addToStock.
    final restocks = <String, double>{};
    for (final item in items.where((i) => i.addToStock)) {
      restocks.update(item.productId, (q) => q + item.quantity, ifAbsent: () => item.quantity);
    }
    await products.incrementLocalStock(restocks);

    return record;
  }

  String _annotateSaleWithReturn(Sale sale, ReturnRecord r) {
    final json = sale.toJson();
    final prevRefund = (json['totalRefunded'] as num? ?? 0).toDouble();
    final newRefund = prevRefund + r.refundAmount;
    json['totalRefunded'] = newRefund;
    json['originalTotal'] ??= sale.total;
    json['refundStatus'] = newRefund >= sale.total - 1e-6 ? 'fully_refunded' : 'partially_refunded';
    return jsonEncode(json);
  }

  Sale _saleFromJson(Map<String, dynamic> j) {
    double td(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    final cartRaw = (j['cart'] as List?) ?? const [];
    return Sale(
      transactionId: (j['transactionId'] ?? '').toString(),
      timestamp: (j['timestamp'] ?? '').toString(),
      cart: cartRaw.map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      subtotal: td(j['subtotal']),
      tax: td(j['tax']),
      discount: td(j['discount']),
      total: td(j['total']),
      amountPaid: td(j['amountPaid']),
      paymentStatus: (j['paymentStatus'] ?? 'paid').toString(),
      storeCreditUsed: td(j['storeCreditUsed']),
      customerId: j['customerId']?.toString(),
      customerName: j['customerName']?.toString(),
      cashReceived: j['cashReceived'] == null ? null : td(j['cashReceived']),
      changeDue: j['changeDue'] == null ? null : td(j['changeDue']),
      payments: const [],
    );
  }
}
