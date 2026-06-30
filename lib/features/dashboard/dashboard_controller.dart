import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../data/db/app_database.dart';
import '../../data/models/product.dart';

/// One row in the 7-day sparkline.
class DailyTotal {
  const DailyTotal({required this.date, required this.revenue, required this.count});
  final DateTime date;
  final double revenue;
  final int count;
}

/// Top-product summary, aggregated client-side from sales payloads.
class ProductSales {
  const ProductSales({
    required this.productId,
    required this.name,
    required this.quantitySold,
    required this.revenue,
  });
  final String productId;
  final String name;
  final double quantitySold;
  final double revenue;
}

/// Everything the dashboard needs in one snapshot.
class DashboardStats {
  const DashboardStats({
    required this.todayRevenue,
    required this.todayCount,
    required this.weekRevenue,
    required this.weekCount,
    required this.weeklyTotals,
    required this.topProducts,
    required this.recentSales,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalProducts,
    required this.totalInventoryValue,
  });

  final double todayRevenue;
  final int todayCount;
  final double weekRevenue;
  final int weekCount;
  final List<DailyTotal> weeklyTotals; // exactly 7 entries, oldest first
  final List<ProductSales> topProducts; // top 5
  final List<SaleRow> recentSales;       // up to 10
  final int lowStockCount;
  final int outOfStockCount;
  final int totalProducts;
  final double totalInventoryValue;

  /// Percent change vs. previous 7 days (null if not enough data).
  double? get revenueWowChange {
    if (weeklyTotals.length < 7) return null;
    // We only have 7 days here; compare today vs day-7-ago for a rough WoW.
    final today = weeklyTotals.last.revenue;
    final last = weeklyTotals.first.revenue;
    if (last <= 0) return today > 0 ? double.infinity : 0;
    return ((today - last) / last) * 100;
  }
}

/// Live dashboard data. Recomputes whenever sales or products change.
/// All work happens client-side against local DB — no network required.
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = ref.watch(productsRepositoryProvider);

  // Combine sales + products streams — when either changes, recompute.
  return _combine2(db.watchAllSales(), repo.watchAll(), (sales, products) {
    return _compute(sales, products);
  });
});

DashboardStats _compute(List<SaleRow> sales, List<Product> products) {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final sevenDaysAgo = startOfToday.subtract(const Duration(days: 6));

  double todayRevenue = 0;
  int todayCount = 0;
  double weekRevenue = 0;
  int weekCount = 0;
  final dailyMap = <String, _DayBucket>{};
  final productAgg = <String, _ProductBucket>{};

  for (final s in sales) {
    final ts = DateTime.tryParse(s.timestamp)?.toLocal();
    if (ts == null) continue;
    if (ts.isBefore(sevenDaysAgo)) continue;

    if (!ts.isBefore(startOfToday)) {
      todayRevenue += s.total;
      todayCount++;
    }
    weekRevenue += s.total;
    weekCount++;

    final dayKey = _dayKey(ts);
    final bucket = dailyMap.putIfAbsent(
      dayKey,
      () => _DayBucket(DateTime(ts.year, ts.month, ts.day)),
    );
    bucket.revenue += s.total;
    bucket.count++;

    // Aggregate top products from the cart payload.
    try {
      final payload = jsonDecode(s.payloadJson);
      if (payload is Map && payload['cart'] is List) {
        for (final raw in payload['cart'] as List) {
          if (raw is! Map) continue;
          final id = raw['productId']?.toString() ?? '';
          if (id.isEmpty) continue;
          final name = raw['name']?.toString() ?? id;
          final qty = _num(raw['quantity']);
          final lineTotal = _num(raw['lineTotal']) > 0
              ? _num(raw['lineTotal'])
              : (_num(raw['price']) * qty);
          final pb = productAgg.putIfAbsent(
            id,
            () => _ProductBucket(id: id, name: name),
          );
          // Use the latest seen name (newer sales may have an updated name).
          pb.name = name.isNotEmpty ? name : pb.name;
          pb.qty += qty;
          pb.revenue += lineTotal;
        }
      }
    } catch (_) {
      // Bad payload — skip aggregation for this sale.
    }
  }

  // Build 7-day series with zero-fill so the sparkline is the right width.
  final weeklyTotals = <DailyTotal>[];
  for (int i = 0; i < 7; i++) {
    final day = sevenDaysAgo.add(Duration(days: i));
    final bucket = dailyMap[_dayKey(day)];
    weeklyTotals.add(DailyTotal(
      date: day,
      revenue: bucket?.revenue ?? 0,
      count: bucket?.count ?? 0,
    ));
  }

  // Top products by revenue.
  final topProducts = productAgg.values
      .map((b) => ProductSales(
            productId: b.id,
            name: b.name,
            quantitySold: b.qty,
            revenue: b.revenue,
          ))
      .toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));

  // Inventory snapshot.
  int low = 0;
  int out = 0;
  double value = 0;
  for (final p in products) {
    if (!p.isActive) continue;
    if (p.stock <= 0) {
      out++;
    } else if (p.reorderPoint != null && p.stock <= p.reorderPoint!) {
      low++;
    }
    value += (p.costPrice ?? p.price) * p.stock;
  }

  return DashboardStats(
    todayRevenue: todayRevenue,
    todayCount: todayCount,
    weekRevenue: weekRevenue,
    weekCount: weekCount,
    weeklyTotals: weeklyTotals,
    topProducts: topProducts.take(5).toList(),
    recentSales: sales.take(10).toList(),
    lowStockCount: low,
    outOfStockCount: out,
    totalProducts: products.where((p) => p.isActive).length,
    totalInventoryValue: value,
  );
}

class _DayBucket {
  _DayBucket(this.day);
  final DateTime day;
  double revenue = 0;
  int count = 0;
}

class _ProductBucket {
  _ProductBucket({required this.id, required this.name});
  final String id;
  String name;
  double qty = 0;
  double revenue = 0;
}

String _dayKey(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

double _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

/// Combine two streams into one — emits whenever either source emits.
Stream<R> _combine2<A, B, R>(
  Stream<A> a,
  Stream<B> b,
  R Function(A a, B b) combiner,
) {
  late A latestA;
  late B latestB;
  bool seenA = false;
  bool seenB = false;
  final controller = StreamController<R>.broadcast();
  void emit() {
    if (seenA && seenB) controller.add(combiner(latestA, latestB));
  }
  final subA = a.listen((v) {
    latestA = v;
    seenA = true;
    emit();
  });
  final subB = b.listen((v) {
    latestB = v;
    seenB = true;
    emit();
  });
  controller.onCancel = () {
    subA.cancel();
    subB.cancel();
  };
  return controller.stream;
}
