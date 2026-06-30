import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/theme.dart';
import '../../../data/models/category.dart';

/// Pops a sheet to pick (or create) a category. Returns the chosen
/// [Category], or `null` if the user cancelled / cleared the selection.
///
/// To support "no category", the dialog has a "None" option that resolves
/// to a [Category] with empty id — callers should treat that as "clear".
class CategoryPickerDialog extends ConsumerStatefulWidget {
  const CategoryPickerDialog({super.key, this.currentId});
  final String? currentId;

  static Future<Category?> show(BuildContext context, {String? currentId}) {
    return showDialog<Category?>(
      context: context,
      builder: (_) => CategoryPickerDialog(currentId: currentId),
    );
  }

  @override
  ConsumerState<CategoryPickerDialog> createState() =>
      _CategoryPickerDialogState();
}

class _CategoryPickerDialogState extends ConsumerState<CategoryPickerDialog> {
  String _q = '';
  bool _creating = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final categoriesAsync = ref.watch(categoriesListProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radius2xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(scheme),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.s4, AppTokens.s4, AppTokens.s4, AppTokens.s2,
              ),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search or type to create new…',
                  prefixIcon: Icon(Icons.search_rounded, size: 18),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            Flexible(
              child: categoriesAsync.when(
                data: (cats) => _list(scheme, cats),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error: $e')),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppTokens.s3),
              child: Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.do_not_disturb_alt_outlined,
                        size: 16),
                    label: const Text('Clear selection'),
                    onPressed: () => Navigator.of(context)
                        .pop(Category(id: '', name: '')),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
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
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(Icons.folder_outlined,
                size: 20, color: scheme.primary),
          ),
          const SizedBox(width: AppTokens.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CHOOSE CATEGORY',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Group products for reporting',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
      ),
    );
  }

  Widget _list(ColorScheme scheme, List<Category> all) {
    final q = _q.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(q)).toList();

    // If the user typed text that exactly matches no existing category,
    // surface a "Create" affordance at the top.
    final exactMatch = filtered.any((c) => c.name.toLowerCase() == q);
    final showCreate = q.isNotEmpty && !exactMatch;

    if (filtered.isEmpty && !showCreate) {
      return Padding(
        padding: const EdgeInsets.all(AppTokens.s5),
        child: Center(
          child: Text(
            'No categories yet — type a name to create one.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s3),
      children: [
        if (showCreate) _createTile(scheme, _q.trim()),
        ...filtered.map((c) => _categoryTile(scheme, c)),
      ],
    );
  }

  Widget _createTile(ColorScheme scheme, String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Icon(Icons.add_rounded, color: scheme.primary, size: 18),
        ),
        title: Text(
          'Create "$name"',
          style: TextStyle(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        trailing: _creating
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
        onTap: _creating ? null : () => _createAndReturn(name),
      ),
    );
  }

  Widget _categoryTile(ColorScheme scheme, Category c) {
    final selected = c.id == widget.currentId;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary.withValues(alpha: 0.06)
            : null,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Icon(
            Icons.folder_outlined,
            color: scheme.onSurfaceVariant,
            size: 16,
          ),
        ),
        title: Text(
          c.name,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13.5,
            color: selected ? scheme.primary : scheme.onSurface,
          ),
        ),
        trailing: selected
            ? Icon(Icons.check_rounded, size: 18, color: scheme.primary)
            : null,
        onTap: () => Navigator.of(context).pop(c),
      ),
    );
  }

  Future<void> _createAndReturn(String name) async {
    setState(() => _creating = true);
    try {
      final c = await ref
          .read(categoriesRepositoryProvider)
          .createCategory(name: name);
      if (mounted) Navigator.of(context).pop(c);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create category: $e')),
        );
        setState(() => _creating = false);
      }
    }
  }
}

/// Watch all categories.
final categoriesListProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchAll();
});
