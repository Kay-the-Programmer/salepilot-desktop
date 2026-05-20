import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';

final _productCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.get('/products');
  if (res is List) return res.length;
  if (res is Map && res['data'] is List) return (res['data'] as List).length;
  return 0;
});

class PosPlaceholderScreen extends ConsumerWidget {
  const PosPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final count = ref.watch(_productCountProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SalePilot POS'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${auth.session?.user.name ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${auth.session?.user.email ?? ''} · ${auth.session?.user.role ?? ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Card(
              color: scheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: count.when(
                  loading: () => const Row(
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 16),
                      Text('Loading products from server…'),
                    ],
                  ),
                  error: (e, _) => Row(
                    children: [
                      Icon(Icons.error_outline, color: scheme.error),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Failed: $e')),
                    ],
                  ),
                  data: (n) => Row(
                    children: [
                      Icon(Icons.check_circle, color: scheme.primary),
                      const SizedBox(width: 12),
                      Text('Server reachable — $n products in catalog'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Milestone 1 complete: auth + connectivity wired. POS UI lands in M2.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
