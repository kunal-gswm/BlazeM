import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blamics_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('BlamicsApp smoke test and initialization', (WidgetTester tester) async {
    // Build our financial terminal app inside a ProviderScope.
    await tester.pumpWidget(const ProviderScope(child: BlamicsApp()));

    // Verify that the app builds a MaterialApp and initializes the navigation structure.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
