import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';
import '../cart_controller.dart';

/// Focused payment screen. Opens as a modal dialog when the cashier taps
/// "Charge" — encapsulates method selection, cash entry, and confirmation
/// so the main POS screen can keep the cart list prominent.
///
/// On confirm, this writes `paymentMethod` and `cashReceived` to the cart
/// state, then calls [onConfirm]. The host POS screen handles the actual
/// sale finalization (build sale, push to repo, show receipt).
class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({
    super.key,
    required this.settings,
    required this.onConfirm,
  });

  final StoreSettings settings;
  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context, {
    required StoreSettings settings,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PaymentSheet(
        settings: settings,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  late final TextEditingController _cashCtrl;

  @override
  void initState() {
    super.initState();
    final initialCash = ref.read(cartProvider).cashReceived;
    _cashCtrl = TextEditingController(
      text: initialCash > 0
          ? initialCash.toStringAsFixed(
              initialCash.truncateToDouble() == initialCash ? 0 : 2,
            )
          : '',
    );
  }

  @override
  void dispose() {
    _cashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totals = ref.watch(cartTotalsProvider);
    final paymentMethod = ref.watch(cartProvider.select((s) => s.paymentMethod));
    final cashReceived = ref.watch(cartProvider.select((s) => s.cashReceived));
    final canCharge = ref.watch(canChargeProvider);
    final blocker = ref.watch(chargeBlockerProvider);

    final methods = widget.settings.effectiveMethods;
    final isCash = (paymentMethod ?? '').toLowerCase().contains('cash');
    final changeDue =
        (cashReceived - totals.total).clamp(0, double.infinity).toDouble();
    final cashShort = isCash && cashReceived > 0 && cashReceived < totals.total;

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
            // ─── Header ───────────────────────────────────────────────
            _header(scheme, totals.total),
            const Divider(height: 1),
            // ─── Body ─────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s5, AppTokens.s5, AppTokens.s5, AppTokens.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sectionLabel('PAYMENT METHOD', scheme),
                    const SizedBox(height: AppTokens.s2),
                    _paymentMethods(methods, paymentMethod, scheme),
                    if (isCash) ...[
                      const SizedBox(height: AppTokens.s4),
                      _sectionLabel('CASH RECEIVED', scheme),
                      const SizedBox(height: AppTokens.s2),
                      _cashInput(scheme, totals.total, changeDue, cashShort),
                    ],
                  ],
                ),
              ),
            ),
            // ─── Footer ───────────────────────────────────────────────
            _footer(scheme, totals.total, canCharge, blocker),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  Widget _header(ColorScheme scheme, double total) {
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
            child: Icon(Icons.payments_rounded, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: AppTokens.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TAKE PAYMENT',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatCurrency(total, widget.settings),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
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

  Widget _paymentMethods(List methods, String? selected, ColorScheme scheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: methods.map<Widget>((m) {
        final isSelected = selected == m.name;
        return InkWell(
          onTap: () => ref.read(cartProvider.notifier).setPaymentMethod(m.name),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: AnimatedContainer(
            duration: AppTokens.motionFast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isSelected ? scheme.primary : scheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected ? AppTokens.shadowSm() : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconForMethod(m.name),
                  size: 16,
                  color: isSelected ? Colors.white : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  m.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : scheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForMethod(String name) {
    final n = name.toLowerCase();
    if (n.contains('cash')) return Icons.payments_outlined;
    if (n.contains('card')) return Icons.credit_card_outlined;
    if (n.contains('mobile') ||
        n.contains('mtn') ||
        n.contains('airtel') ||
        n.contains('lenco')) {
      return Icons.phone_iphone_outlined;
    }
    if (n.contains('bank') || n.contains('transfer')) {
      return Icons.account_balance_outlined;
    }
    return Icons.payment_outlined;
  }

  Widget _cashInput(ColorScheme scheme, double total, double changeDue, bool short) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: short ? scheme.error.withValues(alpha: 0.4) : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _cashCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            autofocus: true,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              prefixText: widget.settings.currencySymbol,
              prefixStyle: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => ref
                .read(cartProvider.notifier)
                .setCashReceived(double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: AppTokens.s2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                short ? 'Still short' : 'Change due',
                style: TextStyle(
                  color: short ? scheme.error : scheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                short
                    ? '-${formatCurrency(total - changeDue.clamp(0, double.infinity), widget.settings)}'
                    : formatCurrency(changeDue, widget.settings),
                style: TextStyle(
                  color: short ? scheme.error : AppTokens.brandSuccess,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s3),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickCashAmounts(total)
                .map((a) => _quickCashChip(scheme, a))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<double> _quickCashAmounts(double total) {
    final amounts = <double>{total.ceilToDouble()};
    final base = total.ceil();
    for (final step in [5, 10, 20, 50, 100, 200, 500]) {
      if (step >= base) amounts.add(step.toDouble());
      if (amounts.length >= 5) break;
    }
    final list = amounts.toList()..sort();
    return list.take(5).toList();
  }

  Widget _quickCashChip(ColorScheme scheme, double amount) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      onTap: () {
        _cashCtrl.text = amount.toStringAsFixed(
          amount.truncateToDouble() == amount ? 0 : 2,
        );
        ref.read(cartProvider.notifier).setCashReceived(amount);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          formatCurrency(amount, widget.settings),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Widget _footer(
    ColorScheme scheme,
    double total,
    bool canCharge,
    String? blocker,
  ) {
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
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: AppTokens.s2),
          Expanded(
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  canCharge
                      ? 'Complete sale · ${formatCurrency(total, widget.settings)}'
                      : (blocker ?? 'Choose a payment method'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      canCharge ? AppTokens.brandSuccess : null,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: scheme.surfaceContainerHigh,
                  disabledForegroundColor: scheme.onSurfaceVariant,
                ),
                onPressed: canCharge
                    ? () {
                        Navigator.of(context).pop();
                        widget.onConfirm();
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
