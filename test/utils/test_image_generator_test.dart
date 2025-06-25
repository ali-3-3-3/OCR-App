import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_app/utils/test_image_generator.dart';
import 'package:ocr_app/constants/app_constants.dart';

void main() {
  group('TestImageGenerator', () {
    test('should generate valid test image file', () async {
      final imagePath = await TestImageGenerator.generateTestImage(
        MedicalDeviceType.bloodPressure,
      );
      
      // Verify file exists
      final file = File(imagePath);
      expect(await file.exists(), isTrue);
      
      // Verify file has content
      final bytes = await file.readAsBytes();
      expect(bytes.isNotEmpty, isTrue);
      
      // Verify it's a PNG file (starts with PNG signature)
      expect(bytes[0], equals(0x89));
      expect(bytes[1], equals(0x50));
      expect(bytes[2], equals(0x4E));
      expect(bytes[3], equals(0x47));
      
      // Clean up
      await file.delete();
    });

    test('should generate test data for blood pressure', () {
      final testData = TestImageGenerator.getTestData(
        MedicalDeviceType.bloodPressure,
      );
      
      expect(testData['title'], equals('Blood Pressure Monitor'));
      expect(testData['line1'], equals('SYS: 135'));
      expect(testData['line2'], equals('DIA: 85'));
      expect(testData['line3'], equals('PULSE: 72 BPM'));
      expect(testData['line4'], equals('mmHg'));
      expect(testData['line5'], equals('AUTO MODE'));
    });

    test('should generate test text content for blood pressure', () {
      final textContent = TestImageGenerator.getTestTextContent(
        MedicalDeviceType.bloodPressure,
      );
      
      expect(textContent, contains('Blood Pressure Monitor'));
      expect(textContent, contains('SYS: 135'));
      expect(textContent, contains('DIA: 85'));
      expect(textContent, contains('PULSE: 72 BPM'));
      expect(textContent, contains('mmHg'));
      expect(textContent, contains('AUTO MODE'));
    });

    test('should generate test data for oxygen saturation', () {
      final testData = TestImageGenerator.getTestData(
        MedicalDeviceType.oxygenSaturation,
      );
      
      expect(testData['title'], equals('Pulse Oximeter'));
      expect(testData['line1'], equals('SpO2: 98%'));
      expect(testData['line2'], equals('PR: 75 BPM'));
    });

    test('should generate test data for thermometer', () {
      final testData = TestImageGenerator.getTestData(
        MedicalDeviceType.thermometer,
      );
      
      expect(testData['title'], equals('Digital Thermometer'));
      expect(testData['line1'], equals('98.6°F'));
      expect(testData['line2'], equals('37.0°C'));
    });

    test('should generate test data for glucometer', () {
      final testData = TestImageGenerator.getTestData(
        MedicalDeviceType.glucometer,
      );
      
      expect(testData['title'], equals('Blood Glucose Meter'));
      expect(testData['line1'], equals('120 mg/dL'));
      expect(testData['line2'], equals('6.7 mmol/L'));
    });

    test('should create files with correct naming pattern', () async {
      final imagePath = await TestImageGenerator.generateTestImage(
        MedicalDeviceType.bloodPressure,
      );
      
      // Verify file name pattern
      expect(imagePath, contains('test_image_'));
      expect(imagePath, endsWith('.png'));
      
      // Clean up
      final file = File(imagePath);
      await file.delete();
    });
  });
}
