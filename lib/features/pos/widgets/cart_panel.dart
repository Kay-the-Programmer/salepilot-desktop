import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';
import '../cart_controller.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key, required this.settings});
  final StoreSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final scheme = Theme.of(context).colorScheme;

    if (cart.items.isEmpty) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shopping_cart_outlined, size: 40, color: scheme.outline),
                ),
                const SizedBox(height: AppTokens.s4),
                Text(
                  'Cart is empty',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppTokens.s1),
                Text(
                  'Scan a barcode, type to search,\nor tap a product to add it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.s3, vertical: AppTokens.s2),
        itemCount: cart.items.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _CartItemRow(item: cart.items[i], settings: settings),
        ),
      ),
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  const _CartItemRow({required this.item, required this.settings});
  final CartItem item;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final ctrl = ref.read(cartProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatCurrency(item.price, settings)} each',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QtyStepper(
            value: item.quantity,
            isWeighed: item.isWeighed,
            onDec: () => ctrl.decrement(item.productId),
            onInc: () => ctrl.increment(item.productId),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              formatCurrency(item.lineTotal, settings),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: scheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            color: scheme.onSurfaceVariant,
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
            onPressed: () => ctrl.remove(item.productId),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.value,
    required this.isWeighed,
    required this.onDec,
    required this.onInc,
  });

  final double value;
  final bool isWeighed;
  final VoidCallback onDec;
  final VoidCallback onInc;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(scheme, Icons.remove, onDec),
          SizedBox(
            width: 32,
            child: Text(
              formatQuantity(value, isWeighed: isWeighed),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          _stepperButton(scheme, Icons.add, onInc),
        ],
      ),
    );
  }

  Widget _stepperButton(ColorScheme scheme, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Icon(icon, size: 14, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
