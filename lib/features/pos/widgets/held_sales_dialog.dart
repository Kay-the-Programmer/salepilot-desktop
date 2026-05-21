import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../data/models/sale.dart';
import '../cart_controller.dart';

class HeldSalesDialog extends ConsumerWidget {
  const HeldSalesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return AlertDialog(
      title: const Text('Held sales'),
      content: SizedBox(
        width: 460,
        height: 460,
        child: StreamBuilder(
          stream: db.watchHeldSales(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = snap.data!;
            if (list.isEmpty) {
              return const Center(child: Text('No held sales'));
            }
            return ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final h = list[i];
                final items = (jsonDecode(h.cartJson) as List)
                    .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
                    .toList();
                final count = items.length;
                final total = items.fold<double>(0, (s, it) => s + it.lineTotal);
                final createdAt = DateTime.fromMillisecondsSinceEpoch(h.createdAt).toLocal();
                return ListTile(
                  title: Text('$count item${count == 1 ? '' : 's'} · ${total.toStringAsFixed(2)}'),
                  subtitle: Text('Held ${_relativeTime(createdAt)}${h.note == null ? '' : ' · ${h.note}'}'),
                  trailing: Wrap(spacing: 4, children: [
                    IconButton(
                      icon: const Icon(Icons.unarchive, size: 20),
                      tooltip: 'Recall',
                      onPressed: () async {
                        final cart = ref.read(cartProvider);
                        if (cart.items.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Clear or hold current cart first')),
                          );
                          return;
                        }
                        ref.read(cartProvider.notifier).replaceItems(items);
                        await db.removeHeldSale(h.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Discard',
                      onPressed: () => db.removeHeldSale(h.id),
                    ),
                  ]),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
