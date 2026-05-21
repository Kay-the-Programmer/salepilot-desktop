import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/theme.dart';
import '../../data/models/product.dart';
import '../../data/models/sale.dart';
import '../../data/models/store_settings.dart';
import '../auth/auth_controller.dart';
import 'cart_controller.dart';
import 'pos_data_controller.dart';
import 'widgets/barcode_listener.dart';
import 'widgets/cart_panel.dart';
import 'widgets/checkout_panel.dart';
import 'widgets/diagnostics_dialog.dart';
import 'widgets/held_sales_dialog.dart';
import 'widgets/product_grid.dart';
import 'widgets/receipt_dialog.dart';
import 'widgets/return_dialogs.dart';
import 'widgets/stock_alert_dialogs.dart';
import 'widgets/sync_status_pill.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _processing = false;
  bool _modalOpen = false;

  @override
  void initState() {
    super.initState();
    // Trigger initial pull + ensure sync engine is alive.
    Future.microtask(() {
      ref.read(posDataProvider.notifier).initialize();
      ref.read(syncEngineProvider); // instantiate
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(posDataProvider);
    final settings = data.settings ?? StoreSettings();
    final auth = ref.watch(authStateProvider);

    // Apply tax rate to the cart whenever settings change.
    ref.listen<PosDataState>(posDataProvider, (prev, next) {
      final rate = next.settings?.taxRate ?? 0;
      if (ref.read(cartProvider).taxRate != rate) {
        ref.read(cartProvider.notifier).setTaxRate(rate);
      }
    });

    final filtered = _filter(data.products, _query);

    final scheme = Theme.of(context).colorScheme;

    return BarcodeListener(
      paused: _modalOpen,
      onScan: (code) => _handleScan(code, data.products, settings),
      child: CallbackShortcuts(
        bindings: _shortcuts(settings),
        child: Scaffold(
          backgroundColor: scheme.surface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: _TopBar(
              settings: settings,
              userName: auth.session?.user.name ?? '',
              userEmail: auth.session?.user.email ?? '',
              userRole: auth.session?.user.role ?? '',
              loading: data.loading,
              onHeldSales: () => _withModal(() => showDialog(
                    context: context,
                    builder: (_) => const HeldSalesDialog(),
                  )),
              onRefresh: data.loading
                  ? null
                  : () => ref.read(posDataProvider.notifier).refresh(),
              onMenuSelect: (v) {
                switch (v) {
                  case 'logout':
                    ref.read(cartProvider.notifier).clear();
                    ref.read(authStateProvider.notifier).logout();
                  case 'returns':
                    _processReturn(settings);
                  case 'diagnostics':
                    _withModal(() => showDialog(
                          context: context,
                          builder: (_) => const DiagnosticsDialog(),
                        ));
                  case 'shortcuts':
                    _withModal(() => showDialog(
                          context: context,
                          builder: (_) => const _ShortcutsDialog(),
                        ));
                }
              },
            ),
          ),
          body: Row(
            children: [
              // Left: catalog
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppTokens.s4, AppTokens.s4, AppTokens.s4, 0),
                      child: _SearchBar(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        onClear: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        resultCount: _query.trim().isEmpty ? null : filtered.length,
                      ),
                    ),
                    if (data.loading)
                      const Expanded(
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      )
                    else if (data.error != null && data.products.isEmpty)
                      Expanded(
                        child: _ErrorState(
                          error: data.error!,
                          onRetry: () => ref.read(posDataProvider.notifier).initialize(),
                        ),
                      )
                    else
                      Expanded(
                        child: ProductGrid(
                          products: filtered,
                          settings: settings,
                          onProductTap: _addProduct,
                        ),
                      ),
                  ],
                ),
              ),
              // Right: cart + checkout column
              Container(
                width: 420,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: scheme.outlineVariant)),
                  color: scheme.surfaceContainerLowest,
                ),
                child: Column(
                  children: [
                    _OrderHeader(),
                    Divider(height: 1, color: scheme.outlineVariant),
                    CartPanel(settings: settings),
                    CheckoutPanel(
                      settings: settings,
                      customers: data.customers,
                      busy: _processing,
                      onHold: _holdCurrentSale,
                      onCharge: () => _charge(settings),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _shortcuts(StoreSettings settings) {
    final cart = ref.read(cartProvider);
    return {
      const SingleActivator(LogicalKeyboardKey.enter, control: true): () {
        if (cart.items.isNotEmpty && !_processing) _charge(settings);
      },
      const SingleActivator(LogicalKeyboardKey.keyH, control: true): () {
        if (cart.items.isNotEmpty) _holdCurrentSale();
      },
      const SingleActivator(LogicalKeyboardKey.keyL, control: true): () {
        ref.read(cartProvider.notifier).clear();
      },
      const SingleActivator(LogicalKeyboardKey.f1): () {
        _withModal(() => showDialog(context: context, builder: (_) => const DiagnosticsDialog()));
      },
    };
  }

  List<Product> _filter(List<Product> all, String q) {
    if (q.trim().isEmpty) return all;
    final n = q.trim().toLowerCase();
    return all.where((p) =>
        p.name.toLowerCase().contains(n) ||
        p.sku.toLowerCase().contains(n) ||
        (p.barcode ?? '').toLowerCase().contains(n)).toList();
  }

  void _addProduct(Product product) {
    final settings = ref.read(posDataProvider).settings ?? StoreSettings();
    final err = ref.read(cartProvider.notifier).addProduct(product);
    if (err == 'Out of stock') {
      _withModal(() => OutOfStockDialog.show(context, product, settings));
      return;
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name}: $err'), duration: const Duration(seconds: 2)),
      );
      return;
    }
    // Low-stock check: fire once when crossing the reorder threshold.
    final reorder = product.reorderPoint;
    if (reorder != null) {
      final inCart = ref
          .read(cartProvider)
          .items
          .where((i) => i.productId == product.id)
          .fold<double>(0, (s, i) => s + i.quantity);
      final remaining = product.stock - inCart;
      final justCrossed = (remaining <= reorder) && (remaining + product.step > reorder);
      if (justCrossed && !_modalOpen) {
        _withModal(() => LowStockAlertDialog.show(context, product, remaining));
      }
    }
  }

  void _handleScan(String code, List<Product> products, StoreSettings settings) {
    final trimmed = code.trim();
    final p = products.where((x) =>
        x.isActive && ((x.barcode != null && x.barcode == trimmed) || x.sku == trimmed)).toList();
    if (p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No product for code "$trimmed"'), duration: const Duration(seconds: 2)),
      );
      return;
    }
    _addProduct(p.first);
  }

  Future<void> _holdCurrentSale() async {
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty) return;
    final db = ref.read(appDatabaseProvider);
    await db.addHeldSale(jsonEncode(cart.items.map((e) => e.toJson()).toList()));
    ref.read(cartProvider.notifier).clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale held'), duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _charge(StoreSettings settings) async {
    final cart = ref.read(cartProvider);
    final totals = cart.totals();
    if (cart.items.isEmpty || cart.paymentMethod == null) return;

    setState(() => _processing = true);
    try {
      final isCash = cart.paymentMethod!.toLowerCase().contains('cash');
      final cashReceived = isCash ? cart.cashReceived : null;
      final changeDue = isCash ? (cart.cashReceived - totals.total).clamp(0, double.infinity).toDouble() : null;

      final salesRepo = ref.read(salesRepositoryProvider);
      final sale = salesRepo.buildSale(
        cart: cart.items,
        subtotal: totals.subtotal,
        tax: totals.tax,
        discount: totals.discountAmount,
        total: totals.total,
        amountPaid: totals.total,
        paymentStatus: 'paid',
        storeCreditUsed: totals.appliedStoreCredit,
        customerId: cart.customer?.id,
        customerName: cart.customer?.name,
        cashReceived: cashReceived,
        changeDue: changeDue,
        payments: [
          Payment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            date: DateTime.now().toUtc().toIso8601String(),
            amount: totals.total,
            method: cart.paymentMethod!,
          ),
        ],
      );

      await salesRepo.finalizeSale(sale);
      // Best-effort immediate push (offline-safe — queue takes over otherwise).
      unawaited(ref.read(syncEngineProvider).drain());

      ref.read(cartProvider.notifier).clear();
      _searchCtrl.clear();
      setState(() => _query = '');

      if (!mounted) return;
      _modalOpen = true;
      await showDialog(
        context: context,
        builder: (_) => ReceiptDialog(sale: sale, settings: settings),
      );
      _modalOpen = false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sale failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _withModal(Future<dynamic> Function() opener) async {
    _modalOpen = true;
    try {
      await opener();
    } finally {
      _modalOpen = false;
    }
  }

  Future<void> _processReturn(StoreSettings settings) async {
    _modalOpen = true;
    try {
      final sale = await FindSaleDialog.show(context, settings);
      if (sale == null) return;
      if (!mounted) return;
      final record = await ReturnFormDialog.show(context, sale, settings);
      if (record == null) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Refund processed: \$${record.refundAmount.toStringAsFixed(2)} via ${record.refundMethod}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      _modalOpen = false;
    }
  }
}

class _ShortcutsDialog extends StatelessWidget {
  const _ShortcutsDialog();

  @override
  Widget build(BuildContext context) {
    const rows = <List<String>>[
      ['Ctrl + Enter', 'Charge current sale'],
      ['Ctrl + H', 'Hold current sale'],
      ['Ctrl + L', 'Clear cart'],
      ['F1', 'Open sync diagnostics'],
      ['Scanner', 'USB/Bluetooth scanners that emit Enter-terminated keystrokes work everywhere except inside text fields'],
    ];
    return AlertDialog(
      title: const Text('Keyboard shortcuts'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: rows.map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r[0],
                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r[1])),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
      ],
    );
  }
}

