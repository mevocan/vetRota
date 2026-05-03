import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vetrota_mobile/main.dart';

void main() {
  testWidgets('App boots and shows VetRota AppBar', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: VetRotaApp()));
    // Boot anindaki spinner gecince AppBar gorunmeli.
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
