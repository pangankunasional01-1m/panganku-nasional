import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_pangan/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    // FarmerHome adalah ConsumerWidget → wajib dibungkus ProviderScope.
    await tester.pumpWidget(const ProviderScope(child: PanganKuApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
