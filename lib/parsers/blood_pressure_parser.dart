import 'dart:math';

/// Comprehensive blood pressure parser that handles various formats and patterns
/// commonly found on different blood pressure monitor displays
class BloodPressureParser {
  /// Parse blood pressure data from OCR extracted text
  static Map<String, dynamic> parse(String text) {
    final Map<String, dynamic> result = {};

    // Clean and normalize the text
    final cleanText = _cleanText(text);

    // Try different parsing strategies in order of reliability
    final bpData = _parseBloodPressureValues(cleanText);
    if (bpData != null) {
      result.addAll(bpData);
    }

    // Parse pulse/heart rate
    final pulseData = _parsePulseRate(cleanText);
    if (pulseData != null) {
      result.addAll(pulseData);
    }

    // Parse additional metadata
    result.addAll(_parseMetadata(cleanText));

    // Validate and clean up results
    return _validateAndCleanResults(result);
  }

  /// Clean and normalize text for better parsing
  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(
          RegExp(r'[^\w\s\/\-\.\:\(\)]'),
          ' ',
        ) // Remove special chars except common ones
        .trim()
        .toLowerCase();
  }

  /// Parse systolic and diastolic blood pressure values
  static Map<String, dynamic>? _parseBloodPressureValues(String text) {
    // Strategy 1: Standard format "120/80" or "120 / 80"
    final standardRegex = RegExp(r'(\d{2,3})\s*[\/]\s*(\d{2,3})');
    final standardMatch = standardRegex.firstMatch(text);

    if (standardMatch != null) {
      final systolic = int.tryParse(standardMatch.group(1)!);
      final diastolic = int.tryParse(standardMatch.group(2)!);

      if (systolic != null &&
          diastolic != null &&
          _isValidBPRange(systolic, diastolic)) {
        return {
          'systolic': systolic,
          'diastolic': diastolic,
          'parseMethod': 'standard_format',
        };
      }
    }

    // Strategy 2: Labeled format "SYS: 120 DIA: 80" or "SYSTOLIC 120 DIASTOLIC 80"
    final labeledSystolic = _extractLabeledValue(text, [
      'sys',
      'systolic',
      'upper',
    ]);
    final labeledDiastolic = _extractLabeledValue(text, [
      'dia',
      'diastolic',
      'lower',
    ]);

    if (labeledSystolic != null &&
        labeledDiastolic != null &&
        _isValidBPRange(labeledSystolic, labeledDiastolic)) {
      return {
        'systolic': labeledSystolic,
        'diastolic': labeledDiastolic,
        'parseMethod': 'labeled_format',
      };
    }

    // Strategy 3: Positional parsing - look for two numbers in typical BP ranges
    final numbers = _extractNumbers(text);
    if (numbers.length >= 2) {
      // Try different combinations to find valid BP pairs
      for (int i = 0; i < numbers.length - 1; i++) {
        for (int j = i + 1; j < numbers.length; j++) {
          final higher = max(numbers[i], numbers[j]);
          final lower = min(numbers[i], numbers[j]);

          if (_isValidBPRange(higher, lower)) {
            return {
              'systolic': higher,
              'diastolic': lower,
              'parseMethod': 'positional_inference',
            };
          }
        }
      }
    }

    // Strategy 4: Single line format "120 80" (space separated)
    final spaceRegex = RegExp(r'(\d{2,3})\s+(\d{2,3})');
    final spaceMatches = spaceRegex.allMatches(text);

    for (final match in spaceMatches) {
      final first = int.tryParse(match.group(1)!);
      final second = int.tryParse(match.group(2)!);

      if (first != null && second != null && _isValidBPRange(first, second)) {
        return {
          'systolic': first,
          'diastolic': second,
          'parseMethod': 'space_separated',
        };
      }
    }

    return null;
  }

  /// Parse pulse/heart rate from text
  static Map<String, dynamic>? _parsePulseRate(String text) {
    // Common pulse indicators
    final pulsePatterns = [
      RegExp(
        r'(?:pulse|hr|bpm|heart\s*rate)[\s:]*(\d{2,3})',
        caseSensitive: false,
      ),
      RegExp(r'(\d{2,3})\s*(?:bpm|beats)', caseSensitive: false),
      RegExp(r'p[\s:]*(\d{2,3})', caseSensitive: false), // Short "P: 72"
    ];

    for (final pattern in pulsePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final pulse = int.tryParse(match.group(1)!);
        if (pulse != null && _isValidPulseRange(pulse)) {
          return {'pulse': pulse, 'pulseUnit': 'bpm'};
        }
      }
    }

    // Fallback: look for standalone numbers in pulse range
    final numbers = _extractNumbers(text);
    for (final number in numbers) {
      if (_isValidPulseRange(number) && !_isLikelyBPValue(number)) {
        return {'pulse': number, 'pulseUnit': 'bpm'};
      }
    }

    return null;
  }

  /// Parse additional metadata like units, timestamps, etc.
  static Map<String, dynamic> _parseMetadata(String text) {
    final Map<String, dynamic> metadata = {};

    // Parse units
    if (text.contains('mmhg')) {
      metadata['unit'] = 'mmHg';
    } else if (text.contains('kpa')) {
      metadata['unit'] = 'kPa';
    } else {
      metadata['unit'] = 'mmHg'; // Default
    }

    // Parse measurement mode/type
    if (text.contains('manual')) {
      metadata['measurementMode'] = 'manual';
    } else if (text.contains('auto')) {
      metadata['measurementMode'] = 'automatic';
    }

    // Parse cuff size indicators
    if (text.contains('adult') || text.contains('regular')) {
      metadata['cuffSize'] = 'adult';
    } else if (text.contains('large')) {
      metadata['cuffSize'] = 'large';
    } else if (text.contains('small') || text.contains('pediatric')) {
      metadata['cuffSize'] = 'small';
    }

    return metadata;
  }

  /// Extract labeled values like "SYS: 120"
  static int? _extractLabeledValue(String text, List<String> labels) {
    for (final label in labels) {
      final pattern = RegExp('$label[\\s:]*([0-9]{2,3})', caseSensitive: false);
      final match = pattern.firstMatch(text);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  /// Extract all numbers from text
  static List<int> _extractNumbers(String text) {
    final numberRegex = RegExp(r'\d{2,3}');
    return numberRegex
        .allMatches(text)
        .map((match) => int.tryParse(match.group(0)!))
        .where((number) => number != null)
        .cast<int>()
        .toList();
  }

  /// Validate if values are in reasonable blood pressure range
  static bool _isValidBPRange(int systolic, int diastolic) {
    return systolic >= 70 &&
        systolic <= 250 &&
        diastolic >= 40 &&
        diastolic <= 150 &&
        systolic > diastolic &&
        (systolic - diastolic) >= 10 && // Minimum pulse pressure
        (systolic - diastolic) <= 100; // Maximum reasonable pulse pressure
  }

  /// Validate if value is in reasonable pulse range
  static bool _isValidPulseRange(int pulse) {
    return pulse >= 30 && pulse <= 200;
  }

  /// Check if a number is likely a blood pressure value
  static bool _isLikelyBPValue(int number) {
    return (number >= 70 && number <= 250) || (number >= 40 && number <= 150);
  }

  /// Validate and clean up final results
  static Map<String, dynamic> _validateAndCleanResults(
    Map<String, dynamic> result,
  ) {
    final Map<String, dynamic> cleanResult = {};

    // Ensure we have valid BP values
    final systolic = result['systolic'] as int?;
    final diastolic = result['diastolic'] as int?;

    if (systolic != null &&
        diastolic != null &&
        _isValidBPRange(systolic, diastolic)) {
      cleanResult['systolic'] = systolic;
      cleanResult['diastolic'] = diastolic;

      // Calculate additional metrics
      cleanResult['pulsePressure'] = systolic - diastolic;
      cleanResult['meanArterialPressure'] = ((2 * diastolic) + systolic) ~/ 3;

      // Add BP category classification
      cleanResult['category'] = _classifyBloodPressure(systolic, diastolic);
    }

    // Add pulse if valid
    final pulse = result['pulse'] as int?;
    if (pulse != null && _isValidPulseRange(pulse)) {
      cleanResult['pulse'] = pulse;
      cleanResult['pulseUnit'] = result['pulseUnit'] ?? 'bpm';
    }

    // Add metadata
    cleanResult['unit'] = result['unit'] ?? 'mmHg';
    if (result['parseMethod'] != null) {
      cleanResult['parseMethod'] = result['parseMethod'];
    }
    if (result['measurementMode'] != null) {
      cleanResult['measurementMode'] = result['measurementMode'];
    }
    if (result['cuffSize'] != null) {
      cleanResult['cuffSize'] = result['cuffSize'];
    }

    return cleanResult;
  }

  /// Classify blood pressure according to AHA guidelines
  static String _classifyBloodPressure(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) {
      return 'Normal';
    } else if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return 'Elevated';
    } else if ((systolic >= 130 && systolic < 140) ||
        (diastolic >= 80 && diastolic < 90)) {
      return 'High Blood Pressure Stage 1';
    } else if ((systolic >= 140 && systolic < 180) ||
        (diastolic >= 90 && diastolic < 120)) {
      return 'High Blood Pressure Stage 2';
    } else {
      return 'Hypertensive Crisis';
    }
  }
}
