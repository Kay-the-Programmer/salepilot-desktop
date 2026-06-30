import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/theme.dart';
import '../../../data/models/product.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';

/// Receive an inbound shipment — typically multiple cartons of the same SKU.
///
/// Wraps a stock adjustment with a familiar "case quantity" mental model:
/// instead of asking the cashier to compute `cartons × units`, they enter
/// both and we do the math. Submitting calls the regular offline-first
/// `adjustStock(reason: 'Restock')` pipeline:
///   - local stock updated immediately
///   - PATCH queued with absolute new value (idempotent retry)
///   - audit log entry recorded
class ReceiveShipmentDialog extends ConsumerStatefulWidget {
  const ReceiveShipmentDialog({
    super.key,
    required this.product,
    required this.settings,
  });

  final Product product;
  final StoreSettings settings;

  static Future<void> show(
    BuildContext context, {
    required Product product,
    required StoreSettings settings,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ReceiveShipmentDialog(
        product: product,
        settings: settings,
      ),
    );
  }

  @override
  ConsumerState<ReceiveShipmentDialog> createState() =>
      _ReceiveShipmentDialogState();
}

class _ReceiveShipmentDialogState
    extends ConsumerState<ReceiveShipmentDialog> {
  late final TextEditingController _cartonsCtrl;
  late final TextEditingController _unitsPerCartonCtrl;
  late final TextEditingController _cartonCostCtrl;
  late final TextEditingController _noteCtrl;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _cartonsCtrl = TextEditingController();
    // Pre-fill from the product's saved box config so the cashier doesn't
    // have to retype the box size every shipment. Falls back to "1" when
    // the product hasn't been configured.
    final savedUnits = widget.product.unitsPerBox;
    _unitsPerCartonCtrl = TextEditingController(
      text: (savedUnits != null && savedUnits > 0)
          ? savedUnits.toString()
          : '1',
    );
    final savedCost = widget.product.boxCost;
    _cartonCostCtrl = TextEditingController(
      text: (savedCost != null && savedCost > 0)
          ? (savedCost == savedCost.truncateToDouble()
              ? savedCost.toStringAsFixed(0)
              : savedCost.toString())
          : '',
    );
    _noteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _cartonsCtrl.dispose();
    _unitsPerCartonCtrl.dispose();
    _cartonCostCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  int get _cartons => int.tryParse(_cartonsCtrl.text.trim()) ?? 0;
  double get _unitsPerCarton =>
      double.tryParse(_unitsPerCartonCtrl.text.trim()) ?? 0;
  double get _cartonCost =>
      double.tryParse(_cartonCostCtrl.text.trim()) ?? 0;
  double get _totalUnits => _cartons * _unitsPerCarton;
  double get _unitCost => _unitsPerCarton > 0 ? _cartonCost / _unitsPerCarton : 0;
  double get _newStock => widget.product.stock + _totalUnits;

  bool get _canSubmit => _cartons > 0 && _unitsPerCarton > 0 && !_busy;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _busy = true);
    try {
      // Single call persists the box config + applies the stock increment.
      // Both flow through the regular offline-first sync pipeline.
      await ref.read(productsRepositoryProvider).receiveShipment(
            product: widget.product,
            boxesReceived: _cartons,
            unitsPerBox: _unitsPerCarton.toInt(),
            boxCost: _cartonCost > 0 ? _cartonCost : null,
            note: _noteCtrl.text.trim().isEmpty
                ? null
                : _noteCtrl.text.trim(),
          );
      ref.read(syncEngineProvider).drain();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Received ${_fmt(_totalUnits)} items '
              '($_cartons box${_cartons == 1 ? '' : 'es'}) of '
              '"${widget.product.name}"',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to receive shipment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(scheme),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s5, AppTokens.s5, AppTokens.s5, AppTokens.s4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _currentStockCard(scheme),
                  const SizedBox(height: AppTokens.s4),
                  _sectionLabel('QUANTITY', scheme),
                  const SizedBox(height: 4),
                  Text(
                    'Stock will increase by  boxes × items per box.',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppTokens.s3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _numberField(
                          label: 'Boxes received',
                          controller: _cartonsCtrl,
                          allowDecimal: false,
                          hint: 'e.g. 4',
                        ),
                      ),
                      const SizedBox(width: AppTokens.s2),
                      Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppTokens.s2),
                      Expanded(
                        child: _numberField(
                          label: 'Items per box',
                          controller: _unitsPerCartonCtrl,
                          allowDecimal: true,
                          hint: 'e.g. 24',
                        ),
                      ),
                      const SizedBox(width: AppTokens.s2),
                      Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: Icon(
                          Icons.drag_handle_rounded,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: AppTokens.s2),
                      Expanded(
                        child: _resultField(
                          scheme,
                          label: 'Total units',
                          value: _totalUnits > 0 ? _fmt(_totalUnits) : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s4),
                  _sectionLabel('COST (OPTIONAL)', scheme),
                  const SizedBox(height: AppTokens.s2),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          label: 'Cost per box',
                          controller: _cartonCostCtrl,
                          allowDecimal: true,
                          hint: '0.00',
                          prefixText: widget.settings.currencySymbol,
                        ),
                      ),
                      const SizedBox(width: AppTokens.s2),
                      Expanded(
                        child: _resultField(
                          scheme,
                          label: 'Effective cost / unit',
                          value: _unitCost > 0
                              ? formatCurrency(_unitCost, widget.settings)
                              : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s4),
                  _sectionLabel('NOTE', scheme),
                  const SizedBox(height: AppTokens.s2),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 2,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'PO number, supplier, etc. (optional)',
                    ),
                  ),
                  if (_totalUnits > 0) ...[
                    const SizedBox(height: AppTokens.s4),
                    _summaryCard(scheme),
                  ],
                ],
              ),
            ),
            _footer(scheme),
          ],
        ),
      ),
    );
  }

  Widget _header(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s5, AppTokens.s5, AppTokens.s3, AppTokens.s4,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTokens.brandSuccess.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 20,
              color: AppTokens.brandSuccess,
            ),
          ),
          const SizedBox(width: AppTokens.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RECEIVE SHIPMENT',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme scheme) => Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: scheme.onSurfaceVariant,
        ),
      );

  Widget _currentStockCard(ColorScheme scheme) {
    final p = widget.product;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SKU: ${p.sku}',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current stock',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _fmt(p.stock),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: p.stock > 0 ? scheme.onSurface : scheme.error,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (p.isWeighed) ...[
            const SizedBox(width: 4),
            Text(
              'kg',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    required bool allowDecimal,
    required String hint,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              allowDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
            ),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _resultField(
    ColorScheme scheme, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: value == '—' ? scheme.onSurfaceVariant : scheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTokens.brandSuccess.withValues(alpha: 0.1),
            AppTokens.brandSuccess.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: AppTokens.brandSuccess.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 18,
            color: AppTokens.brandSuccess,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEW STOCK',
                  style: TextStyle(
                    color: AppTokens.brandSuccess,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmt(widget.product.stock)} → ${_fmt(_newStock)} (+${_fmt(_totalUnits)})',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s4),
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
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.cloud_sync_outlined,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Saves locally, syncs when online',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: AppTokens.s2),
          FilledButton.icon(
            icon: _busy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 16),
            label: const Text('Receive shipment'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.brandSuccess,
              foregroundColor: Colors.white,
            ),
            onPressed: _canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }
}
