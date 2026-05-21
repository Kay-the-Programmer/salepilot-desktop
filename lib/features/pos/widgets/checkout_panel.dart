import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/store_settings.dart';
import '../../../shared/currency.dart';
import '../cart_controller.dart';
import 'customer_form_dialog.dart';

class CheckoutPanel extends ConsumerStatefulWidget {
  const CheckoutPanel({
    super.key,
    required this.settings,
    required this.customers,
    required this.onCharge,
    required this.onHold,
    required this.busy,
  });

  final StoreSettings settings;
  final List<Customer> customers;
  final VoidCallback onCharge;
  final VoidCallback onHold;
  final bool busy;

  @override
  ConsumerState<CheckoutPanel> createState() => _CheckoutPanelState();
}

class _CheckoutPanelState extends ConsumerState<CheckoutPanel> {
  final _discountCtrl = TextEditingController(text: '');
  final _cashCtrl = TextEditingController();
  bool _showDiscount = false;

  @override
  void dispose() {
    _discountCtrl.dispose();
    _cashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final totals = cart.totals();
    final scheme = Theme.of(context).colorScheme;
    final methods = widget.settings.effectiveMethods;
    final isCash = (cart.paymentMethod ?? '').toLowerCase().contains('cash');
    final canCharge = cart.items.isNotEmpty &&
        cart.paymentMethod != null &&
        (!isCash || cart.cashReceived >= totals.total) &&
        !widget.busy;
    final changeDue = (cart.cashReceived - totals.total).clamp(0, double.infinity).toDouble();
    final cashShort = isCash && cart.cashReceived > 0 && cart.cashReceived < totals.total;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.all(AppTokens.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _customerRow(cart, scheme),
          const SizedBox(height: AppTokens.s3),
          // Compact totals
          _summary(totals, scheme),
          const SizedBox(height: AppTokens.s3),
          _bigTotal(totals.total, scheme),
          const SizedBox(height: AppTokens.s3),
          _miniActions(cart, totals, scheme),
          if (_showDiscount) ...[
            const SizedBox(height: AppTokens.s2),
            _discountField(cart, scheme),
          ],
          const SizedBox(height: AppTokens.s4),
          Text(
            'PAYMENT METHOD',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.s2),
          _paymentMethods(methods, cart.paymentMethod, scheme),
          if (isCash) ...[
            const SizedBox(height: AppTokens.s3),
            _cashInput(scheme, totals.total, changeDue, cashShort),
          ],
          const SizedBox(height: AppTokens.s4),
          Row(
            children: [
              SizedBox(
                width: 96,
                height: 56,
                child: OutlinedButton(
                  onPressed: cart.items.isEmpty ? null : widget.onHold,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pause_circle_outline, size: 18),
                      SizedBox(height: 2),
                      Text('Hold', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.s2),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    icon: widget.busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.bolt_rounded, size: 20),
                    label: Text(
                      widget.busy ? 'Processing…' : 'Charge ${formatCurrency(totals.total, widget.settings)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: canCharge ? AppTokens.brandSuccess : null,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: scheme.surfaceContainerHigh,
                      disabledForegroundColor: scheme.onSurfaceVariant,
                    ),
                    onPressed: canCharge ? widget.onCharge : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customerRow(CartState cart, ColorScheme scheme) {
    final hasCustomer = cart.customer != null;
    return InkWell(
      onTap: _pickCustomer,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: hasCustomer
              ? scheme.primary.withValues(alpha: 0.08)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
            color: hasCustomer ? scheme.primary.withValues(alpha: 0.3) : scheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: hasCustomer ? scheme.primary : scheme.surfaceContainerHigh,
              child: Icon(
                hasCustomer ? Icons.person : Icons.person_outline,
                size: 16,
                color: hasCustomer ? Colors.white : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cart.customer?.name ?? 'Walk-in customer',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: hasCustomer ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  if (hasCustomer && (cart.customer!.storeCredit) > 0)
                    Text(
                      '${formatCurrency(cart.customer!.storeCredit, widget.settings)} store credit',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
                    ),
                ],
              ),
            ),
            if (hasCustomer)
              IconButton(
                icon: const Icon(Icons.close, size: 14),
                visualDensity: VisualDensity.compact,
                onPressed: () => ref.read(cartProvider.notifier).setCustomer(null),
                tooltip: 'Remove customer',
              )
            else
              Icon(Icons.chevron_right, size: 18, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _summary(CartTotals totals, ColorScheme scheme) {
    Widget row(String label, String value, {bool dim = false, Color? color}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color ?? (dim ? scheme.onSurfaceVariant : scheme.onSurface),
                fontSize: 12.5,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color ?? (dim ? scheme.onSurfaceVariant : scheme.onSurface),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        row('Subtotal', formatCurrency(totals.subtotal, widget.settings)),
        if (totals.discountAmount > 0)
          row('Discount', '-${formatCurrency(totals.discountAmount, widget.settings)}',
              color: AppTokens.brandSuccess),
        if (totals.tax > 0)
          row(
            '${widget.settings.taxName} (${widget.settings.taxRate.toStringAsFixed(1)}%)',
            formatCurrency(totals.tax, widget.settings),
            dim: true,
          ),
        if (totals.appliedStoreCredit > 0)
          row('Store credit', '-${formatCurrency(totals.appliedStoreCredit, widget.settings)}',
              color: scheme.primary),
      ],
    );
  }

  Widget _bigTotal(double total, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.08),
            scheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              'TOTAL',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Text(
            formatCurrency(total, widget.settings),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: scheme.primary,
              letterSpacing: -0.8,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniActions(CartState cart, CartTotals totals, ColorScheme scheme) {
    final hasCredit = (cart.customer?.storeCredit ?? 0) > 0;
    return Row(
      children: [
        Expanded(
          child: _miniBtn(
            scheme,
            icon: _showDiscount ? Icons.percent : Icons.discount_outlined,
            label: totals.discountAmount > 0
                ? 'Discount: ${formatCurrency(totals.discountAmount, widget.settings)}'
                : 'Add discount',
            active: totals.discountAmount > 0 || _showDiscount,
            onTap: () => setState(() => _showDiscount = !_showDiscount),
          ),
        ),
        if (hasCredit) ...[
          const SizedBox(width: 6),
          Expanded(
            child: _miniBtn(
              scheme,
              icon: Icons.credit_score,
              label: totals.appliedStoreCredit > 0 ? 'Credit applied' : 'Use credit',
              active: totals.appliedStoreCredit > 0,
              onTap: () => ref.read(cartProvider.notifier).applyStoreCredit(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _miniBtn(ColorScheme scheme,
      {required IconData icon,
      required String label,
      required bool active,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? scheme.primary.withValues(alpha: 0.1) : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(
              color: active ? scheme.primary.withValues(alpha: 0.4) : scheme.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: active ? scheme.primary : scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? scheme.primary : scheme.onSurface,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _discountField(CartState cart, ColorScheme scheme) {
    return TextField(
      controller: _discountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autofocus: true,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Discount value',
        prefixIcon: Icon(
          cart.discountType == DiscountType.amount ? Icons.attach_money : Icons.percent,
          size: 16,
        ),
        suffix: SegmentedButton<DiscountType>(
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8, vertical: 0)),
            textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11)),
          ),
          segments: const [
            ButtonSegment(value: DiscountType.amount, label: Text('\$')),
            ButtonSegment(value: DiscountType.percentage, label: Text('%')),
          ],
          selected: {cart.discountType},
          onSelectionChanged: (set) {
            ref.read(cartProvider.notifier).setDiscount(
                  double.tryParse(_discountCtrl.text) ?? 0,
                  set.first,
                );
          },
        ),
      ),
      onChanged: (v) => ref.read(cartProvider.notifier).setDiscount(
            double.tryParse(v) ?? 0,
            cart.discountType,
          ),
    );
  }

  Widget _paymentMethods(List methods, String? selected, ColorScheme scheme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: methods.map<Widget>((m) {
        final isSelected = selected == m.name;
        return InkWell(
          onTap: () => ref.read(cartProvider.notifier).setPaymentMethod(m.name),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? scheme.primary : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isSelected ? scheme.primary : scheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _iconForMethod(m.name),
                  size: 14,
                  color: isSelected ? Colors.white : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  m.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : scheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
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
    if (n.contains('mobile') || n.contains('mtn') || n.contains('airtel') || n.contains('lenco')) {
      return Icons.phone_iphone_outlined;
    }
    if (n.contains('bank') || n.contains('transfer')) return Icons.account_balance_outlined;
    return Icons.payment_outlined;
  }

  Widget _cashInput(ColorScheme scheme, double total, double changeDue, bool short) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.s3),
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
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              labelText: 'Cash received',
              prefixText: widget.settings.currencySymbol,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => ref.read(cartProvider.notifier).setCashReceived(double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                short ? 'Short' : 'Change due',
                style: TextStyle(
                  color: short ? scheme.error : scheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                short
                    ? '-${formatCurrency(total - changeDue.clamp(0, double.infinity), widget.settings)}'
                    : formatCurrency(changeDue, widget.settings),
                style: TextStyle(
                  color: short ? scheme.error : AppTokens.brandSuccess,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          // Quick cash buttons
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickCashAmounts(total).map((amount) {
              return _quickCashChip(scheme, amount);
            }).toList(),
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
        _cashCtrl.text = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
        ref.read(cartProvider.notifier).setCashReceived(amount);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          formatCurrency(amount, widget.settings),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustomer() async {
    final picked = await showDialog<Customer?>(
      context: context,
      builder: (ctx) => _CustomerPickerDialog(customers: widget.customers),
    );
    if (picked != null) {
      ref.read(cartProvider.notifier).setCustomer(picked);
    }
  }
}

class _CustomerPickerDialog extends StatefulWidget {
  const _CustomerPickerDialog({required this.customers});
  final List<Customer> customers;

  @override
  State<_CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<_CustomerPickerDialog> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _q.isEmpty
        ? widget.customers
        : widget.customers
            .where((c) =>
                c.name.toLowerCase().contains(_q.toLowerCase()) ||
                (c.phone ?? '').contains(_q) ||
                (c.email ?? '').toLowerCase().contains(_q.toLowerCase()))
            .toList();

    return AlertDialog(
      title: const Text('Choose customer'),
      content: SizedBox(
        width: 420,
        height: 520,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name, phone, or email…',
                prefixIcon: Icon(Icons.search, size: 18),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: AppTokens.s2),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: Text(
                _q.trim().isEmpty
                    ? 'New customer…'
                    : 'New customer named "${_q.trim()}"',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                side: BorderSide(color: scheme.primary.withValues(alpha: 0.4), style: BorderStyle.solid),
                foregroundColor: scheme.primary,
              ),
              onPressed: () async {
                final created = await CustomerFormDialog.show(context,
                    initialName: _q.trim().isEmpty ? null : _q.trim());
                if (created != null && context.mounted) {
                  Navigator.pop(context, created);
                }
              },
            ),
            const SizedBox(height: AppTokens.s2),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('No matches',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
                          tileColor: scheme.surfaceContainerLow,
                          leading: CircleAvatar(
                            backgroundColor: scheme.primary.withValues(alpha: 0.12),
                            child: Text(
                              c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                            ),
                          ),
                          title: Text(c.name,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text([c.phone, c.email].whereType<String>().join(' · ')),
                          trailing: c.storeCredit > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTokens.brandSuccess.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    c.storeCredit.toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: AppTokens.brandSuccess,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                )
                              : null,
                          onTap: () => Navigator.pop(context, c),
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
}
