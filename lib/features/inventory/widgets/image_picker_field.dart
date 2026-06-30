import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Pick + manage up to [maxImages] product images. Returns the list of
/// chosen file paths to the parent via [onChanged].
///
/// Renders a row of thumbnails with X-to-remove, followed by a "+ Add"
/// tile while there's room left. Designed for the create/edit dialogs.
class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    required this.paths,
    required this.onChanged,
    this.maxImages = 5,
  });

  /// Currently-selected file paths.
  final List<String> paths;
  final ValueChanged<List<String>> onChanged;
  final int maxImages;

  Future<void> _pick() async {
    final remaining = maxImages - paths.length;
    if (remaining <= 0) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null) return;
    final picked = result.files
        .map((f) => f.path)
        .whereType<String>()
        .take(remaining)
        .toList();
    if (picked.isEmpty) return;
    onChanged([...paths, ...picked]);
  }

  void _remove(int index) {
    final next = [...paths]..removeAt(index);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canAdd = paths.length < maxImages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 88,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < paths.length; i++) ...[
                _Thumb(
                  path: paths[i],
                  onRemove: () => _remove(i),
                ),
                const SizedBox(width: 8),
              ],
              if (canAdd) _AddTile(onTap: _pick),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${paths.length}/$maxImages images · JPG, PNG, WebP',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUrl = path.startsWith('http://') || path.startsWith('https://');
    return Stack(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: isUrl
              ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    size: 24,
                    color: scheme.outline,
                  ),
                )
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    size: 24,
                    color: scheme.outline,
                  ),
                ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Material(
            color: Colors.black.withValues(alpha: 0.6),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.close_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
            color: scheme.outline,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 22,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
