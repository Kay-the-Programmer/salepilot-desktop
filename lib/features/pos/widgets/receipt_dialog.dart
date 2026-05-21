import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/theme.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';
import '../receipt_pdf.dart';

class ReceiptDialog extends StatelessWidget {
  const ReceiptDialog({super.key, required this.sale, required this.settings});
  final Sale sale;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radius2xl),
          child: Container(
            color: scheme.surfaceContainerLowest,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderBanner(sale: sale, settings: settings),
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: AppTokens.s5, vertical: AppTokens.s4),
                    children: [
                      _meta(context, sale),
                      const SizedBox(height: AppTokens.s3),
                      _itemsCard(context, sale, settings, scheme),
                      const SizedBox(height: AppTokens.s3),
                      _totalsCard(context, sale, settings, scheme),
                      if (sale.cashReceived != null) ...[
                        const SizedBox(height: AppTokens.s3),
                        _cashCard(context, sale, settings, scheme),
                      ],
                    ],
                  ),
                ),
                _Actions(sale: sale, settings: settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(BuildContext context, Sale sale) {
    final scheme = Theme.of(context).colorScheme;
    final receipt = sale.transactionId.length > 8
        ? sale.transactionId.substring(0, 8).toUpperCase()
        : sale.transactionId;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECEIPT',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '#$receipt',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'DATE',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDt(sale.timestamp),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _itemsCard(BuildContext ctx, Sale sale, StoreSettings settings, ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Column(
        children: [
          for (int i = 0; i < sale.cart.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      formatQuantity(sale.cart[i].quantity, isWeighed: sale.cart[i].isWeighed),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sale.cart[i].name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(
                          '${formatCurrency(sale.cart[i].price, settings)} ea',
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency(sale.cart[i].lineTotal, settings),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _totalsCard(BuildContext ctx, Sale sale, StoreSettings settings, ColorScheme scheme) {
    Widget row(String l, double v, {Color? color, bool emphasis = false}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: emphasis ? 6 : 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l,
              style: TextStyle(
                color: color ?? (emphasis ? scheme.onSurface : scheme.onSurfaceVariant),
                fontSize: emphasis ? 14 : 12,
                fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: emphasis ? 0.5 : 0,
              ),
            ),
            Text(
              formatCurrency(v, settings),
              style: TextStyle(
                color: color ?? scheme.onSurface,
                fontSize: emphasis ? 18 : 12,
                fontWeight: emphasis ? FontWeight.w900 : FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Column(
        children: [
          row('Subtotal', sale.subtotal),
          if (sale.discount > 0) row('Discount', -sale.discount, color: AppTokens.brandSuccess),
          if (sale.tax > 0) row('Tax', sale.tax),
          if (sale.storeCreditUsed > 0)
            row('Store credit', -sale.storeCreditUsed, color: scheme.primary),
          Divider(color: scheme.outlineVariant, height: 18),
          row('TOTAL', sale.total, emphasis: true, color: scheme.primary),
        ],
      ),
    );
  }

  Widget _cashCard(BuildContext ctx, Sale sale, StoreSettings settings, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTokens.brandSuccess.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppTokens.brandSuccess.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: AppTokens.brandSuccess, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash received: ${formatCurrency(sale.cashReceived!, settings)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                if ((sale.changeDue ?? 0) > 0)
                  Text(
                    'Change due: ${formatCurrency(sale.changeDue!, settings)}',
                    style: const TextStyle(
                      color: AppTokens.brandSuccess,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDt(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return iso;
    }
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({required this.sale, required this.settings});
  final Sale sale;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppTokens.s5, AppTokens.s5, AppTokens.s4, AppTokens.s5),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTokens.brandSuccess, Color(0xFF059669)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sale completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatCurrency(sale.total, settings)} · ${sale.cart.length} item${sale.cart.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.sale, required this.settings});
  final Sale sale;
  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.s4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppTokens.s2),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              icon: const Icon(Icons.print_rounded, size: 18),
              label: const Text('Print receipt'),
              onPressed: () async {
                final doc = await buildReceiptPdf(sale, settings);
                await Printing.layoutPdf(onLayout: (_) async => doc.save());
              },
            ),
          ),
        ],
      ),
    );
  }
}
