import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitrack_pro/main.dart';

void main() {
  testWidgets('App loads and shows MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const WorkoutApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}