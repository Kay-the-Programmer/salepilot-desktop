import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../app_providers.dart';
import '../../core/branding.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../data/models/product.dart';
import '../../data/models/store_settings.dart';
import '../../shared/currency.dart';
import '../pos/pos_data_controller.dart';
import 'inventory_controller.dart';
import 'low_stock_pdf.dart';
import 'stock_take_screen.dart';
import 'widgets/product_create_dialog.dart';
import 'widgets/product_edit_dialog.dart';
import 'widgets/product_picker_dialog.dart';
import 'widgets/receive_shipment_dialog.dart';
import 'widgets/stock_activity_dialog.dart';
import 'widgets/stock_adjustment_dialog.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filter = ref.watch(inventoryControllerProvider.select((s) => s.filter));
    final products = ref.watch(filteredInventoryProvider);
    final stats = ref.watch(inventoryStatsProvider);
    final pending = ref.watch(pendingStockAdjustmentsProvider);
    final settings = ref.watch(posDataProvider).settings ?? StoreSettings();
    // On narrow windows the labelled CTAs would overflow the app bar, so
    // collapse them to icon buttons.
    final compactBar = context.isMedium;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to POS',
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const SalePilotLogo.icon(size: 26),
            const SizedBox(width: AppTokens.s3),
            const Text('Inventory'),
            const SizedBox(width: AppTokens.s2),
            // "Pending sync" pill — visible only when there are queued adjustments.
            pending.when(
              data: (count) => count > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.brandWarning.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_sync_outlined,
                            size: 12,
                            color: AppTokens.brandWarning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$count to sync',
                            style: const TextStyle(
                              color: AppTokens.brandWarning,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Stock activity',
            onPressed: () => StockActivityDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh from server',
            onPressed: () =>
                ref.read(productsRepositoryProvider).pullFromServer(),
          ),
          // Secondary actions overflow — keeps the app bar uncluttered as
          // the feature surface grows. Stock take has its own entry here.
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'More actions',
            onSelected: (v) {
              if (v == 'stock-take') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StockTakeScreen(),
                  ),
                );
              } else if (v == 'low-stock-pdf') {
                _exportLowStockPdf(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'stock-take',
                height: 40,
                child: Row(
                  children: [
                    Icon(Icons.checklist_rounded, size: 16),
                    SizedBox(width: 10),
                    Text(
                      'Stock take',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'low-stock-pdf',
                height: 40,
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, size: 16),
                    SizedBox(width: 10),
                    Text(
                      'Low-stock report (PDF)',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: AppTokens.s2),
          // Secondary CTA — receive a shipment. Pairs with "New product".
          // Collapses to an icon button on narrow windows.
          if (compactBar)
            IconButton(
              icon: const Icon(Icons.inbox_outlined),
              tooltip: 'Receive shipment',
              color: AppTokens.brandSuccess,
              onPressed: () => _openReceiveFlow(context),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.inbox_outlined, size: 18),
                label: const Text('Receive shipment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTokens.brandSuccess,
                  side: BorderSide(
                    color: AppTokens.brandSuccess.withValues(alpha: 0.5),
                  ),
                ),
                onPressed: () => _openReceiveFlow(context),
              ),
            ),
          const SizedBox(width: AppTokens.s2),
          // Primary CTA — also collapses to a filled icon button when narrow.
          if (compactBar)
            IconButton.filled(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'New product',
              onPressed: () => ProductCreateDialog.show(context),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              child: FilledButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New product'),
                onPressed: () => ProductCreateDialog.show(context),
              ),
            ),
          const SizedBox(width: AppTokens.s4),
        ],
      ),
      body: Column(
        children: [
          // Top stats row — bento dashboard summary
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.s5, AppTokens.s5, AppTokens.s5, AppTokens.s3,
            ),
            child: stats.when(
              data: (s) => _StatsRow(stats: s, settings: settings),
              loading: () => const _StatsRowSkeleton(),
              error: (e, _) => _StatsErrorRow(error: e.toString()),
            ),
          ),
          // Search + filter row — stacks on narrow windows so the filter
          // segments never collide with the search field.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s5),
            child: Builder(builder: (context) {
              final filterChips = _FilterChips(
                selected: filter,
                onChange: (f) =>
                    ref.read(inventoryControllerProvider.notifier).setFilter(f),
              );
              if (compactBar) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _searchField(scheme),
                    const SizedBox(height: AppTokens.s2),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: filterChips,
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _searchField(scheme)),
                  const SizedBox(width: AppTokens.s3),
                  filterChips,
                ],
              );
            }),
          ),
          const SizedBox(height: AppTokens.s3),
          Expanded(
            child: products.when(
              data: (list) => list.isEmpty
                  ? _EmptyState(filter: filter)
                  : _ProductList(products: list, settings: settings),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: TextStyle(color: scheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a low-stock + out-of-stock PDF report and opens the OS-native
  /// print/save dialog via the `printing` package. From there the user can
  /// preview, save as PDF, or send to any installed printer.
  Future<void> _exportLowStockPdf(BuildContext context) async {
    final settings =
        ref.read(posDataProvider).settings ?? StoreSettings();
    // Read the full active+archived product list once for the report. We
    // bypass the filter so the PDF always shows the canonical "what needs
    // reordering" picture regardless of what filter the user has set.
    final repo = ref.read(productsRepositoryProvider);
    final allProducts = await repo.watchAll().first;
    final doc = await buildLowStockReportPdf(
      allProducts: allProducts,
      settings: settings,
    );
    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name:
          'low-stock-${DateTime.now().toIso8601String().substring(0, 10)}.pdf',
    );
  }

  /// Page-level "Receive shipment" entry point: picks a product first, then
  /// hands off to the existing receive dialog with that product preselected.
  /// Mirrors the web app's flow, where receiving is initiated from inventory
  /// rather than buried per-row.
  Future<void> _openReceiveFlow(BuildContext context) async {
    final settings =
        ref.read(posDataProvider).settings ?? StoreSettings();
    final picked = await ProductPickerDialog.show(
      context,
      settings: settings,
      title: 'Receive shipment',
      subtitle: 'Pick the product you\'re receiving',
    );
    if (picked == null || !context.mounted) return;
    await ReceiveShipmentDialog.show(
      context,
      product: picked,
      settings: settings,
    );
  }

  Widget _searchField(ColorScheme scheme) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchCtrl,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search by name, SKU, barcode or brand…',
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        onChanged: (v) =>
            ref.read(inventoryControllerProvider.notifier).setQuery(v),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// Stats row
// ───────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.settings});
  final InventoryStats stats;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ResponsiveCardGrid(
      children: [
        _StatCard(
          label: 'TOTAL PRODUCTS',
          value: '${stats.total}',
          icon: Icons.inventory_2_outlined,
          color: scheme.primary,
        ),
        _StatCard(
          label: 'LOW STOCK',
          value: '${stats.lowStock}',
          icon: Icons.warning_amber_rounded,
          color: AppTokens.brandWarning,
          highlight: stats.lowStock > 0,
        ),
        _StatCard(
          label: 'OUT OF STOCK',
          value: '${stats.outOfStock}',
          icon: Icons.do_not_disturb_on_outlined,
          color: AppTokens.brandDanger,
          highlight: stats.outOfStock > 0,
        ),
        _StatCard(
          label: 'INVENTORY VALUE',
          value: formatCurrency(stats.totalStockValue, settings),
          icon: Icons.account_balance_wallet_outlined,
          color: AppTokens.brandSuccess,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });

  final String label;
  final String value;
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
            ],
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
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: highlight ? color : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 100,
      child: Row(
        children: List.generate(
          4,
          (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == 3 ? 0 : AppTokens.s3),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsErrorRow extends StatelessWidget {
  const _StatsErrorRow({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 100, child: Center(child: Text(error)));
  }
}

// ───────────────────────────────────────────────────────────────────────
// Filter chips
// ───────────────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChange});
  final StockFilter selected;
  final ValueChanged<StockFilter> onChange;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<StockFilter>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
      segments: const [
        ButtonSegment(value: StockFilter.all, label: Text('All')),
        ButtonSegment(value: StockFilter.inStock, label: Text('In stock')),
        ButtonSegment(value: StockFilter.lowStock, label: Text('Low')),
        ButtonSegment(value: StockFilter.outOfStock, label: Text('Out')),
        ButtonSegment(value: StockFilter.archived, label: Text('Archived')),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChange(s.first),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// Product list
// ───────────────────────────────────────────────────────────────────────
class _ProductList extends ConsumerWidget {
  const _ProductList({required this.products, required this.settings});
  final List<Product> products;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s5, 0, AppTokens.s5, AppTokens.s5,
      ),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final p = products[i];
        return Consumer(
          builder: (context, ref, _) => _ProductRow(
            product: p,
            settings: settings,
            onAdjust: () => StockAdjustmentDialog.show(
              context,
              product: p,
              settings: settings,
            ),
            onEdit: () => ProductEditDialog.show(context, p),
            onReceive: () => ReceiveShipmentDialog.show(
              context,
              product: p,
              settings: settings,
            ),
            onViewHistory: () => StockActivityDialog.show(
              context,
              productId: p.id,
              productName: p.name,
            ),
            onToggleArchive: () async {
              await ref.read(productsRepositoryProvider).setArchived(
                    productId: p.id,
                    archived: p.isActive, // toggle
                  );
              ref.read(syncEngineProvider).drain();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(p.isActive
                        ? 'Archived "${p.name}"'
                        : 'Restored "${p.name}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            onDelete: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete this product?'),
                  content: Text(
                    'This permanently removes "${p.name}" from your catalog. '
                    'Past sales referencing it will keep their snapshot, but the '
                    'product won\'t appear in lists or reports again.\n\n'
                    'Consider archiving instead if you may want it back later.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTokens.brandDanger,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (ok != true) return;
              await ref.read(productsRepositoryProvider).deleteProduct(p.id);
              ref.read(syncEngineProvider).drain();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${p.name}"')),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _ProductRow extends StatefulWidget {
  const _ProductRow({
    required this.product,
    required this.settings,
    required this.onAdjust,
    required this.onEdit,
    required this.onReceive,
    required this.onViewHistory,
    required this.onToggleArchive,
    required this.onDelete,
  });

  final Product product;
  final StoreSettings settings;
  final VoidCallback onAdjust;
  final VoidCallback onEdit;
  final VoidCallback onReceive;
  final VoidCallback onViewHistory;
  final VoidCallback onToggleArchive;
  final VoidCallback onDelete;

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = widget.product;
    final archived = !p.isActive;
    final outOfStock = p.stock <= 0;
    final lowStock = !archived &&
        !outOfStock &&
        p.reorderPoint != null &&
        p.stock <= p.reorderPoint!;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Opacity(
        // Archived rows are visually de-emphasized — still tappable so the
        // user can restore them.
        opacity: archived ? 0.6 : 1.0,
        child: AnimatedContainer(
          duration: AppTokens.motionFast,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(
              color: _hover ? scheme.outline : scheme.outlineVariant,
            ),
            boxShadow: _hover ? AppTokens.shadowSm() : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              // Archived products can't be sold or adjusted — the only
              // useful row-tap is to restore them.
              onTap: archived ? widget.onToggleArchive : widget.onAdjust,
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s3),
                child: Row(
                  children: [
                  // Image / placeholder
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: p.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTokens.radiusSm,
                            ),
                            child: Image.network(
                              p.imageUrls.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.image_not_supported_outlined,
                                color: scheme.outline,
                                size: 20,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            color: scheme.outline,
                            size: 22,
                          ),
                  ),
                  const SizedBox(width: AppTokens.s3),
                  // Name + SKU
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.sku,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Consolas',
                            fontFamilyFallback: const ['monospace'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Expanded(
                    flex: 2,
                    child: Text(
                      formatCurrency(p.price, widget.settings),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  // Stock + badge
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppTokens.s2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${formatQuantity(p.stock, isWeighed: p.isWeighed)}${p.isWeighed ? ' kg' : ''}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: outOfStock
                                  ? AppTokens.brandDanger
                                  : (lowStock
                                      ? AppTokens.brandWarning
                                      : scheme.onSurface),
                              letterSpacing: -0.3,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          _stockBadge(
                              scheme: scheme,
                              outOfStock: outOfStock,
                              lowStock: lowStock,
                              reorderPoint: p.reorderPoint),
                        ],
                      ),
                    ),
                  ),
                    const SizedBox(width: AppTokens.s2),
                    // Action cluster. Edit pencil hover-revealed, Adjust
                    // always-visible, kebab menu for less-frequent actions.
                    _RowActions(
                      hover: _hover,
                      scheme: scheme,
                      archived: archived,
                      onAdjust: widget.onAdjust,
                      onEdit: widget.onEdit,
                      onReceive: widget.onReceive,
                      onViewHistory: widget.onViewHistory,
                      onToggleArchive: widget.onToggleArchive,
                      onDelete: widget.onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stockBadge({
    required ColorScheme scheme,
    required bool outOfStock,
    required bool lowStock,
    double? reorderPoint,
  }) {
    if (outOfStock) {
      return _badge(
        'OUT OF STOCK',
        AppTokens.brandDanger,
        scheme,
      );
    }
    if (lowStock) {
      return _badge(
        'LOW · Reorder at ${reorderPoint?.toStringAsFixed(0) ?? '?'}',
        AppTokens.brandWarning,
        scheme,
      );
    }
    return Text(
      'In stock',
      style: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _badge(String text, Color color, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// Row action cluster
// ───────────────────────────────────────────────────────────────────────
class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.hover,
    required this.scheme,
    required this.archived,
    required this.onAdjust,
    required this.onEdit,
    required this.onReceive,
    required this.onViewHistory,
    required this.onToggleArchive,
    required this.onDelete,
  });

  final bool hover;
  final ColorScheme scheme;
  final bool archived;
  final VoidCallback onAdjust;
  final VoidCallback onEdit;
  final VoidCallback onReceive;
  final VoidCallback onViewHistory;
  final VoidCallback onToggleArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Archived: only the kebab menu is useful (to restore).
    if (archived) {
      return _archivedBadgeAndMenu();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit — hover-revealed
        AnimatedOpacity(
          duration: AppTokens.motionFast,
          opacity: hover ? 1 : 0,
          child: IgnorePointer(
            ignoring: !hover,
            child: _iconBtn(
              icon: Icons.edit_outlined,
              tooltip: 'Edit product',
              onTap: onEdit,
            ),
          ),
        ),
        const SizedBox(width: 2),
        // Adjust stock — always visible
        _iconBtn(
          icon: Icons.tune_rounded,
          tooltip: 'Adjust stock',
          onTap: onAdjust,
          highlight: hover,
        ),
        const SizedBox(width: 2),
        // Kebab — secondary actions (archive, etc.)
        _kebab(),
      ],
    );
  }

  /// Compact display for archived rows: a label badge + a restore action.
  Widget _archivedBadgeAndMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Text(
            'ARCHIVED',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(width: 4),
        _iconBtn(
          icon: Icons.unarchive_outlined,
          tooltip: 'Restore product',
          onTap: onToggleArchive,
          highlight: hover,
        ),
      ],
    );
  }

  Widget _kebab() {
    return PopupMenuButton<String>(
      tooltip: 'More actions',
      icon: Icon(Icons.more_vert_rounded, size: 18, color: scheme.onSurfaceVariant),
      padding: EdgeInsets.zero,
      iconSize: 18,
      onSelected: (v) {
        switch (v) {
          case 'receive':
            onReceive();
          case 'history':
            onViewHistory();
          case 'archive':
            onToggleArchive();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'receive',
          height: 40,
          child: Row(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 16,
                color: AppTokens.brandSuccess,
              ),
              const SizedBox(width: 10),
              const Text(
                'Receive shipment',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'history',
          height: 40,
          child: Row(
            children: [
              Icon(Icons.history_rounded, size: 16),
              SizedBox(width: 10),
              Text(
                'View history',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'archive',
          height: 40,
          child: Row(
            children: [
              Icon(
                Icons.archive_outlined,
                size: 16,
                color: AppTokens.brandWarning,
              ),
              const SizedBox(width: 10),
              const Text(
                'Archive',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 40,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppTokens.brandDanger,
              ),
              const SizedBox(width: 10),
              Text(
                'Delete',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTokens.brandDanger,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: highlight ? scheme.primary.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Icon(
            icon,
            size: 16,
            color: highlight ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────
// Empty state
// ───────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final StockFilter filter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, title, hint) = switch (filter) {
      StockFilter.outOfStock => (
        Icons.celebration_outlined,
        'No out-of-stock items',
        'Everything in your catalog has stock.',
      ),
      StockFilter.lowStock => (
        Icons.check_circle_outline_rounded,
        'No low-stock items',
        'All products are above their reorder point.',
      ),
      StockFilter.inStock => (
        Icons.inventory_2_outlined,
        'Nothing in stock',
        'Add inventory to start seeing products here.',
      ),
      StockFilter.archived => (
        Icons.inbox_outlined,
        'No archived products',
        'Products you archive will show up here.',
      ),
      StockFilter.all => (
        Icons.inventory_2_outlined,
        'No products match',
        'Try a different search or refresh from the server.',
      ),
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: scheme.outline),
          ),
          const SizedBox(height: AppTokens.s3),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            hint,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
