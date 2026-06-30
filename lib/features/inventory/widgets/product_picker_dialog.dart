import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/theme.dart';
import '../../../data/models/product.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';

/// Search + pick a product. Returns the chosen [Product] (or `null` if the
/// user cancelled). Used by the page-level "Receive shipment" flow so the
/// cashier doesn't have to find the row first.
class ProductPickerDialog extends ConsumerStatefulWidget {
  const ProductPickerDialog({
    super.key,
    required this.settings,
    this.title = 'Pick a product',
    this.subtitle = 'Search by name, SKU or barcode',
  });

  final StoreSettings settings;
  final String title;
  final String subtitle;

  static Future<Product?> show(
    BuildContext context, {
    required StoreSettings settings,
    String title = 'Pick a product',
    String subtitle = 'Search by name, SKU or barcode',
  }) {
    return showDialog<Product?>(
      context: context,
      builder: (_) => ProductPickerDialog(
        settings: settings,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  ConsumerState<ProductPickerDialog> createState() =>
      _ProductPickerDialogState();
}

class _ProductPickerDialogState extends ConsumerState<ProductPickerDialog> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final productsAsync =
        ref.watch(_productPickerListProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s5, AppTokens.s5, AppTokens.s3, AppTokens.s4,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppTokens.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title.toUpperCase(),
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s4, AppTokens.s4, AppTokens.s4, AppTokens.s2,
              ),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search…',
                  prefixIcon: Icon(Icons.search_rounded, size: 18),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            Flexible(
              child: productsAsync.when(
                data: (all) => _list(scheme, _filter(all)),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _filter(List<Product> all) {
    // Only active products — you don't receive shipments for archived items.
    final active = all.where((p) => p.isActive).toList();
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return active;
    return active
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            (p.barcode ?? '').toLowerCase().contains(q) ||
            (p.brand ?? '').toLowerCase().contains(q))
        .toList();
  }

  Widget _list(ColorScheme scheme, List<Product> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppTokens.s5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 32,
                color: scheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'No products match',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s4, 0, AppTokens.s4, AppTokens.s4,
      ),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (_, i) => _row(scheme, products[i]),
    );
  }

  Widget _row(ColorScheme scheme, Product p) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(p),
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              clipBehavior: Clip.antiAlias,
              child: p.imageUrls.isNotEmpty
                  ? Image.network(
                      p.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: scheme.outline,
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: scheme.outline,
                    ),
            ),
            const SizedBox(width: AppTokens.s3),
            Expanded(
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
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.sku,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_fmt(p.stock)}${p.isWeighed ? ' kg' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: p.stock <= 0
                        ? AppTokens.brandDanger
                        : scheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatCurrency(p.price, widget.settings),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

/// Local stream — we want all products (active + archived) so this could be
/// reused for archive-restore flows later; we filter to active in the dialog.
final _productPickerListProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productsRepositoryProvider).watchAll();
});
