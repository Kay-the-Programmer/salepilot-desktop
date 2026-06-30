import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/branding.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/models/store_settings.dart';
import '../../shared/currency.dart';
import '../pos/pos_data_controller.dart';
import 'dashboard_controller.dart';

/// Admin dashboard. Bento layout, all data sourced from the local DB so the
/// screen renders instantly and works offline.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(dashboardStatsProvider);
    final settings =
        ref.watch(posDataProvider.select((s) => s.settings)) ?? StoreSettings();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        titleSpacing: 0,
        title: Row(
          children: const [
            SalePilotLogo.icon(size: 26),
            SizedBox(width: AppTokens.s3),
            Text('Dashboard'),
          ],
        ),
      ),
      body: statsAsync.when(
        data: (stats) => _DashboardBody(stats: stats, settings: settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats, required this.settings});
  final DashboardStats stats;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final hero = _HeroCard(
      label: 'TODAY',
      value: formatCurrency(stats.todayRevenue, settings),
      sub: '${stats.todayCount} transaction${stats.todayCount == 1 ? '' : 's'}',
      sparkline: stats.weeklyTotals,
    );
    final week = _StatCard(
      label: 'LAST 7 DAYS',
      value: formatCurrency(stats.weekRevenue, settings),
      sub: '${stats.weekCount} sale${stats.weekCount == 1 ? '' : 's'}',
      icon: Icons.show_chart_rounded,
      color: AppTokens.brandSuccess,
    );
    final change = _ChangeCard(change: stats.revenueWowChange);

    final health = [
      _StatCard(
        label: 'PRODUCTS',
        value: '${stats.totalProducts}',
        sub: 'active in catalog',
        icon: Icons.inventory_2_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      _StatCard(
        label: 'LOW STOCK',
        value: '${stats.lowStockCount}',
        sub: 'need reorder',
        icon: Icons.warning_amber_rounded,
        color: AppTokens.brandWarning,
        highlight: stats.lowStockCount > 0,
      ),
      _StatCard(
        label: 'OUT OF STOCK',
        value: '${stats.outOfStockCount}',
        sub: 'unavailable for sale',
        icon: Icons.do_not_disturb_on_outlined,
        color: AppTokens.brandDanger,
        highlight: stats.outOfStockCount > 0,
      ),
      _StatCard(
        label: 'INVENTORY VALUE',
        value: formatCurrency(stats.totalInventoryValue, settings),
        sub: 'at cost basis',
        icon: Icons.account_balance_wallet_outlined,
        color: AppTokens.brandSuccess,
      ),
    ];

    final topProducts = _TopProducts(products: stats.topProducts, settings: settings);
    final recentSales = _RecentSales(sales: stats.recentSales, settings: settings);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.s5),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < Breakpoints.compact;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Top: today + week + WoW change ───────────────────
                  if (narrow) ...[
                    hero,
                    const SizedBox(height: AppTokens.s3),
                    ResponsiveCardGrid(children: [week, change]),
                  ] else
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(flex: 5, child: hero),
                          const SizedBox(width: AppTokens.s3),
                          Expanded(flex: 3, child: week),
                          const SizedBox(width: AppTokens.s3),
                          Expanded(flex: 3, child: change),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppTokens.s3),
                  // ─── Inventory health (wraps 4 / 2 / 1) ───────────────
                  ResponsiveCardGrid(children: health),
                  const SizedBox(height: AppTokens.s3),
                  // ─── Top products + recent sales ──────────────────────
                  if (narrow) ...[
                    topProducts,
                    const SizedBox(height: AppTokens.s3),
                    recentSales,
                  ] else
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: topProducts),
                          const SizedBox(width: AppTokens.s3),
                          Expanded(child: recentSales),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// Hero card with sparkline
// ───────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.sparkline,
  });

  final String label;
  final String value;
  final String sub;
  final List<DailyTotal> sparkline;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.s5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            AppTokens.brandSecondary,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: AppTokens.shadowMd(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppTokens.s2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTokens.s4),
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: const Size.fromHeight(60),
              painter: _SparklinePainter(
                values: sparkline.map((d) => d.revenue).toList(),
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Day labels under the sparkline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: sparkline
                .map((d) => Text(
                      _dayLabel(d.date),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  String _dayLabel(DateTime d) => _days[d.weekday - 1];
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.fold<double>(0, (m, v) => v > m ? v : m);
    if (maxV <= 0) {
      // Flat zero line.
      final paint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height - 2),
        Offset(size.width, size.height - 2),
        paint,
      );
      return;
    }

    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0;
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = (i * stepX).toDouble();
      final y = size.height - (values[i] / maxV) * size.height;
      points.add(Offset(x, y));
    }

    // Filled area beneath the line.
    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()..color = color.withValues(alpha: 0.18),
    );

    // Stroke line.
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, stroke);

    // Point markers on each day.
    final dotPaint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}

// ───────────────────────────────────────────────────────────────────────
// Stat card
// ───────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.s4),
      decoration: BoxDecoration(
        color: highlight
            ? color.withValues(alpha: 0.06)
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: highlight
              ? color.withValues(alpha: 0.25)
              : scheme.outlineVariant,
        ),
        boxShadow: AppTokens.shadowSm(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppTokens.s3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: highlight ? color : scheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// WoW change card
// ───────────────────────────────────────────────────────────────────────
class _ChangeCard extends StatelessWidget {
  const _ChangeCard({required this.change});
  final double? change;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = change;
    final positive = c != null && c > 0;
    final negative = c != null && c < 0;
    final color = positive
        ? AppTokens.brandSuccess
        : (negative ? AppTokens.brandDanger : scheme.onSurfaceVariant);
    final icon = positive
        ? Icons.trending_up_rounded
        : (negative ? Icons.trending_down_rounded : Icons.trending_flat_rounded);

    final valueText = c == null
        ? '—'
        : (c.isInfinite ? '∞' : '${c >= 0 ? '+' : ''}${c.toStringAsFixed(1)}%');

    return Container(
      padding: const EdgeInsets.all(AppTokens.s4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: AppTokens.shadowSm(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: AppTokens.s3),
          Text(
            'WEEK OVER WEEK',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valueText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            c == null
                ? 'Not enough data yet'
                : (positive
                    ? 'Today vs 7 days ago'
                    : (negative
                        ? 'Today vs 7 days ago'
                        : 'No change vs 7 days ago')),
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// Top products
// ───────────────────────────────────────────────────────────────────────
class _TopProducts extends StatelessWidget {
  const _TopProducts({required this.products, required this.settings});
  final List<ProductSales> products;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxRevenue = products.isEmpty
        ? 0.0
        : products.first.revenue;
    return Container(
      padding: const EdgeInsets.all(AppTokens.s4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: AppTokens.shadowSm(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline_rounded,
                  size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Top products · last 7 days',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s3),
          if (products.isEmpty)
            _emptyState(scheme, 'No sales yet this week')
          else
            ...products.map(
              (p) => _TopProductRow(
                product: p,
                maxRevenue: maxRevenue,
                settings: settings,
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState(ColorScheme scheme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.s4),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
        ),
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  const _TopProductRow({
    required this.product,
    required this.maxRevenue,
    required this.settings,
  });
  final ProductSales product;
  final double maxRevenue;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = maxRevenue <= 0 ? 0.0 : (product.revenue / maxRevenue);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                formatCurrency(product.revenue, settings),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: fill.clamp(0.0, 1.0),
                    minHeight: 4,
                    color: scheme.primary,
                    backgroundColor: scheme.surfaceContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_fmt(product.quantitySold)} sold',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

// ───────────────────────────────────────────────────────────────────────
// Recent sales
// ───────────────────────────────────────────────────────────────────────
class _RecentSales extends StatelessWidget {
  const _RecentSales({required this.sales, required this.settings});
  final List<SaleRow> sales;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.s4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: AppTokens.shadowSm(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Recent sales',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s3),
          if (sales.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTokens.s4),
              child: Center(
                child: Text(
                  'No sales yet',
                  style:
                      TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5),
                ),
              ),
            )
          else
            ...sales.map((s) => _SaleRow(sale: s, settings: settings)),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale, required this.settings});
  final SaleRow sale;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pending = sale.synced == 0;
    final ts = DateTime.tryParse(sale.timestamp)?.toLocal();
    final itemCount = _countItems(sale.payloadJson);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppTokens.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        sale.customerName ?? 'Walk-in customer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (pending) ...[
                      const SizedBox(width: 6),
                      _pendingChip(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$itemCount item${itemCount == 1 ? '' : 's'} · ${_formatTime(ts)}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(sale.total, settings),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppTokens.brandWarning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: const Text(
        'PENDING',
        style: TextStyle(
          color: AppTokens.brandWarning,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static int _countItems(String payloadJson) {
    try {
      final m = jsonDecode(payloadJson);
      if (m is Map && m['cart'] is List) return (m['cart'] as List).length;
    } catch (_) {}
    return 0;
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '—';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }
}
