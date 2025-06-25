import 'dart:io';
import '../constants/app_constants.dart';
import '../parsers/blood_pressure_parser.dart';
import '../utils/test_image_generator.dart';
import 'api_service.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  final ApiService _apiService = ApiService();

  // Process image with OCR
  Future<OcrResult> processImage({
    required File imageFile,
    required MedicalDeviceType deviceType,
    required ReadingCategory category,
    String? notes,
  }) async {
    try {
      // Check if this is a test file
      if (imageFile.path.contains('test_image_') &&
          (imageFile.path.endsWith('.txt') ||
              imageFile.path.endsWith('.png'))) {
        return await _processTestFile(imageFile, deviceType);
      }

      // Upload image and process with OCR
      final response = await _apiService.uploadFile(
        '/ocr/process',
        imageFile,
        fields: {
          'deviceType': deviceType.toString().split('.').last,
          'category': category.toString().split('.').last,
          'notes': notes ?? '',
        },
      );

      // Parse the response
      return _parseOcrResponse(response, deviceType);
    } catch (e) {
      throw OcrException('OCR processing failed: $e');
    }
  }

  // Parse OCR response from backend
  OcrResult _parseOcrResponse(
    Map<String, dynamic> response,
    MedicalDeviceType deviceType,
  ) {
    try {
      final success = response['success'] as bool? ?? false;

      if (!success) {
        final error = response['error'] as String? ?? 'Unknown error';
        throw OcrException(error);
      }

      final data = response['data'] as Map<String, dynamic>;
      final extractedText = data['extractedText'] as String? ?? '';
      final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
      final boundingBoxes = data['boundingBoxes'] as List<dynamic>? ?? [];

      // Parse extracted data based on device type
      final parsedData = _parseExtractedData(extractedText, deviceType);

      return OcrResult(
        success: true,
        extractedText: extractedText,
        confidence: confidence,
        parsedData: parsedData,
        boundingBoxes: boundingBoxes.cast<Map<String, dynamic>>(),
        processingTime: data['processingTime'] as int? ?? 0,
      );
    } catch (e) {
      throw OcrException('Failed to parse OCR response: $e');
    }
  }

  // Parse extracted data based on device type
  Map<String, dynamic> _parseExtractedData(
    String text,
    MedicalDeviceType deviceType,
  ) {
    switch (deviceType) {
      case MedicalDeviceType.bloodPressure:
        return _parseBloodPressureData(text);
      case MedicalDeviceType.oxygenSaturation:
        return _parseOxygenSaturationData(text);
      case MedicalDeviceType.thermometer:
        return _parseTemperatureData(text);
      case MedicalDeviceType.glucometer:
        return _parseGlucoseData(text);
      case MedicalDeviceType.unknown:
        return _parseGenericData(text);
    }
  }

  // Parse blood pressure readings using comprehensive parser
  Map<String, dynamic> _parseBloodPressureData(String text) {
    return BloodPressureParser.parse(text);
  }

  // Parse oxygen saturation readings
  Map<String, dynamic> _parseOxygenSaturationData(String text) {
    final Map<String, dynamic> result = {};

    // Look for SpO2 percentage
    final spo2Regex = RegExp(
      r'(?:spo2|o2)[\s:]*(\d{2,3})%?',
      caseSensitive: false,
    );
    final spo2Match = spo2Regex.firstMatch(text);

    if (spo2Match != null) {
      result['spO2'] = int.tryParse(spo2Match.group(1)!) ?? 0;
    } else {
      // Look for standalone percentage
      final percentRegex = RegExp(r'(\d{2,3})%');
      final percentMatch = percentRegex.firstMatch(text);
      if (percentMatch != null) {
        final value = int.tryParse(percentMatch.group(1)!) ?? 0;
        if (value >= 70 && value <= 100) {
          result['spO2'] = value;
        }
      }
    }

    // Look for pulse rate
    final pulseRegex = RegExp(
      r'(?:pulse|pr|bpm)[\s:]*(\d{2,3})',
      caseSensitive: false,
    );
    final pulseMatch = pulseRegex.firstMatch(text);

    if (pulseMatch != null) {
      result['pulseRate'] = int.tryParse(pulseMatch.group(1)!) ?? 0;
    }

    return result;
  }

  // Parse temperature readings
  Map<String, dynamic> _parseTemperatureData(String text) {
    final Map<String, dynamic> result = {};

    // Look for temperature with decimal
    final tempRegex = RegExp(r'(\d{2,3}\.?\d{0,2})\s*[°]?([CF])?');
    final tempMatch = tempRegex.firstMatch(text);

    if (tempMatch != null) {
      result['temperature'] = double.tryParse(tempMatch.group(1)!) ?? 0.0;

      final unit = tempMatch.group(2);
      if (unit != null) {
        result['unit'] = unit == 'C' ? '°C' : '°F';
      } else {
        // Try to determine unit from value range
        final temp = result['temperature'] as double;
        if (temp >= 90 && temp <= 110) {
          result['unit'] = '°F';
        } else if (temp >= 30 && temp <= 45) {
          result['unit'] = '°C';
        } else {
          result['unit'] = '°C'; // Default
        }
      }
    }

    return result;
  }

  // Parse glucose readings
  Map<String, dynamic> _parseGlucoseData(String text) {
    final Map<String, dynamic> result = {};

    // Look for glucose value
    final glucoseRegex = RegExp(r'(\d{2,4}\.?\d{0,2})');
    final glucoseMatch = glucoseRegex.firstMatch(text);

    if (glucoseMatch != null) {
      result['glucose'] = double.tryParse(glucoseMatch.group(1)!) ?? 0.0;
    }

    // Look for unit
    if (text.toLowerCase().contains('mg/dl') ||
        text.toLowerCase().contains('mgdl')) {
      result['unit'] = 'mg/dL';
    } else if (text.toLowerCase().contains('mmol/l') ||
        text.toLowerCase().contains('mmoll')) {
      result['unit'] = 'mmol/L';
    } else {
      // Try to determine unit from value range
      final glucose = result['glucose'] as double? ?? 0.0;
      if (glucose >= 50 && glucose <= 600) {
        result['unit'] = 'mg/dL';
      } else if (glucose >= 2.8 && glucose <= 33.3) {
        result['unit'] = 'mmol/L';
      } else {
        result['unit'] = 'mg/dL'; // Default
      }
    }

    return result;
  }

  // Parse generic medical device data
  Map<String, dynamic> _parseGenericData(String text) {
    final Map<String, dynamic> result = {};

    // Extract all numbers
    final numberRegex = RegExp(r'\d+\.?\d*');
    final numbers = numberRegex
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();

    result['extractedNumbers'] = numbers;
    result['rawText'] = text;

    return result;
  }

  // Validate extracted data
  bool validateExtractedData(
    Map<String, dynamic> data,
    MedicalDeviceType deviceType,
  ) {
    switch (deviceType) {
      case MedicalDeviceType.bloodPressure:
        final systolic = data['systolic'] as int? ?? 0;
        final diastolic = data['diastolic'] as int? ?? 0;
        final pulse = data['pulse'] as int?;

        // Enhanced validation with pulse pressure check
        final isValidBP =
            systolic >= 70 &&
            systolic <= 250 &&
            diastolic >= 40 &&
            diastolic <= 150 &&
            systolic > diastolic &&
            (systolic - diastolic) >= 10 && // Minimum pulse pressure
            (systolic - diastolic) <= 100; // Maximum reasonable pulse pressure

        final isValidPulse = pulse == null || (pulse >= 30 && pulse <= 200);

        return isValidBP && isValidPulse;

      case MedicalDeviceType.oxygenSaturation:
        final spO2 = data['spO2'] as int? ?? 0;
        return spO2 >= 70 && spO2 <= 100;

      case MedicalDeviceType.thermometer:
        final temp = data['temperature'] as double? ?? 0.0;
        final unit = data['unit'] as String? ?? '°C';
        if (unit == '°C') {
          return temp >= 30.0 && temp <= 45.0;
        } else {
          return temp >= 86.0 && temp <= 113.0;
        }

      case MedicalDeviceType.glucometer:
        final glucose = data['glucose'] as double? ?? 0.0;
        final unit = data['unit'] as String? ?? 'mg/dL';
        if (unit == 'mg/dL') {
          return glucose >= 20.0 && glucose <= 600.0;
        } else {
          return glucose >= 1.1 && glucose <= 33.3;
        }

      case MedicalDeviceType.unknown:
        return true; // Can't validate unknown devices
    }
  }

  // Process test file for testing purposes
  Future<OcrResult> _processTestFile(
    File testFile,
    MedicalDeviceType deviceType,
  ) async {
    try {
      // Get the test content for this device type
      final testContent = TestImageGenerator.getTestTextContent(deviceType);

      // Parse the test data using our parsers
      final parsedData = _parseExtractedData(testContent, deviceType);

      // Create a mock OCR result
      return OcrResult(
        success: true,
        extractedText: testContent,
        confidence: 0.95, // High confidence for test data
        parsedData: parsedData,
        boundingBoxes: [], // Empty for test data
        processingTime: 100, // Mock processing time
      );
    } catch (e) {
      throw OcrException('Failed to process test file: $e');
    }
  }
}

// OCR result class
class OcrResult {
  final bool success;
  final String extractedText;
  final double confidence;
  final Map<String, dynamic> parsedData;
  final List<Map<String, dynamic>> boundingBoxes;
  final int processingTime;

  OcrResult({
    required this.success,
    required this.extractedText,
    required this.confidence,
    required this.parsedData,
    required this.boundingBoxes,
    required this.processingTime,
  });
}

// OCR exception
class OcrException implements Exception {
  final String message;

  OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}
