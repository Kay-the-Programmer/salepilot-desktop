import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../data/models/product.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';
import '../cart_controller.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.settings,
    required this.onProductTap,
  });

  final List<Product> products;
  final StoreSettings settings;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return _emptyState(context);
    }

    final cart = ref.watch(cartProvider);
    final inCart = {for (final item in cart.items) item.productId: item.quantity};

    return GridView.builder(
      padding: const EdgeInsets.all(AppTokens.s4),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: AppTokens.s3,
        crossAxisSpacing: AppTokens.s3,
        childAspectRatio: 0.76,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return _ProductCard(
          product: p,
          settings: settings,
          quantityInCart: inCart[p.id],
          onTap: () => onProductTap(p),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined, size: 36, color: scheme.outline),
            ),
            const SizedBox(height: AppTokens.s4),
            Text('No products found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppTokens.s1),
            Text(
              'Try a different search, or add products in the web app and refresh.',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.settings,
    required this.quantityInCart,
    required this.onTap,
  });

  final Product product;
  final StoreSettings settings;
  final double? quantityInCart;
  final VoidCallback onTap;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final product = widget.product;
    final lowStock = product.reorderPoint != null && product.stock <= product.reorderPoint!;
    final outOfStock = product.stock <= 0;
    final inCart = (widget.quantityInCart ?? 0) > 0;

    final borderColor = inCart
        ? scheme.primary
        : (_hover ? scheme.outline : scheme.outlineVariant);

    return MouseRegion(
      cursor: outOfStock ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: borderColor, width: inCart ? 1.5 : 1),
          boxShadow: _hover && !outOfStock
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: outOfStock ? null : widget.onTap,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  scheme.surfaceContainerLow,
                                  scheme.surfaceContainerHigh,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                            ),
                            child: product.imageUrls.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                                    child: Image.network(
                                      product.imageUrls.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, _, _) => Center(
                                        child: Icon(
                                          Icons.image_not_supported_outlined,
                                          color: scheme.outline,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      size: 32,
                                      color: scheme.outline,
                                    ),
                                  ),
                          ),
                        ),
                        if (inCart)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check, color: Colors.white, size: 11),
                                  const SizedBox(width: 3),
                                  Text(
                                    formatQuantity(widget.quantityInCart!, isWeighed: product.isWeighed),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (outOfStock)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.surface.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: scheme.error,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'OUT OF STOCK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.s2),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppTokens.s1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatCurrency(product.price, widget.settings),
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      _stockBadge(scheme, product, outOfStock, lowStock),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stockBadge(ColorScheme scheme, Product product, bool out, bool low) {
    if (out) return const SizedBox.shrink();
    final color = low ? AppTokens.brandWarning : scheme.onSurfaceVariant;
    final bg = low
        ? AppTokens.brandWarning.withValues(alpha: 0.12)
        : scheme.surfaceContainerLow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${formatQuantity(product.stock, isWeighed: product.isWeighed)} ${product.isWeighed ? 'kg' : ''}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
