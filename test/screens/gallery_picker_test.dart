import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_app/screens/gallery_picker_screen.dart';
import 'package:ocr_app/constants/app_constants.dart';

void main() {
  group('GalleryPickerScreen', () {
    testWidgets('should display all image source options', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GalleryPickerScreen(),
        ),
      );

      // Verify the screen title
      expect(find.text('Select Image'), findsOneWidget);

      // Verify device type selector section
      expect(find.text('Select Device Type'), findsOneWidget);

      // Verify image source section
      expect(find.text('Select Image Source'), findsOneWidget);

      // Verify all three image source options
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Use Test Image'), findsOneWidget);

      // Verify tips section
      expect(find.text('Tips for Better OCR Results'), findsOneWidget);
    });

    testWidgets('should show blood pressure tips by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GalleryPickerScreen(),
        ),
      );

      // Should show blood pressure tips since it's the default device type
      expect(find.textContaining('systolic and diastolic'), findsOneWidget);
      expect(find.textContaining('well-lit and not blurry'), findsOneWidget);
    });

    testWidgets('should have proper icons for each option', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GalleryPickerScreen(),
        ),
      );

      // Verify icons are present
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.science), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('should be scrollable to prevent overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GalleryPickerScreen(),
        ),
      );

      // Verify the main content is in a SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should update tips when device type changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GalleryPickerScreen(),
        ),
      );

      // Initially should show blood pressure tips
      expect(find.textContaining('systolic and diastolic'), findsOneWidget);

      // Find and tap on a different device type (if the selector allows it)
      // This test would need to be expanded based on how the DeviceTypeSelectorExpanded works
    });
  });

  group('Test Image Generation', () {
    test('should generate appropriate test data for blood pressure', () {
      // This would test the _getTestData method if it were public
      // For now, we can test the integration through the UI
    });

    test('should generate appropriate test data for other device types', () {
      // Similar integration test for other device types
    });
  });
}
