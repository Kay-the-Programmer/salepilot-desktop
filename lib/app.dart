import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config.dart';
import 'core/theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/login_screen.dart';
import 'features/pos/pos_placeholder_screen.dart';

class SalePilotApp extends ConsumerStatefulWidget {
  const SalePilotApp({super.key});

  @override
  ConsumerState<SalePilotApp> createState() => _SalePilotAppState();
}

class _SalePilotAppState extends ConsumerState<SalePilotApp> {
  late final Future<void> _restored;

  @override
  void initState() {
    super.initState();
    _restored = ref.read(authStateProvider.notifier).restore();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: FutureBuilder<void>(
        future: _restored,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return auth.isAuthed ? const PosPlaceholderScreen() : const LoginScreen();
        },
      ),
    );
  }
}
