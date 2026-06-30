import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/theme.dart';
import '../../../data/models/category.dart';
import 'category_picker_dialog.dart';
import 'image_picker_field.dart';

/// Create a brand-new product. Offline-first: if the server is unreachable,
/// we still create a local-only row with a `local-*` ID and queue the POST.
/// The next online pullFromServer reconciles by replacing the local cache.
class ProductCreateDialog extends ConsumerStatefulWidget {
  const ProductCreateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ProductCreateDialog(),
    );
  }

  @override
  ConsumerState<ProductCreateDialog> createState() =>
      _ProductCreateDialogState();
}

class _ProductCreateDialogState extends ConsumerState<ProductCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController()
    // Rebuild on name change so the AI button enables/disables in sync
    // with whether there's anything to feed the model.
    ..addListener(() => setState(() {}));
  final _skuCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _reorderCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _unitOfMeasure = 'unit';
  Category? _category;
  List<String> _imagePaths = const [];
  bool _busy = false;
  bool _generatingDescription = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _costCtrl.dispose();
    _stockCtrl.dispose();
    _reorderCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // Category is required by the backend.
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a category')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final repo = ref.read(productsRepositoryProvider);
      final created = await repo.createProduct(
        name: _nameCtrl.text.trim(),
        sku: _skuCtrl.text.trim(),
        barcode: _emptyToNull(_barcodeCtrl.text),
        brand: _emptyToNull(_brandCtrl.text),
        categoryId: _category!.id,
        price: double.parse(_priceCtrl.text),
        costPrice: double.tryParse(_costCtrl.text),
        initialStock: double.tryParse(_stockCtrl.text) ?? 0,
        reorderPoint: double.tryParse(_reorderCtrl.text),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        unitOfMeasure: _unitOfMeasure,
        imagePaths: _imagePaths,
      );
      // Kick off drain in case we fell back to local + queue.
      ref.read(syncEngineProvider).drain();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              created.id.startsWith('local-')
                  ? 'Saved "${created.name}" — will sync when online'
                  : 'Created "${created.name}"',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _emptyToNull(String s) => s.trim().isEmpty ? null : s.trim();

  /// Ask the backend's Gemini integration to draft a description from the
  /// product name (+ category name if picked). Online-only — gated by the
  /// sync engine's `online` flag in the UI.
  Future<void> _generateDescription() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a product name first')),
      );
      return;
    }
    setState(() => _generatingDescription = true);
    try {
      final ai = ref.read(aiServiceProvider);
      final text = await ai.generateDescription(
        productName: name,
        category: _category?.name,
      );
      if (!mounted) return;
      setState(() => _descCtrl.text = text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_aiErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingDescription = false);
    }
  }

  String _aiErrorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('quota')) return 'AI quota reached for today — try again later.';
    if (msg.contains('Cannot reach') || msg.contains('Network')) {
      return 'AI needs an internet connection.';
    }
    return 'Couldn\'t generate description: $msg';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
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
            child: Icon(
              Icons.add_box_outlined,
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
                  'NEW PRODUCT',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add an item to your catalog',
                  style: Theme.of(context).textTheme.titleMedium,
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
        _sectionTitle('Identity', scheme),
        const SizedBox(height: AppTokens.s3),
        _Field(
          label: 'Name',
          required: true,
          child: TextFormField(
            controller: _nameCtrl,
            autofocus: true,
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
                required: true,
                child: _categoryPickerField(scheme),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.s5),
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
        _sectionTitle('Inventory', scheme),
        const SizedBox(height: AppTokens.s3),
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Unit',
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
                label: 'Starting stock',
                child: TextFormField(
                  controller: _stockCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(hintText: '0'),
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
        _sectionTitle('Photos', scheme),
        const SizedBox(height: AppTokens.s3),
        ImagePickerField(
          paths: _imagePaths,
          onChanged: (next) => setState(() => _imagePaths = next),
        ),

        const SizedBox(height: AppTokens.s5),
        Row(
          children: [
            Expanded(child: _sectionTitle('Description', scheme)),
            _generateWithAiButton(scheme),
          ],
        ),
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

  Widget _categoryPickerField(ColorScheme scheme) {
    final hasValue = _category != null;
    return InkWell(
      onTap: () async {
        final picked = await CategoryPickerDialog.show(
          context,
          currentId: _category?.id,
        );
        if (picked == null) return;
        setState(() {
          _category = picked.id.isEmpty ? null : picked;
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
                hasValue ? _category!.name : 'Pick a category…',
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
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ],
    );
  }

  /// "Generate with AI" pill button. Disabled when offline or while the
  /// name field is empty — both states have informative tooltips so it's
  /// clear what's blocking.
  Widget _generateWithAiButton(ColorScheme scheme) {
    final online = ref.watch(
      syncStatusProvider.select((s) => s.asData?.value.online ?? true),
    );
    final hasName = _nameCtrl.text.trim().isNotEmpty;
    final enabled = online && hasName && !_generatingDescription;
    final tooltip = !online
        ? 'AI needs an internet connection'
        : (!hasName ? 'Enter a product name first' : 'Draft a description with AI');
    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        onPressed: enabled ? _generateDescription : null,
        icon: _generatingDescription
            ? const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: enabled ? scheme.primary : scheme.onSurfaceVariant,
              ),
        label: Text(
          _generatingDescription ? 'Writing…' : 'Generate with AI',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: enabled ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
        style: TextButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
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
            label: const Text('Create product'),
            onPressed: _busy ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Field wrapper — same pattern as the edit dialog. Could be hoisted to a
/// shared widget if it grows; copied here for now to keep the two dialogs
/// independent.
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
