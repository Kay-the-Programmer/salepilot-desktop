import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/theme.dart';
import '../../../data/db/app_database.dart';

/// Recent stock-movement log. Local audit trail that survives queue drain —
/// so even after a movement has been pushed to the server, history stays
/// visible to the cashier without needing an API call.
class StockActivityDialog extends ConsumerWidget {
  const StockActivityDialog({super.key, this.productId, this.productName});

  /// When non-null, filter the log to a single product.
  final String? productId;
  final String? productName;

  static Future<void> show(
    BuildContext context, {
    String? productId,
    String? productName,
  }) {
    return showDialog(
      context: context,
      builder: (_) => StockActivityDialog(
        productId: productId,
        productName: productName,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final movements = productId == null
        ? ref.watch(stockMovementsProvider)
        : ref.watch(stockMovementsForProductProvider(productId!));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
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
                      Icons.history_rounded,
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
                          productId == null
                              ? 'STOCK ACTIVITY'
                              : 'PRODUCT HISTORY',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          productName ?? 'Recent stock adjustments',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Flexible(
              child: movements.when(
                data: (list) => list.isEmpty
                    ? _empty(scheme)
                    : _list(scheme, list),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.s5),
                    child: Text('Error: $e'),
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s4,
                vertical: AppTokens.s3,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTokens.radius2xl),
                  bottomRight: Radius.circular(AppTokens.radius2xl),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Local audit trail — kept even when offline.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 40,
            color: scheme.outline,
          ),
          const SizedBox(height: AppTokens.s3),
          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stock adjustments you make will appear here.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(ColorScheme scheme, List<StockMovementRow> list) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s4,
        vertical: AppTokens.s3,
      ),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (_, i) => _MovementRow(movement: list[i]),
    );
  }
}

/// Provider exposing recent stock movements from the local DB.
final stockMovementsProvider = StreamProvider<List<StockMovementRow>>((ref) {
  return ref.watch(productsRepositoryProvider).watchStockMovements(limit: 100);
});

/// Stream movements filtered to a single product. Use `.family` so each
/// product gets its own cached stream.
final stockMovementsForProductProvider =
    StreamProvider.family<List<StockMovementRow>, String>((ref, productId) {
  return ref
      .watch(productsRepositoryProvider)
      .watchStockMovements(limit: 100, productId: productId);
});

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement});
  final StockMovementRow movement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final positive = movement.delta > 0;
    final color = positive ? AppTokens.brandSuccess : AppTokens.brandWarning;
    final pending = movement.synced == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Direction indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(
              positive
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: AppTokens.s3),
          // Product + reason
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        movement.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    if (pending) ...[
                      const SizedBox(width: 6),
                      _pendingChip(scheme),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${movement.reason} · ${_formatTime(movement.createdAt)}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Delta + new value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${positive ? '+' : ''}${_fmt(movement.delta)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${_fmt(movement.previousStock)} → ${_fmt(movement.newStock)}',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10.5,
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

  Widget _pendingChip(ColorScheme scheme) {
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

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  static String _formatTime(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    // Older: show absolute date
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }
}
