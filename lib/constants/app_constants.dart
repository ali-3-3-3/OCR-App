// App-wide constants for the OCR Medical Device Reader

class AppConstants {
  // App Information
  static const String appName = 'OCR Medical Reader';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api'; // Update with your backend URL
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String readingsKey = 'ocr_readings';
  
  // Database
  static const String databaseName = 'ocr_app.db';
  static const int databaseVersion = 1;
  
  // Image Processing
  static const double maxImageWidth = 1920.0;
  static const double maxImageHeight = 1080.0;
  static const int imageQuality = 85;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
}

// Medical Device Types
enum MedicalDeviceType {
  bloodPressure,
  oxygenSaturation,
  thermometer,
  glucometer,
  unknown
}

extension MedicalDeviceTypeExtension on MedicalDeviceType {
  String get displayName {
    switch (this) {
      case MedicalDeviceType.bloodPressure:
        return 'Blood Pressure Monitor';
      case MedicalDeviceType.oxygenSaturation:
        return 'Pulse Oximeter';
      case MedicalDeviceType.thermometer:
        return 'Thermometer';
      case MedicalDeviceType.glucometer:
        return 'Blood Glucose Meter';
      case MedicalDeviceType.unknown:
        return 'Unknown Device';
    }
  }
  
  String get iconPath {
    switch (this) {
      case MedicalDeviceType.bloodPressure:
        return 'assets/icons/blood_pressure.png';
      case MedicalDeviceType.oxygenSaturation:
        return 'assets/icons/oxygen_saturation.png';
      case MedicalDeviceType.thermometer:
        return 'assets/icons/thermometer.png';
      case MedicalDeviceType.glucometer:
        return 'assets/icons/glucometer.png';
      case MedicalDeviceType.unknown:
        return 'assets/icons/unknown_device.png';
    }
  }
}

// Reading Categories
enum ReadingCategory {
  morning,
  afternoon,
  evening,
  beforeMedication,
  afterMedication,
  beforeExercise,
  afterExercise,
  other
}

extension ReadingCategoryExtension on ReadingCategory {
  String get displayName {
    switch (this) {
      case ReadingCategory.morning:
        return 'Morning';
      case ReadingCategory.afternoon:
        return 'Afternoon';
      case ReadingCategory.evening:
        return 'Evening';
      case ReadingCategory.beforeMedication:
        return 'Before Medication';
      case ReadingCategory.afterMedication:
        return 'After Medication';
      case ReadingCategory.beforeExercise:
        return 'Before Exercise';
      case ReadingCategory.afterExercise:
        return 'After Exercise';
      case ReadingCategory.other:
        return 'Other';
    }
  }
}

// Measurement Units
enum MeasurementUnit {
  mmHg,
  kPa,
  celsius,
  fahrenheit,
  mgdL,
  mmolL
}

extension MeasurementUnitExtension on MeasurementUnit {
  String get symbol {
    switch (this) {
      case MeasurementUnit.mmHg:
        return 'mmHg';
      case MeasurementUnit.kPa:
        return 'kPa';
      case MeasurementUnit.celsius:
        return '°C';
      case MeasurementUnit.fahrenheit:
        return '°F';
      case MeasurementUnit.mgdL:
        return 'mg/dL';
      case MeasurementUnit.mmolL:
        return 'mmol/L';
    }
  }
}
