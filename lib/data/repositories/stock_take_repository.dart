import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'products_repository.dart';

/// Coordinates a cycle-count session.
///
/// The session is stored entirely in the local DB (the `stock_take_items`
/// table) — no server round-trip needed to start or update counts. On
/// finalize, each variance is converted into a regular stock adjustment
/// that goes through the existing offline-first sync pipeline.
///
/// Why client-side state instead of using the backend's stock-take API:
///   - Works fully offline (you can count for an hour with no network and
///     finalize once you're back online).
///   - Each finalized item benefits from the existing audit log + retry
///     semantics already built for `adjustStock`.
///   - Server-side stock take state is reserved for cross-device sessions,
///     which isn't a current requirement.
class StockTakeRepository {
  StockTakeRepository({required this.db, required this.products});

  final AppDatabase db;
  final ProductsRepository products;

  /// Watch all rows in the active session. Empty list = no active session.
  Stream<List<StockTakeItemRow>> watch() => db.watchStockTakeItems();

  /// True when there's an in-progress session.
  Future<bool> hasActiveSession() async =>
      (await db.stockTakeItemCount()) > 0;

  /// Start a fresh session — clears any prior state and seeds with the
  /// current snapshot of active products.
  Future<void> start() async {
    final all = await products.listActive();
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = all
        .map((p) => StockTakeItemsCompanion.insert(
              productId: p.id,
              productName: p.name,
              productSku: p.sku,
              expectedQty: p.stock,
              unitOfMeasure: Value(p.unitOfMeasure),
              sessionStartedAt: now,
            ))
        .toList();
    await db.seedStockTakeItems(rows);
  }

  /// Record (or update) the counted quantity for a product.
  Future<void> recordCount(String productId, double counted) =>
      db.recordStockTakeCount(productId, counted);

  /// Reset a single product's count back to "not counted".
  Future<void> clearCount(String productId) =>
      db.clearStockTakeItem(productId);

  /// Discard the entire session.
  Future<void> cancel() => db.clearStockTakeItems();

  /// Apply each counted variance as a stock adjustment with reason
  /// `Stock Count`. The variances are committed sequentially so the local
  /// audit log shows one entry per product. Returns a summary of the work.
  Future<StockTakeSummary> finalize() async {
    final items = await db.allStockTakeItems();
    int applied = 0;
    int skippedNoChange = 0;
    int skippedNotCounted = 0;
    double totalDeltaUp = 0;
    double totalDeltaDown = 0;

    for (final item in items) {
      final counted = item.countedQty;
      if (counted == null) {
        skippedNotCounted++;
        continue;
      }
      if (counted == item.expectedQty) {
        skippedNoChange++;
        continue;
      }
      await products.adjustStock(
        productId: item.productId,
        newAbsoluteStock: counted,
        reason: 'Stock Count',
      );
      applied++;
      final delta = counted - item.expectedQty;
      if (delta > 0) {
        totalDeltaUp += delta;
      } else {
        totalDeltaDown += delta.abs();
      }
    }

    await db.clearStockTakeItems();

    return StockTakeSummary(
      applied: applied,
      skippedNoChange: skippedNoChange,
      skippedNotCounted: skippedNotCounted,
      totalDeltaUp: totalDeltaUp,
      totalDeltaDown: totalDeltaDown,
    );
  }
}

/// Result of finalizing a stock take — surfaced to the user as a toast/dialog.
class StockTakeSummary {
  const StockTakeSummary({
    required this.applied,
    required this.skippedNoChange,
    required this.skippedNotCounted,
    required this.totalDeltaUp,
    required this.totalDeltaDown,
  });

  /// Number of adjustments enqueued.
  final int applied;

  /// Items where counted == expected (no change needed).
  final int skippedNoChange;

  /// Items the user didn't enter a count for.
  final int skippedNotCounted;

  /// Sum of positive deltas (extra inventory found).
  final double totalDeltaUp;

  /// Sum of |negative deltas| (shrinkage / missing inventory).
  final double totalDeltaDown;
}
