import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/branding.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/repositories/stock_take_repository.dart';

/// Stock take (cycle count) screen.
///
/// One in-progress session lives in the local DB at a time. The user can
/// pause and resume — closing this screen and reopening the app preserves
/// state. Finalize converts each variance into a stock adjustment via the
/// regular offline-first pipeline.
class StockTakeScreen extends ConsumerStatefulWidget {
  const StockTakeScreen({super.key});

  @override
  ConsumerState<StockTakeScreen> createState() => _StockTakeScreenState();
}

class _StockTakeScreenState extends ConsumerState<StockTakeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _onlyUncounted = false;
  bool _busy = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final itemsAsync = ref.watch(stockTakeItemsProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        titleSpacing: 0,
        title: Row(
          children: const [
            SalePilotLogo.icon(size: 26),
            SizedBox(width: AppTokens.s3),
            Text('Stock take'),
          ],
        ),
        actions: [
          // "Discard session" — only useful when one is in progress.
          itemsAsync.when(
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : TextButton.icon(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Discard'),
                    onPressed: _busy ? null : _confirmDiscard,
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(width: AppTokens.s4),
        ],
      ),
      body: itemsAsync.when(
        data: (list) => list.isEmpty ? _startState(scheme) : _activeSession(scheme, list),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // Empty / start state
  // ──────────────────────────────────────────────────────────────────────
  Widget _startState(ColorScheme scheme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  size: 36,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: AppTokens.s4),
              Text(
                'Start a stock take',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppTokens.s2),
              Text(
                'Count your physical inventory and reconcile against the system. '
                'You can pause and resume — your progress is saved locally.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppTokens.s6),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Begin counting'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                onPressed: _busy ? null : _start,
              ),
              const SizedBox(height: AppTokens.s4),
              Container(
                padding: const EdgeInsets.all(AppTokens.s3),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Counting takes a snapshot of current stock at the moment '
                        'you start. New products added during the session won\'t '
                        'appear until you start a fresh session.',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11.5,
                          height: 1.5,
                        ),
                      ),
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

  Future<void> _start() async {
    setState(() => _busy = true);
    try {
      await ref.read(stockTakeRepositoryProvider).start();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // Active session UI
  // ──────────────────────────────────────────────────────────────────────
  Widget _activeSession(ColorScheme scheme, List<StockTakeItemRow> all) {
    final counted = all.where((i) => i.countedQty != null).length;
    final variance = all.where((i) =>
        i.countedQty != null && i.countedQty != i.expectedQty).length;
    final total = all.length;

    // Apply filters
    final q = _query.trim().toLowerCase();
    final filtered = all.where((i) {
      if (_onlyUncounted && i.countedQty != null) return false;
      if (q.isNotEmpty) {
        return i.productName.toLowerCase().contains(q) ||
            i.productSku.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Column(
      children: [
        _progressHeader(scheme, counted: counted, total: total, variance: variance),
        // Toolbar: search + filter toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.s5, 0, AppTokens.s5, AppTokens.s3,
          ),
          child: Row(
            children: [
              Expanded(child: _searchField(scheme)),
              const SizedBox(width: AppTokens.s3),
              FilterChip(
                selected: _onlyUncounted,
                label: const Text('Uncounted only'),
                onSelected: (v) => setState(() => _onlyUncounted = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _filteredEmpty(scheme)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.s5, 0, AppTokens.s5, AppTokens.s5,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (_, i) => _ItemRow(
                    item: filtered[i],
                    onChanged: (counted) => ref
                        .read(stockTakeRepositoryProvider)
                        .recordCount(filtered[i].productId, counted),
                    onClear: () => ref
                        .read(stockTakeRepositoryProvider)
                        .clearCount(filtered[i].productId),
                  ),
                ),
        ),
        _finalizeBar(scheme, variance: variance, total: total, countedCount: counted),
      ],
    );
  }

  Widget _progressHeader(
    ColorScheme scheme, {
    required int counted,
    required int total,
    required int variance,
  }) {
    final pct = total == 0 ? 0.0 : counted / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s5, AppTokens.s5, AppTokens.s5, AppTokens.s3,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'COUNTED',
              value: '$counted / $total',
              icon: Icons.fact_check_outlined,
              color: scheme.primary,
              progress: pct,
            ),
          ),
          const SizedBox(width: AppTokens.s3),
          Expanded(
            child: _StatCard(
              label: 'WITH VARIANCE',
              value: '$variance',
              icon: Icons.balance_outlined,
              color: variance > 0
                  ? AppTokens.brandWarning
                  : AppTokens.brandSuccess,
            ),
          ),
          const SizedBox(width: AppTokens.s3),
          Expanded(
            child: _StatCard(
              label: 'REMAINING',
              value: '${total - counted}',
              icon: Icons.pending_outlined,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(ColorScheme scheme) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchCtrl,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search by name or SKU…',
          prefixIcon: Icon(Icons.search_rounded,
              size: 18, color: scheme.onSurfaceVariant),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        onChanged: (v) => setState(() => _query = v),
      ),
    );
  }

  Widget _filteredEmpty(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 32, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            _onlyUncounted
                ? 'Nothing left to count'
                : 'No products match your search',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _finalizeBar(
    ColorScheme scheme, {
    required int variance,
    required int total,
    required int countedCount,
  }) {
    final canFinalize = countedCount > 0 && !_busy;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.s5, AppTokens.s3, AppTokens.s5, AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
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
                    variance == 0
                        ? 'No variances yet — count items above to see changes.'
                        : 'Finalizing will queue $variance stock adjustment${variance == 1 ? '' : 's'}, '
                            'one per varied item.',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            label: const Text('Finalize stock take'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: canFinalize ? _confirmFinalize : null,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDiscard() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard stock take?'),
        content: const Text(
          'All counts entered so far will be lost. '
          'You can\'t undo this.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep counting'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.brandDanger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(stockTakeRepositoryProvider).cancel();
  }

  Future<void> _confirmFinalize() async {
    // Preview the changes before applying.
    final items = await ref.read(stockTakeItemsProvider.future);
    final varied = items
        .where((i) => i.countedQty != null && i.countedQty != i.expectedQty)
        .toList();
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(varied.isEmpty
            ? 'Finalize with no changes?'
            : 'Apply ${varied.length} adjustment${varied.length == 1 ? '' : 's'}?'),
        content: SizedBox(
          width: 420,
          child: varied.isEmpty
              ? const Text(
                  'No variances were recorded. Finalizing will end the session '
                  'without applying any changes.',
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'These products will be adjusted via the regular '
                        'offline-first sync pipeline (one entry per item).',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: AppTokens.s3),
                      ...varied.take(8).map(_varianceLine),
                      if (varied.length > 8) ...[
                        const SizedBox(height: 6),
                        Text(
                          '…and ${varied.length - 8} more',
                          style: TextStyle(
                            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(varied.isEmpty ? 'End session' : 'Apply'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      final summary =
          await ref.read(stockTakeRepositoryProvider).finalize();
      ref.read(syncEngineProvider).drain();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_summaryText(summary)),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to finalize: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _summaryText(StockTakeSummary s) {
    if (s.applied == 0) {
      return 'Session ended — no adjustments needed.';
    }
    final parts = <String>['${s.applied} adjustment${s.applied == 1 ? '' : 's'} queued'];
    if (s.totalDeltaUp > 0) parts.add('+${_fmt(s.totalDeltaUp)} added');
    if (s.totalDeltaDown > 0) parts.add('-${_fmt(s.totalDeltaDown)} missing');
    return parts.join(' · ');
  }

  Widget _varianceLine(StockTakeItemRow item) {
    final delta = (item.countedQty ?? 0) - item.expectedQty;
    final positive = delta > 0;
    final color = positive ? AppTokens.brandSuccess : AppTokens.brandWarning;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${_fmt(item.expectedQty)} → ${_fmt(item.countedQty!)}',
            style: const TextStyle(
              fontSize: 12,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${positive ? '+' : ''}${_fmt(delta)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Item row
// ─────────────────────────────────────────────────────────────────────────
class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.item,
    required this.onChanged,
    required this.onClear,
  });

  final StockTakeItemRow item;
  final ValueChanged<double> onChanged;
  final VoidCallback onClear;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  // Track the field's text separately from the DB value so we don't fight
  // the user mid-typing. Sync to DB on blur or commit (Enter).
  String _lastSyncedText = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.item.countedQty == null
        ? ''
        : _fmt(widget.item.countedQty!);
    _ctrl = TextEditingController(text: initial);
    _lastSyncedText = initial;
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _ItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // External changes (e.g. clear button) reflect into the field — but only
    // if the user isn't actively editing (to avoid stomping their typing).
    if (!_focus.hasFocus) {
      final fresh = widget.item.countedQty == null
          ? ''
          : _fmt(widget.item.countedQty!);
      if (fresh != _ctrl.text) {
        _ctrl.text = fresh;
        _lastSyncedText = fresh;
      }
    }
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) _commit();
  }

  void _commit() {
    final raw = _ctrl.text.trim();
    if (raw == _lastSyncedText) return;
    if (raw.isEmpty) {
      widget.onClear();
      _lastSyncedText = '';
      return;
    }
    final parsed = double.tryParse(raw);
    if (parsed == null || parsed < 0) {
      // Revert to last synced.
      _ctrl.text = _lastSyncedText;
      return;
    }
    widget.onChanged(parsed);
    _lastSyncedText = raw;
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  static String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final item = widget.item;
    final isCounted = item.countedQty != null;
    final delta = isCounted ? item.countedQty! - item.expectedQty : 0.0;
    final hasVariance = isCounted && delta != 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: hasVariance
              ? (delta > 0
                  ? AppTokens.brandSuccess.withValues(alpha: 0.3)
                  : AppTokens.brandWarning.withValues(alpha: 0.3))
              : (isCounted
                  ? scheme.primary.withValues(alpha: 0.25)
                  : scheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          // Counted checkmark indicator
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCounted
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(
              isCounted
                  ? Icons.check_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: isCounted ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppTokens.s3),
          // Name + SKU
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.productSku,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Consolas',
                    fontFamilyFallback: const ['monospace'],
                  ),
                ),
              ],
            ),
          ),
          // Expected
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EXPECTED',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _fmt(item.expectedQty),
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.s3),
          // Counted input
          SizedBox(
            width: 88,
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              decoration: InputDecoration(
                hintText: 'count',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                hintStyle: TextStyle(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              onSubmitted: (_) => _commit(),
            ),
          ),
          const SizedBox(width: AppTokens.s2),
          // Variance display
          SizedBox(
            width: 48,
            child: hasVariance
                ? _varianceBadge(delta)
                : (isCounted
                    ? Text(
                        '✓',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTokens.brandSuccess,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      )
                    : const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  Widget _varianceBadge(double delta) {
    final positive = delta > 0;
    final color = positive ? AppTokens.brandSuccess : AppTokens.brandWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Text(
        '${positive ? '+' : ''}${_fmt(delta)}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Stat card (mini)
// ─────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.s3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: AppTokens.shadowSm(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppTokens.s2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: scheme.onSurface,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: AppTokens.s2),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                minHeight: 4,
                color: color,
                backgroundColor: scheme.surfaceContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────
final stockTakeItemsProvider = StreamProvider<List<StockTakeItemRow>>((ref) {
  return ref.watch(stockTakeRepositoryProvider).watch();
});
