import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../core/theme.dart';
import '../../../data/sync/sync_engine.dart';

class SyncStatusPill extends ConsumerWidget {
  const SyncStatusPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).asData?.value ?? const SyncStatus();
    final scheme = Theme.of(context).colorScheme;

    final config = _pillConfig(status, scheme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(syncEngineProvider).drain(),
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        child: Tooltip(
          message: status.lastError ?? 'Click to sync now',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: config.bg,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
              border: Border.all(color: config.fg.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status.phase == SyncPhase.syncing)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.6,
                      valueColor: AlwaysStoppedAnimation(config.fg),
                    ),
                  )
                else
                  _StatusDot(color: config.fg, pulse: !status.online),
                const SizedBox(width: 8),
                Text(
                  config.label,
                  style: TextStyle(
                    color: config.fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _PillConfig _pillConfig(SyncStatus s, ColorScheme scheme) {
    if (!s.online) {
      return _PillConfig(
        bg: scheme.errorContainer,
        fg: scheme.onErrorContainer,
        label: s.pending > 0 ? 'Offline · ${s.pending} queued' : 'Offline',
      );
    }
    if (s.phase == SyncPhase.syncing) {
      return _PillConfig(
        bg: scheme.primary.withValues(alpha: 0.1),
        fg: scheme.primary,
        label: 'Syncing${s.pending > 0 ? ' (${s.pending})' : ''}',
      );
    }
    if (s.phase == SyncPhase.error) {
      return _PillConfig(
        bg: AppTokens.brandWarning.withValues(alpha: 0.14),
        fg: AppTokens.brandWarning,
        label: 'Sync error · ${s.pending} queued',
      );
    }
    if (s.pending > 0) {
      return _PillConfig(
        bg: AppTokens.brandWarning.withValues(alpha: 0.12),
        fg: AppTokens.brandWarning,
        label: '${s.pending} queued',
      );
    }
    return _PillConfig(
      bg: AppTokens.brandSuccess.withValues(alpha: 0.12),
      fg: AppTokens.brandSuccess,
      label: 'Synced',
    );
  }
}

class _PillConfig {
  _PillConfig({required this.bg, required this.fg, required this.label});
  final Color bg;
  final Color fg;
  final String label;
}

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.color, this.pulse = false});
  final Color color;
  final bool pulse;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pulse) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Color.lerp(widget.color.withValues(alpha: 0.4), widget.color, _ctrl.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
