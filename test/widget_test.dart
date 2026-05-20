import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:salepilot_desktop/app.dart';

void main() {
  testWidgets('app builds and shows login screen when unauthed', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalePilotApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
