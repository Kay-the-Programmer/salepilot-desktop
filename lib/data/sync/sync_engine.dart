import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/logger.dart';
import '../db/app_database.dart';
import '../repositories/sales_repository.dart';

enum SyncPhase { idle, syncing, error }

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.pending = 0,
    this.online = true,
    this.lastError,
    this.lastSyncedAt,
  });

  final SyncPhase phase;
  final int pending;
  final bool online;
  final String? lastError;
  final DateTime? lastSyncedAt;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pending,
    bool? online,
    String? lastError,
    DateTime? lastSyncedAt,
    bool clearError = false,
  }) {
    return SyncStatus(
      phase: phase ?? this.phase,
      pending: pending ?? this.pending,
      online: online ?? this.online,
      lastError: clearError ? null : (lastError ?? this.lastError),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class SyncEngine {
  SyncEngine({required this.db, required this.sales}) {
    _statusCtrl.add(const SyncStatus());
    _watchConnectivity();
    _watchPendingCount();
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) => drain());
  }

  final AppDatabase db;
  final SalesRepository sales;

  final _statusCtrl = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = const SyncStatus();
  Stream<SyncStatus> get status => _statusCtrl.stream;
  SyncStatus get current => _status;

  StreamSubscription? _connSub;
  Timer? _tickTimer;
  bool _draining = false;

  void _emit(SyncStatus next) {
    _status = next;
    _statusCtrl.add(next);
  }

  Future<void> _watchPendingCount() async {
    // Poll pending count cheaply every 5s — Drift doesn't expose a stream for
    // arbitrary aggregates without extra setup, and 5s granularity is fine.
    Timer.periodic(const Duration(seconds: 5), (_) async {
      final count = await db.pendingSyncCount();
      if (count != _status.pending) {
        _emit(_status.copyWith(pending: count));
      }
    });
    final initial = await db.pendingSyncCount();
    _emit(_status.copyWith(pending: initial));
  }

  void _watchConnectivity() {
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      _emit(_status.copyWith(online: online));
      if (online) {
        // Fire and forget — when connectivity returns, drain immediately.
        drain();
      }
    });
  }

  Future<void> drain() async {
    if (_draining) return;
    if (!_status.online) return;
    _draining = true;
    _emit(_status.copyWith(phase: SyncPhase.syncing, clearError: true));
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final entries = await db.dueSyncEntries(now: now);
      if (entries.isEmpty) {
        final pending = await db.pendingSyncCount();
        _emit(_status.copyWith(phase: SyncPhase.idle, pending: pending, lastSyncedAt: DateTime.now()));
        return;
      }
      var allOk = true;
      for (final e in entries) {
        final ok = await sales.pushQueueEntry(e);
        if (!ok) {
          // Stop the batch on first failure for clearer error reporting;
          // the periodic timer will retry due entries later.
          allOk = false;
          break;
        }
      }
      final pending = await db.pendingSyncCount();
      _emit(_status.copyWith(
        phase: allOk ? SyncPhase.idle : SyncPhase.error,
        pending: pending,
        lastSyncedAt: DateTime.now(),
      ));
    } catch (e, st) {
      log.e('Sync drain failed', error: e, stackTrace: st);
      _emit(_status.copyWith(phase: SyncPhase.error, lastError: e.toString()));
    } finally {
      _draining = false;
    }
  }

  Future<void> dispose() async {
    _tickTimer?.cancel();
    await _connSub?.cancel();
    await _statusCtrl.close();
  }
}
