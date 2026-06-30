import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Local image storage for offline-deferred multipart uploads.
///
/// When the user picks images for a product but we can't reach the server,
/// we copy the files into `<appSupport>/pending_images/<uuid>.<ext>` and
/// reference them in the sync queue. The push helper rehydrates them as
/// `MultipartFile`s when the queue eventually drains.
class ImageStore {
  ImageStore._();
  static final ImageStore instance = ImageStore._();

  Directory? _root;

  /// Path to the pending-images directory, creating it on first use.
  Future<Directory> _ensureRoot() async {
    if (_root != null) return _root!;
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'pending_images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _root = dir;
    return dir;
  }

  /// Copy [source] into the pending dir. Returns the absolute path of the
  /// stored copy — safe to keep across app restarts.
  Future<String> stash(String source) async {
    final root = await _ensureRoot();
    final ext = p.extension(source).toLowerCase();
    final filename = '${_uuid.v4()}$ext';
    final dest = File(p.join(root.path, filename));
    await File(source).copy(dest.path);
    return dest.path;
  }

  /// Delete a stored file by absolute path. Silently ignores missing files —
  /// cleanup is best-effort and should never block sync completion.
  Future<void> remove(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // best-effort
    }
  }

  /// Bulk remove. Used after a queue entry successfully syncs.
  Future<void> removeAll(Iterable<String> paths) async {
    for (final path in paths) {
      await remove(path);
    }
  }
}
