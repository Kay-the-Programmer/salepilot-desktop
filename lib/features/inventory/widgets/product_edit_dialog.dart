import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/theme.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import 'category_picker_dialog.dart';

/// Edit a product's catalog metadata (name, price, reorder point, etc).
///
/// Intentionally excludes stock and status:
///   - Stock has its own focused [StockAdjustmentDialog] with reason codes.
///   - Status (archive/unarchive) is a destructive single-action; deserves
///     its own confirmation flow.
///
/// All changes go through `ProductsRepository.updateProduct()` which is
/// offline-first: writes to local SQLite immediately, enqueues a PUT for
/// the sync engine to push when online.
class ProductEditDialog extends ConsumerStatefulWidget {
  const ProductEditDialog({super.key, required this.product});
  final Product product;

  static Future<void> show(BuildContext context, Product product) {
    return showDialog(
      context: context,
      builder: (_) => ProductEditDialog(product: product),
    );
  }

  @override
  ConsumerState<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends ConsumerState<ProductEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _barcodeCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _costCtrl;
  late final TextEditingController _reorderCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _unitsPerBoxCtrl;
  late final TextEditingController _boxCostCtrl;
  late String _unitOfMeasure;
  bool _busy = false;
  // null = nothing picked yet (preserve original); empty string = explicit
  // "clear category"; otherwise = newly picked category id.
  String? _pickedCategoryId;
  String? _pickedCategoryName;
  bool _categoryTouched = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p.name);
    _skuCtrl = TextEditingController(text: p.sku);
    _barcodeCtrl = TextEditingController(text: p.barcode ?? '');
    _brandCtrl = TextEditingController(text: p.brand ?? '');
    _priceCtrl = TextEditingController(text: _fmtNum(p.price));
    _costCtrl = TextEditingController(
      text: p.costPrice != null ? _fmtNum(p.costPrice!) : '',
    );
    _reorderCtrl = TextEditingController(
      text: p.reorderPoint != null ? _fmtNum(p.reorderPoint!) : '',
    );
    _descCtrl = TextEditingController(text: p.description);
    _unitsPerBoxCtrl = TextEditingController(
      text: p.unitsPerBox != null ? p.unitsPerBox!.toString() : '',
    );
    _boxCostCtrl = TextEditingController(
      text: p.boxCost != null ? _fmtNum(p.boxCost!) : '',
    );
    _unitOfMeasure = p.unitOfMeasure;
    _pickedCategoryId = p.categoryId;
  }

  static String _fmtNum(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _costCtrl.dispose();
    _reorderCtrl.dispose();
    _descCtrl.dispose();
    _unitsPerBoxCtrl.dispose();
    _boxCostCtrl.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    final p = widget.product;
    return _nameCtrl.text.trim() != p.name ||
        _skuCtrl.text.trim() != p.sku ||
        _barcodeCtrl.text.trim() != (p.barcode ?? '') ||
        _brandCtrl.text.trim() != (p.brand ?? '') ||
        (double.tryParse(_priceCtrl.text) ?? -1) != p.price ||
        (double.tryParse(_costCtrl.text)) != p.costPrice ||
        (double.tryParse(_reorderCtrl.text)) != p.reorderPoint ||
        _descCtrl.text.trim() != p.description ||
        _unitOfMeasure != p.unitOfMeasure ||
        (int.tryParse(_unitsPerBoxCtrl.text)) != p.unitsPerBox ||
        (double.tryParse(_boxCostCtrl.text)) != p.boxCost ||
        _categoryTouched;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges()) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(productsRepositoryProvider).updateProduct(
            productId: widget.product.id,
            name: _nameCtrl.text.trim(),
            sku: _skuCtrl.text.trim(),
            barcode: _emptyToNull(_barcodeCtrl.text),
            brand: _emptyToNull(_brandCtrl.text),
            price: double.parse(_priceCtrl.text),
            costPrice: double.tryParse(_costCtrl.text),
            reorderPoint: double.tryParse(_reorderCtrl.text),
            description: _descCtrl.text.trim(),
            unitOfMeasure: _unitOfMeasure,
            categoryId: _categoryTouched
                ? Value(_emptyToNull(_pickedCategoryId ?? ''))
                : const Value.absent(),
            // Pass the box config so the server stays in sync with what the
            // receive flow has been writing locally.
            unitsPerBox: Value(int.tryParse(_unitsPerBoxCtrl.text.trim())),
            boxCost: Value(double.tryParse(_boxCostCtrl.text.trim())),
          );
      ref.read(syncEngineProvider).drain();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _emptyToNull(String s) => s.trim().isEmpty ? null : s.trim();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(scheme),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.s5, AppTokens.s5, AppTokens.s5, AppTokens.s4,
                  ),
                  child: _formBody(scheme),
                ),
              ),
              _footer(scheme),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────
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
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(Icons.edit_outlined, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: AppTokens.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EDIT PRODUCT',
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
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _formBody(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── Section 1: Identity ─────────────────────────────────────
        _sectionTitle('Identity', scheme),
        const SizedBox(height: AppTokens.s3),
        _Field(
          label: 'Name',
          required: true,
          child: TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'e.g. Coca-Cola 500ml'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
        ),
        const SizedBox(height: AppTokens.s3),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'SKU',
                required: true,
                child: TextFormField(
                  controller: _skuCtrl,
                  style: const TextStyle(
                    fontFamily: 'Consolas',
                    fontFamilyFallback: ['monospace'],
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(hintText: 'COKE-500'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'SKU is required'
                      : null,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.s3),
            Expanded(
              child: _Field(
                label: 'Barcode',
                child: TextFormField(
                  controller: _barcodeCtrl,
                  style: const TextStyle(
                    fontFamily: 'Consolas',
                    fontFamilyFallback: ['monospace'],
                    fontSize: 13,
                  ),
                  decoration: const InputDecoration(hintText: 'Optional'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s3),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Brand',
                child: TextFormField(
                  controller: _brandCtrl,
                  decoration: const InputDecoration(hintText: 'Optional'),
                ),
              ),
            ),
            const SizedBox(width: AppTokens.s3),
            Expanded(
              child: _Field(
                label: 'Category',
                child: _categoryPickerField(),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTokens.s5),
        // ─── Section 2: Pricing ───────────────────────────────────────
        _sectionTitle('Pricing', scheme),
        const SizedBox(height: AppTokens.s3),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Sell price',
                required: true,
                child: TextFormField(
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(hintText: '0.00'),
                  validator: (v) {
                    final p = double.tryParse(v ?? '');
                    if (p == null) return 'Required, must be a number';
                    if (p < 0) return 'Cannot be negative';
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: AppTokens.s3),
            Expanded(
              child: _Field(
                label: 'Cost price',
                helper: 'For margin reporting',
                child: TextFormField(
                  controller: _costCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(hintText: '0.00'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final p = double.tryParse(v);
                    if (p == null) return 'Must be a number';
                    if (p < 0) return 'Cannot be negative';
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTokens.s5),
        // ─── Section 3: Inventory ─────────────────────────────────────
        _sectionTitle('Inventory', scheme),
        const SizedBox(height: AppTokens.s3),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Unit',
                helper: 'How this product is sold',
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const [
                    ButtonSegment(value: 'unit', label: Text('Unit')),
                    ButtonSegment(value: 'kg', label: Text('Weighed (kg)')),
                  ],
                  selected: {_unitOfMeasure},
                  onSelectionChanged: (s) =>
                      setState(() => _unitOfMeasure = s.first),
                ),
              ),
            ),
            const SizedBox(width: AppTokens.s3),
            Expanded(
              child: _Field(
                label: 'Reorder point',
                helper: 'Low-stock threshold',
                child: TextFormField(
                  controller: _reorderCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(hintText: 'Optional'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final p = double.tryParse(v);
                    if (p == null) return 'Must be a number';
                    if (p < 0) return 'Cannot be negative';
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTokens.s5),
        // ─── Section 4: Bulk packaging ────────────────────────────────
        _sectionTitle('Bulk packaging', scheme),
        const SizedBox(height: AppTokens.s3),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Items per box',
                helper: 'Used when receiving shipments',
                child: TextFormField(
                  controller: _unitsPerBoxCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration:
                      const InputDecoration(hintText: 'e.g. 24'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) {
                      return 'Must be a positive whole number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: AppTokens.s3),
            Expanded(
              child: _Field(
                label: 'Cost per box',
                helper: 'Optional — for margin tracking',
                child: TextFormField(
                  controller: _boxCostCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(hintText: '0.00'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final n = double.tryParse(v);
                    if (n == null) return 'Must be a number';
                    if (n < 0) return 'Cannot be negative';
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTokens.s5),
        // ─── Section 5: Description ───────────────────────────────────
        _sectionTitle('Description', scheme),
        const SizedBox(height: AppTokens.s3),
        TextFormField(
          controller: _descCtrl,
          maxLines: 3,
          minLines: 2,
          decoration: const InputDecoration(
            hintText: 'Optional notes for staff or receipts',
          ),
        ),
      ],
    );
  }

  /// Visual proxy for the category picker. Looks like an input field but
  /// opens the [CategoryPickerDialog] when tapped.
  Widget _categoryPickerField() {
    return Consumer(
      builder: (context, ref, _) {
        final scheme = Theme.of(context).colorScheme;
        // Resolve the name to show: the latest pick (if any), else look up
        // the original product's categoryId in the categories cache.
        final categoriesAsync = ref.watch(categoriesListProvider);
        final id = _categoryTouched
            ? _pickedCategoryId
            : widget.product.categoryId;
        String? resolvedName;
        if (_categoryTouched) {
          resolvedName = _pickedCategoryName;
        } else if (id != null && id.isNotEmpty) {
          final all = categoriesAsync.asData?.value ?? const <Category>[];
          for (final c in all) {
            if (c.id == id) {
              resolvedName = c.name;
              break;
            }
          }
        }
        final hasValue = (id != null && id.isNotEmpty);
        return InkWell(
          onTap: () async {
            final picked = await CategoryPickerDialog.show(
              context,
              currentId: id,
            );
            if (picked == null) return; // cancelled
            setState(() {
              _categoryTouched = true;
              _pickedCategoryId = picked.id.isEmpty ? null : picked.id;
              _pickedCategoryName = picked.id.isEmpty ? null : picked.name;
            });
          },
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: scheme.outline),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasValue ? (resolvedName ?? id) : 'None',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasValue
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text, ColorScheme scheme) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(width: AppTokens.s2),
        Expanded(
          child: Container(
            height: 1,
            color: scheme.outlineVariant,
          ),
        ),
      ],
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
            label: const Text('Save changes'),
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Field wrapper: label above + input + optional helper text below.
/// Same pattern Google Forms / Microsoft Forms use — much clearer than
/// floating labels in dense forms.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.child,
    this.helper,
    this.required = false,
  });

  final String label;
  final Widget child;
  final String? helper;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 3),
              Text(
                '*',
                style: TextStyle(
                  color: scheme.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper!,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
