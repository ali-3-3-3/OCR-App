import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_app/parsers/blood_pressure_parser.dart';

void main() {
  group('BloodPressureParser', () {
    test('should parse standard format "120/80"', () {
      final result = BloodPressureParser.parse('120/80 mmHg');

      expect(result['systolic'], equals(120));
      expect(result['diastolic'], equals(80));
      expect(result['unit'], equals('mmHg'));
      expect(
        result['category'],
        equals('High Blood Pressure Stage 1'),
      ); // 80 diastolic = Stage 1
      expect(result['pulsePressure'], equals(40));
      expect(result['meanArterialPressure'], equals(93));
    });

    test('should parse spaced format "135 / 85"', () {
      final result = BloodPressureParser.parse('135 / 85 mmHg');

      expect(result['systolic'], equals(135));
      expect(result['diastolic'], equals(85));
      expect(result['category'], equals('High Blood Pressure Stage 1'));
    });

    test('should parse labeled format "SYS: 140 DIA: 90"', () {
      final result = BloodPressureParser.parse('SYS: 140 DIA: 90 mmHg');

      expect(result['systolic'], equals(140));
      expect(result['diastolic'], equals(90));
      expect(result['category'], equals('High Blood Pressure Stage 2'));
    });

    test('should parse with pulse rate', () {
      final result = BloodPressureParser.parse('120/80 mmHg PULSE: 72 bpm');

      expect(result['systolic'], equals(120));
      expect(result['diastolic'], equals(80));
      expect(result['pulse'], equals(72));
      expect(result['pulseUnit'], equals('bpm'));
    });

    test('should parse complex medical device output', () {
      final text = '''
        SYSTOLIC 145
        DIASTOLIC 95
        PULSE RATE 88 BPM
        UNIT mmHg
        AUTO MODE
      ''';

      final result = BloodPressureParser.parse(text);

      expect(result['systolic'], equals(145));
      expect(result['diastolic'], equals(95));
      expect(result['pulse'], equals(88));
      expect(result['unit'], equals('mmHg'));
      expect(result['category'], equals('High Blood Pressure Stage 2'));
    });

    test('should handle space-separated format "120 80"', () {
      final result = BloodPressureParser.parse('120 80 mmHg');

      expect(result['systolic'], equals(120));
      expect(result['diastolic'], equals(80));
    });

    test('should parse kPa units', () {
      final result = BloodPressureParser.parse('16.0/10.7 kPa');

      expect(result['unit'], equals('kPa'));
    });

    test('should classify blood pressure categories correctly', () {
      // Normal
      var result = BloodPressureParser.parse('110/70');
      expect(result['category'], equals('Normal'));

      // Elevated
      result = BloodPressureParser.parse('125/75');
      expect(result['category'], equals('Elevated'));

      // Stage 1
      result = BloodPressureParser.parse('135/85');
      expect(result['category'], equals('High Blood Pressure Stage 1'));

      // Stage 2
      result = BloodPressureParser.parse('145/95');
      expect(result['category'], equals('High Blood Pressure Stage 2'));

      // Hypertensive Crisis
      result = BloodPressureParser.parse('185/125');
      expect(result['category'], equals('Hypertensive Crisis'));
    });

    test('should handle invalid input gracefully', () {
      final result = BloodPressureParser.parse('invalid text');

      expect(result['systolic'], isNull);
      expect(result['diastolic'], isNull);
      expect(result['unit'], equals('mmHg')); // Default unit
    });

    test('should validate reasonable blood pressure ranges', () {
      // Should reject unrealistic values
      var result = BloodPressureParser.parse('300/200');
      expect(result['systolic'], isNull);

      // Should intelligently handle inverted values by correcting them
      result = BloodPressureParser.parse('80/120');
      expect(result['systolic'], equals(120)); // Should correct to higher value
      expect(result['diastolic'], equals(80)); // Should correct to lower value
      expect(result['parseMethod'], equals('positional_inference'));

      // Should accept valid ranges
      result = BloodPressureParser.parse('120/80');
      expect(result['systolic'], equals(120));
      expect(result['diastolic'], equals(80));
    });

    test('should parse pulse rate variations', () {
      var result = BloodPressureParser.parse('120/80 HR: 75');
      expect(result['pulse'], equals(75));

      result = BloodPressureParser.parse('120/80 BPM 82');
      expect(result['pulse'], equals(82));

      result = BloodPressureParser.parse('120/80 P: 68');
      expect(result['pulse'], equals(68));
    });

    test('should calculate pulse pressure and MAP correctly', () {
      final result = BloodPressureParser.parse('120/80');

      expect(result['pulsePressure'], equals(40)); // 120 - 80
      expect(result['meanArterialPressure'], equals(93)); // (2*80 + 120) / 3
    });

    test('should handle measurement mode detection', () {
      var result = BloodPressureParser.parse('120/80 AUTO MODE');
      expect(result['measurementMode'], equals('automatic'));

      result = BloodPressureParser.parse('120/80 MANUAL');
      expect(result['measurementMode'], equals('manual'));
    });

    test('should detect cuff size information', () {
      var result = BloodPressureParser.parse('120/80 ADULT CUFF');
      expect(result['cuffSize'], equals('adult'));

      result = BloodPressureParser.parse('120/80 LARGE CUFF');
      expect(result['cuffSize'], equals('large'));
    });
  });
}
