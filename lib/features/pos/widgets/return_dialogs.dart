import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../data/models/return_record.dart';
import '../../../data/models/sale.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';

/// Step 1: pick a sale from the recent cache.
class FindSaleDialog extends ConsumerStatefulWidget {
  const FindSaleDialog({super.key, required this.settings});
  final StoreSettings settings;

  static Future<Sale?> show(BuildContext context, StoreSettings settings) {
    return showDialog<Sale>(
      context: context,
      builder: (_) => FindSaleDialog(settings: settings),
    );
  }

  @override
  ConsumerState<FindSaleDialog> createState() => _FindSaleDialogState();
}

class _FindSaleDialogState extends ConsumerState<FindSaleDialog> {
  String _q = '';
  Future<List<Sale>>? _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(returnsRepositoryProvider).recentSales(limit: 100);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Find sale to return'),
      content: SizedBox(
        width: 560,
        height: 520,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Receipt #, customer name, or scan…',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Sale>>(
                future: _future,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data!;
                  final q = _q.trim().toLowerCase();
                  final filtered = q.isEmpty
                      ? all
                      : all.where((s) =>
                          s.transactionId.toLowerCase().contains(q) ||
                          (s.customerName ?? '').toLowerCase().contains(q)).toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined, color: scheme.outline, size: 36),
                          const SizedBox(height: 8),
                          const Text('No matching sales in the local cache'),
                          const SizedBox(height: 4),
                          Text(
                            'Only recently-rung sales are stored on this terminal.',
                            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      final receipt = s.transactionId.length > 8
                          ? s.transactionId.substring(0, 8).toUpperCase()
                          : s.transactionId;
                      return ListTile(
                        dense: true,
                        title: Text('Receipt #$receipt · ${formatCurrency(s.total, widget.settings)}'),
                        subtitle: Text([
                          _formatTime(s.timestamp),
                          if (s.customerName != null) s.customerName!,
                          '${s.cart.length} item${s.cart.length == 1 ? '' : 's'}',
                        ].join(' · ')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(context, s),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

/// Step 2: choose which items + quantities to refund.
class ReturnFormDialog extends ConsumerStatefulWidget {
  const ReturnFormDialog({super.key, required this.sale, required this.settings});
  final Sale sale;
  final StoreSettings settings;

  static Future<ReturnRecord?> show(BuildContext context, Sale sale, StoreSettings settings) {
    return showDialog<ReturnRecord>(
      context: context,
      builder: (_) => ReturnFormDialog(sale: sale, settings: settings),
    );
  }

  @override
  ConsumerState<ReturnFormDialog> createState() => _ReturnFormDialogState();
}

class _ReturnFormDialogState extends ConsumerState<ReturnFormDialog> {
  late final Map<String, _RowState> _rows;
  String _reason = 'Customer return';
  String _refundMethod = 'Cash';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rows = {
      for (final item in widget.sale.cart)
        item.productId: _RowState(maxQty: item.quantity, qty: 0, addToStock: true),
    };
    final methods = widget.settings.effectiveMethods;
    if (methods.isNotEmpty) _refundMethod = methods.first.name;
  }

  double get _subtotal {
    double sum = 0;
    for (final item in widget.sale.cart) {
      final row = _rows[item.productId]!;
      if (row.qty > 0) sum += row.qty * item.price;
    }
    return sum;
  }

  /// Tax is refunded proportionally to the value being returned.
  double get _taxRefund {
    if (widget.sale.subtotal <= 0) return 0;
    final ratio = _subtotal / widget.sale.subtotal;
    return widget.sale.tax * ratio.clamp(0.0, 1.0);
  }

  double get _totalRefund => _subtotal + _taxRefund;

  bool get _anySelected => _rows.values.any((r) => r.qty > 0);

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final items = <ReturnLineItem>[];
      for (final original in widget.sale.cart) {
        final row = _rows[original.productId]!;
        if (row.qty <= 0) continue;
        items.add(ReturnLineItem(
          productId: original.productId,
          productName: original.name,
          quantity: row.qty,
          reason: _reason,
          addToStock: row.addToStock,
          unitPrice: original.price,
        ));
      }
      final record = await ref.read(returnsRepositoryProvider).createReturn(
            originalSale: widget.sale,
            items: items,
            taxRefund: _taxRefund,
            refundMethod: _refundMethod,
          );
      // Trigger an immediate sync attempt — fire and forget.
      ref.read(syncEngineProvider).drain();
      if (!mounted) return;
      Navigator.pop(context, record);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final receipt = widget.sale.transactionId.length > 8
        ? widget.sale.transactionId.substring(0, 8).toUpperCase()
        : widget.sale.transactionId;

    return AlertDialog(
      title: Text('Return — Receipt #$receipt'),
      content: SizedBox(
        width: 640,
        height: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Original total: ${formatCurrency(widget.sale.total, widget.settings)}'
                      '${widget.sale.customerName == null ? '' : ' · ${widget.sale.customerName}'}',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: widget.sale.cart.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = widget.sale.cart[i];
                  final row = _rows[item.productId]!;
                  return _ReturnRow(
                    item: item,
                    row: row,
                    settings: widget.settings,
                    onChanged: () => setState(() {}),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _reason,
                    decoration: const InputDecoration(labelText: 'Reason', isDense: true),
                    items: const [
                      DropdownMenuItem(value: 'Customer return', child: Text('Customer return')),
                      DropdownMenuItem(value: 'Defective', child: Text('Defective')),
                      DropdownMenuItem(value: 'Wrong item', child: Text('Wrong item')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _reason = v ?? _reason),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _refundMethod,
                    decoration: const InputDecoration(labelText: 'Refund method', isDense: true),
                    items: widget.settings.effectiveMethods
                        .map((m) => DropdownMenuItem(value: m.name, child: Text(m.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _refundMethod = v ?? _refundMethod),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _summaryLine('Subtotal refund', _subtotal),
                  _summaryLine('Tax refund', _taxRefund),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total refund', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        formatCurrency(_totalRefund, widget.settings),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: scheme.error, fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          icon: const Icon(Icons.undo),
          label: Text(_saving ? 'Processing…' : 'Process refund'),
          onPressed: (_anySelected && !_saving) ? _submit : null,
        ),
      ],
    );
  }

  Widget _summaryLine(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(formatCurrency(value, widget.settings)),
        ],
      ),
    );
  }
}

class _RowState {
  _RowState({required this.maxQty, required this.qty, required this.addToStock});
  double maxQty;
  double qty;
  bool addToStock;
}

class _ReturnRow extends StatelessWidget {
  const _ReturnRow({
    required this.item,
    required this.row,
    required this.settings,
    required this.onChanged,
  });

  final CartItem item;
  final _RowState row;
  final StoreSettings settings;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: row.qty > 0,
            onChanged: (v) {
              row.qty = (v ?? false) ? row.maxQty : 0;
              onChanged();
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  'Sold: ${formatQuantity(item.quantity, isWeighed: item.isWeighed)} ${item.unitOfMeasure} · ${formatCurrency(item.price, settings)} ea',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: row.qty == 0 ? '' : formatQuantity(row.qty, isWeighed: item.isWeighed),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Qty', isDense: true),
              onChanged: (v) {
                final n = double.tryParse(v) ?? 0;
                row.qty = n.clamp(0, row.maxQty).toDouble();
                onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Add back to stock',
            child: IconButton(
              icon: Icon(
                row.addToStock ? Icons.inventory : Icons.inventory_outlined,
                color: row.addToStock ? scheme.primary : scheme.outline,
              ),
              onPressed: () {
                row.addToStock = !row.addToStock;
                onChanged();
              },
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              formatCurrency(row.qty * item.price, settings),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
