import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../data/models/product.dart';

enum StockFilter {
  all,
  lowStock,
  outOfStock,
  inStock,
  archived,
}

class InventoryState {
  const InventoryState({
    this.query = '',
    this.filter = StockFilter.all,
  });

  final String query;
  final StockFilter filter;

  InventoryState copyWith({String? query, StockFilter? filter}) =>
      InventoryState(
        query: query ?? this.query,
        filter: filter ?? this.filter,
      );
}

class InventoryController extends StateNotifier<InventoryState> {
  InventoryController() : super(const InventoryState());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setFilter(StockFilter f) => state = state.copyWith(filter: f);
  void clear() => state = const InventoryState();
}

final inventoryControllerProvider =
    StateNotifierProvider<InventoryController, InventoryState>(
        (ref) => InventoryController());

/// Pulls products from the local DB (offline-first), then applies the
/// current search query + stock filter. Reactive — re-emits whenever the
/// underlying product list, query, or filter changes.
final filteredInventoryProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productsRepositoryProvider);
  final filter = ref.watch(inventoryControllerProvider.select((s) => s.filter));
  final query = ref.watch(inventoryControllerProvider.select((s) => s.query));

  // Use watchAll so archived products can be surfaced in their own filter.
  return repo.watchAll().map((products) {
    final q = query.trim().toLowerCase();
    return products.where((p) {
      // Status axis: archived filter shows ONLY archived; all other filters
      // show ONLY active products.
      if (filter == StockFilter.archived) {
        if (p.isActive) return false;
      } else {
        if (!p.isActive) return false;
      }
      // Stock filter (only applies to active products)
      if (filter == StockFilter.outOfStock && p.stock > 0) return false;
      if (filter == StockFilter.lowStock) {
        final reorder = p.reorderPoint;
        if (reorder == null) return false;
        if (p.stock <= 0) return false; // out-of-stock is its own bucket
        if (p.stock > reorder) return false;
      }
      if (filter == StockFilter.inStock && p.stock <= 0) return false;
      // Search filter
      if (q.isNotEmpty) {
        final hit = p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            (p.barcode ?? '').toLowerCase().contains(q) ||
            (p.brand ?? '').toLowerCase().contains(q);
        if (!hit) return false;
      }
      return true;
    }).toList();
  });
});

/// Top-of-screen stats for the inventory dashboard.
class InventoryStats {
  const InventoryStats({
    required this.total,
    required this.lowStock,
    required this.outOfStock,
    required this.totalStockValue,
  });
  final int total;
  final int lowStock;
  final int outOfStock;
  final double totalStockValue;
}

final inventoryStatsProvider = StreamProvider<InventoryStats>((ref) {
  final repo = ref.watch(productsRepositoryProvider);
  return repo.watchActive().map((products) {
    int low = 0;
    int out = 0;
    double value = 0;
    for (final p in products) {
      if (p.stock <= 0) {
        out++;
      } else if (p.reorderPoint != null && p.stock <= p.reorderPoint!) {
        low++;
      }
      value += (p.costPrice ?? p.price) * p.stock;
    }
    return InventoryStats(
      total: products.length,
      lowStock: low,
      outOfStock: out,
      totalStockValue: value,
    );
  });
});

/// Pending stock-adjustment count from the local sync queue.
/// Used to show "N adjustments waiting to sync" hints in the UI.
final pendingStockAdjustmentsProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  // Poll every 3 seconds — sync queue doesn't expose a stream natively but
  // changes infrequently enough that polling is fine.
  return Stream.periodic(const Duration(seconds: 3), (_) => null)
      .asyncMap((_) async {
    final all = await db.dueSyncEntries(now: 1 << 62, limit: 1000);
    return all.where((e) => e.endpoint.startsWith('/products/')).length;
  });
});
