import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';

/// Shown when the cashier tries to add a product whose stock is exhausted
/// (or already fully in the cart).
class OutOfStockDialog extends StatelessWidget {
  const OutOfStockDialog({super.key, required this.product, required this.settings});
  final Product product;
  final StoreSettings settings;

  static Future<void> show(BuildContext context, Product product, StoreSettings settings) {
    return showDialog<void>(
      context: context,
      builder: (_) => OutOfStockDialog(product: product, settings: settings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.inventory_2_outlined, color: scheme.error, size: 36),
      title: const Text('Out of stock'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              'SKU ${product.sku}${product.barcode != null ? ' · ${product.barcode}' : ''}',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: scheme.onErrorContainer, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Available: ${formatQuantity(product.stock, isWeighed: product.isWeighed)} ${product.unitOfMeasure}',
                      style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Restock this product in the web app, then refresh the catalog (top-right) to add it to a sale.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ],
    );
  }
}

/// Shown once when an item is added and the resulting stock drops at or below
/// the product's `reorderPoint`. Non-blocking; cashier dismisses.
class LowStockAlertDialog extends StatelessWidget {
  const LowStockAlertDialog({super.key, required this.product, required this.remaining});
  final Product product;
  final double remaining;

  static Future<void> show(BuildContext context, Product product, double remaining) {
    return showDialog<void>(
      context: context,
      builder: (_) => LowStockAlertDialog(product: product, remaining: remaining),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 36),
      title: const Text('Low stock'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            Text(
              'Only ${formatQuantity(remaining, isWeighed: product.isWeighed)} ${product.unitOfMeasure} left '
              'after this sale (reorder point: ${formatQuantity(product.reorderPoint ?? 0, isWeighed: product.isWeighed)}).',
              style: TextStyle(color: scheme.onSurface, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Consider creating a purchase order in the web app.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
      ],
    );
  }
}
