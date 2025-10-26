// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:braille_notepad/main.dart';

void main() {
  testWidgets('Braille notepad smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BrailleNotepadApp());

    // Verify that the app loads with the Braille Notepad title
    expect(find.text('Braille Notepad'), findsOneWidget);

    // Verify that the Braille Workspace header is present
    expect(find.text('Braille Workspace'), findsOneWidget);

    // Verify that character count shows 0 initially
    expect(find.text('0 characters'), findsOneWidget);
  });

  testWidgets('Help dialog can be opened', (WidgetTester tester) async {
    await tester.pumpWidget(const BrailleNotepadApp());

    // Find and tap the help button
    final helpButton = find.byIcon(Icons.help_outline);
    expect(helpButton, findsOneWidget);

    await tester.tap(helpButton);
    await tester.pumpAndSettle();

    // Verify help dialog content appears
    expect(find.text('Braille Input Guide'), findsOneWidget);
    expect(find.text('Key Mapping'), findsOneWidget);
  });

  testWidgets('Document options can be opened', (WidgetTester tester) async {
    await tester.pumpWidget(const BrailleNotepadApp());

    // Find and tap the document options button
    final optionsButton = find.text('Document options');
    expect(optionsButton, findsOneWidget);

    await tester.tap(optionsButton);
    await tester.pumpAndSettle();

    // Verify bottom sheet content appears
    expect(find.text('Text Options'), findsOneWidget);
    expect(find.text('Clear All'), findsOneWidget);
    expect(find.text('Save as Unicode text'), findsOneWidget);
  });
}
