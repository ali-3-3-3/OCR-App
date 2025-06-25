import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class TestImageGenerator {
  /// Generate a test image for the specified device type
  static Future<String> generateTestImage(MedicalDeviceType deviceType) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'test_image_$timestamp.png';
    final filePath = path.join(directory.path, 'test_images', fileName);

    // Create directory if it doesn't exist
    final testDir = Directory(path.dirname(filePath));
    if (!await testDir.exists()) {
      await testDir.create(recursive: true);
    }

    // Create a simple test image with device-specific data
    final imageBytes = await _createSimpleTestImage(deviceType);

    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    return filePath;
  }

  /// Create a simple test image with minimal PNG structure
  static Future<Uint8List> _createSimpleTestImage(
    MedicalDeviceType deviceType,
  ) async {
    // Use a base64 encoded minimal 1x1 pixel PNG that is guaranteed to work
    // This is a transparent 1x1 pixel PNG created with a standard image editor
    const base64Png =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAI9jU77yQAAAABJRU5ErkJggg==';

    // Decode the base64 string to bytes
    final pngBytes = base64.decode(base64Png);

    return Uint8List.fromList(pngBytes);
  }

  /// Get test data for the specified device type
  static Map<String, String> getTestData(MedicalDeviceType deviceType) {
    switch (deviceType) {
      case MedicalDeviceType.bloodPressure:
        return {
          'title': 'Blood Pressure Monitor',
          'line1': 'SYS: 135',
          'line2': 'DIA: 85',
          'line3': 'PULSE: 72 BPM',
          'line4': 'mmHg',
          'line5': 'AUTO MODE',
        };
      case MedicalDeviceType.oxygenSaturation:
        return {
          'title': 'Pulse Oximeter',
          'line1': 'SpO2: 98%',
          'line2': 'PR: 75 BPM',
          'line3': '',
          'line4': '',
          'line5': '',
        };
      case MedicalDeviceType.thermometer:
        return {
          'title': 'Digital Thermometer',
          'line1': '98.6°F',
          'line2': '37.0°C',
          'line3': '',
          'line4': '',
          'line5': '',
        };
      case MedicalDeviceType.glucometer:
        return {
          'title': 'Blood Glucose Meter',
          'line1': '120 mg/dL',
          'line2': '6.7 mmol/L',
          'line3': '',
          'line4': '',
          'line5': '',
        };
      case MedicalDeviceType.unknown:
        return {
          'title': 'Medical Device',
          'line1': '123',
          'line2': '456',
          'line3': '',
          'line4': '',
          'line5': '',
        };
    }
  }

  /// Get the text content for OCR processing
  static String getTestTextContent(MedicalDeviceType deviceType) {
    final testData = getTestData(deviceType);
    return [
      testData['title'] ?? '',
      testData['line1'] ?? '',
      testData['line2'] ?? '',
      testData['line3'] ?? '',
      testData['line4'] ?? '',
      testData['line5'] ?? '',
    ].where((line) => line.isNotEmpty).join('\n');
  }
}
