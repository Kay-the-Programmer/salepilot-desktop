import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1280, 800),
        // Allow the window to shrink to tablet-ish widths; layouts reflow
        // responsively below ~1000 (see core/responsive.dart).
        minimumSize: Size(820, 600),
        center: true,
        title: 'SalePilot POS',
        backgroundColor: Colors.transparent,
        titleBarStyle: TitleBarStyle.normal,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  runApp(const ProviderScope(child: SalePilotApp()));
}
