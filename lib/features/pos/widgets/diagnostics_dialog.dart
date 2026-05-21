import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../data/db/app_database.dart';
import '../../../data/sync/sync_engine.dart';

/// Shows the contents of the sync queue and lets the user force-drain it.
/// Useful when a sale appears "queued" forever to find out why.
class DiagnosticsDialog extends ConsumerWidget {
  const DiagnosticsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).asData?.value ?? const SyncStatus();
    final db = ref.watch(appDatabaseProvider);

    return AlertDialog(
      title: const Text('Sync diagnostics'),
      content: SizedBox(
        width: 540,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusBlock(status: status),
            const SizedBox(height: 12),
            const Text('Queued operations', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Expanded(
              child: FutureBuilder<List<SyncQueueRow>>(
                future: db.dueSyncEntries(
                  now: DateTime.now().millisecondsSinceEpoch + const Duration(days: 30).inMilliseconds,
                  limit: 100,
                ),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final rows = snap.data!;
                  if (rows.isEmpty) {
                    return const Center(child: Text('Queue is empty'));
                  }
                  return ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) => _QueueEntryTile(entry: rows[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.sync),
          label: const Text('Sync now'),
          onPressed: status.online ? () => ref.read(syncEngineProvider).drain() : null,
        ),
      ],
    );
  }
}

class _StatusBlock extends StatelessWidget {
  const _StatusBlock({required this.status});
  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kv('Network', status.online ? 'Online' : 'Offline'),
          _kv('Phase', status.phase.name),
          _kv('Pending', status.pending.toString()),
          if (status.lastSyncedAt != null)
            _kv('Last sync', status.lastSyncedAt!.toLocal().toString()),
          if (status.lastError != null) ...[
            const SizedBox(height: 6),
            Text(
              'Last error:',
              style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Text(status.lastError!, style: TextStyle(color: scheme.error, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            SizedBox(width: 90, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w500))),
            Expanded(child: Text(v)),
          ],
        ),
      );
}

class _QueueEntryTile extends StatelessWidget {
  const _QueueEntryTile({required this.entry});
  final SyncQueueRow entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nextAttempt = entry.nextAttemptAt > 0
        ? DateTime.fromMillisecondsSinceEpoch(entry.nextAttemptAt).toLocal()
        : null;
    return ListTile(
      leading: Icon(
        entry.lastError == null ? Icons.cloud_queue : Icons.error_outline,
        color: entry.lastError == null ? scheme.primary : scheme.error,
      ),
      title: Text('${entry.method} ${entry.endpoint}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.refKey != null) Text('ref: ${entry.refKey}'),
          if (entry.retries > 0) Text('retries: ${entry.retries}'),
          if (entry.lastError != null)
            Text(entry.lastError!, style: TextStyle(color: scheme.error, fontSize: 12)),
          if (nextAttempt != null) Text('next attempt: $nextAttempt', style: const TextStyle(fontSize: 11)),
        ],
      ),
      dense: true,
    );
  }
}
