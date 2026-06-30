import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/theme.dart';
import '../../../data/models/product.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';

enum _AdjustmentMode { set, delta }

/// The reasons we expose in the UI. The first ("Stock Count") is special-
/// cased by the backend as an absolute set; the rest are user-facing labels.
const _reasons = <String>[
  'Stock Count',
  'Restock',
  'Damage / Loss',
  'Promotion / Giveaway',
  'Correction',
  'Other',
];

class StockAdjustmentDialog extends ConsumerStatefulWidget {
  const StockAdjustmentDialog({
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
      builder: (_) => StockAdjustmentDialog(
        product: product,
        settings: settings,
      ),
    );
  }

  @override
  ConsumerState<StockAdjustmentDialog> createState() =>
      _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  late final TextEditingController _valueCtrl;
  _AdjustmentMode _mode = _AdjustmentMode.set;
  String _reason = 'Stock Count';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _valueCtrl = TextEditingController(
      text: widget.product.stock.toString(),
    );
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  /// Computes the resulting absolute stock based on the selected mode + value.
  /// Returns null if the input is invalid (negative result or unparsable).
  double? _computeNewStock() {
    final raw = _valueCtrl.text.trim();
    final parsed = double.tryParse(raw);
    if (parsed == null) return null;
    switch (_mode) {
      case _AdjustmentMode.set:
        if (parsed < 0) return null;
        return parsed;
      case _AdjustmentMode.delta:
        final next = widget.product.stock + parsed;
        if (next < 0) return null;
        return next;
    }
  }

  Future<void> _submit() async {
    final newStock = _computeNewStock();
    if (newStock == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(productsRepositoryProvider).adjustStock(
            productId: widget.product.id,
            newAbsoluteStock: newStock,
            // For "Set" mode we always use "Stock Count" so the backend
            // treats the value as absolute. For delta mode, use the user's
            // chosen reason (mapped to absolute server-side by the repo).
            reason: _mode == _AdjustmentMode.set ? 'Stock Count' : _reason,
          );
      // Best-effort immediate push.
      ref.read(syncEngineProvider).drain();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to adjust stock: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final newStock = _computeNewStock();
    final canSubmit = newStock != null && !_busy && newStock != widget.product.stock;
    final delta = newStock == null ? null : newStock - widget.product.stock;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                  // Current stock snapshot
                  _currentStockCard(scheme),
                  const SizedBox(height: AppTokens.s4),
                  // Mode toggle
                  _sectionLabel('ADJUSTMENT TYPE', scheme),
                  const SizedBox(height: AppTokens.s2),
                  _modeToggle(scheme),
                  const SizedBox(height: AppTokens.s4),
                  // Value input
                  _sectionLabel(
                    _mode == _AdjustmentMode.set
                        ? 'NEW STOCK COUNT'
                        : 'ADJUST BY',
                    scheme,
                  ),
                  const SizedBox(height: AppTokens.s2),
                  _valueInput(scheme),
                  // Preview of resulting stock
                  if (delta != null && delta != 0) ...[
                    const SizedBox(height: AppTokens.s3),
                    _previewLine(scheme, newStock!, delta),
                  ],
                  // Reason picker (only in delta mode — for "set" mode we
                  // always use "Stock Count" since it's a recount).
                  if (_mode == _AdjustmentMode.delta) ...[
                    const SizedBox(height: AppTokens.s4),
                    _sectionLabel('REASON', scheme),
                    const SizedBox(height: AppTokens.s2),
                    _reasonChips(scheme),
                  ],
                ],
              ),
            ),
            _footer(scheme, canSubmit),
          ],
        ),
      ),
    );
  }

  Widget _header(ColorScheme scheme) {
    final p = widget.product;
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
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
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
                  'ADJUST STOCK',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.name,
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
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

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
            formatQuantity(p.stock, isWeighed: p.isWeighed),
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

  Widget _sectionLabel(String text, ColorScheme scheme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _modeToggle(ColorScheme scheme) {
    return SegmentedButton<_AdjustmentMode>(
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      segments: const [
        ButtonSegment(
          value: _AdjustmentMode.set,
          icon: Icon(Icons.edit_outlined, size: 16),
          label: Text('Set new count'),
        ),
        ButtonSegment(
          value: _AdjustmentMode.delta,
          icon: Icon(Icons.add_circle_outline, size: 16),
          label: Text('Adjust by amount'),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (set) {
        setState(() {
          _mode = set.first;
          // Reset the field value when switching modes for a clean UX.
          _valueCtrl.text = _mode == _AdjustmentMode.set
              ? widget.product.stock.toString()
              : '';
        });
      },
    );
  }

  Widget _valueInput(ColorScheme scheme) {
    final isDelta = _mode == _AdjustmentMode.delta;
    return Row(
      children: [
        if (isDelta) ...[
          _stepperBtn(scheme, Icons.remove_rounded, () {
            final current = double.tryParse(_valueCtrl.text) ?? 0;
            _valueCtrl.text = (current - 1).toString();
            setState(() {});
          }),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: TextField(
            controller: _valueCtrl,
            keyboardType: TextInputType.numberWithOptions(
              signed: isDelta,
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                isDelta ? RegExp(r'[-0-9.]') : RegExp(r'[0-9.]'),
              ),
            ],
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              hintText: isDelta ? '0' : '0',
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
        ),
        if (isDelta) ...[
          const SizedBox(width: 8),
          _stepperBtn(scheme, Icons.add_rounded, () {
            final current = double.tryParse(_valueCtrl.text) ?? 0;
            _valueCtrl.text = (current + 1).toString();
            setState(() {});
          }),
        ],
      ],
    );
  }

  Widget _stepperBtn(ColorScheme scheme, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        width: 44,
        height: 48,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: scheme.outline),
        ),
        child: Icon(icon, size: 18, color: scheme.onSurface),
      ),
    );
  }

  Widget _previewLine(ColorScheme scheme, double newStock, double delta) {
    final positive = delta > 0;
    final color =
        positive ? AppTokens.brandSuccess : AppTokens.brandWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'New stock will be ${formatQuantity(newStock, isWeighed: widget.product.isWeighed)} '
              '${widget.product.isWeighed ? 'kg ' : ''}'
              '(${positive ? '+' : ''}${formatQuantity(delta, isWeighed: widget.product.isWeighed)})',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasonChips(ColorScheme scheme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _reasons.where((r) => r != 'Stock Count').map((r) {
        final selected = _reason == r;
        return InkWell(
          onTap: () => setState(() => _reason = r),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: AnimatedContainer(
            duration: AppTokens.motionFast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.5)
                    : scheme.outlineVariant,
              ),
            ),
            child: Text(
              r,
              style: TextStyle(
                color: selected ? scheme.primary : scheme.onSurface,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _footer(ColorScheme scheme, bool canSubmit) {
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
          // "Saves locally, syncs when online" — important to advertise
          // since this is the offline-first promise to the user.
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
            label: const Text('Save adjustment'),
            onPressed: canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }
}
