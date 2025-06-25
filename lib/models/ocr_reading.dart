import '../constants/app_constants.dart';

class OcrReading {
  final String id;
  final String userId;
  final MedicalDeviceType deviceType;
  final String imagePath;
  final Map<String, dynamic> extractedData;
  final double confidenceScore;
  final ReadingCategory category;
  final String? notes;
  final DateTime timestamp;
  final bool isManuallyEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  OcrReading({
    required this.id,
    required this.userId,
    required this.deviceType,
    required this.imagePath,
    required this.extractedData,
    required this.confidenceScore,
    required this.category,
    this.notes,
    required this.timestamp,
    this.isManuallyEdited = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OcrReading.fromJson(Map<String, dynamic> json) {
    return OcrReading(
      id: json['id'] as String,
      userId: json['userId'] as String,
      deviceType: MedicalDeviceType.values.firstWhere(
        (e) => e.toString() == json['deviceType'],
        orElse: () => MedicalDeviceType.unknown,
      ),
      imagePath: json['imagePath'] as String,
      extractedData: Map<String, dynamic>.from(json['extractedData'] as Map),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      category: ReadingCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ReadingCategory.other,
      ),
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isManuallyEdited: json['isManuallyEdited'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceType': deviceType.toString(),
      'imagePath': imagePath,
      'extractedData': extractedData,
      'confidenceScore': confidenceScore,
      'category': category.toString(),
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'isManuallyEdited': isManuallyEdited,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  OcrReading copyWith({
    String? id,
    String? userId,
    MedicalDeviceType? deviceType,
    String? imagePath,
    Map<String, dynamic>? extractedData,
    double? confidenceScore,
    ReadingCategory? category,
    String? notes,
    DateTime? timestamp,
    bool? isManuallyEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OcrReading(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceType: deviceType ?? this.deviceType,
      imagePath: imagePath ?? this.imagePath,
      extractedData: extractedData ?? this.extractedData,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
      isManuallyEdited: isManuallyEdited ?? this.isManuallyEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OcrReading && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OcrReading(id: $id, deviceType: $deviceType, timestamp: $timestamp)';
  }
}

// Specific reading types
class BloodPressureReading {
  final int systolic;
  final int diastolic;
  final int? pulse;
  final MeasurementUnit unit;

  BloodPressureReading({
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.unit = MeasurementUnit.mmHg,
  });

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) {
    return BloodPressureReading(
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      pulse: json['pulse'] as int?,
      unit: MeasurementUnit.values.firstWhere(
        (e) => e.toString() == json['unit'],
        orElse: () => MeasurementUnit.mmHg,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'unit': unit.toString(),
    };
  }

  String get displayValue => '$systolic/$diastolic ${unit.symbol}';
}

class OxygenSaturationReading {
  final int spO2;
  final int? pulseRate;

  OxygenSaturationReading({
    required this.spO2,
    this.pulseRate,
  });

  factory OxygenSaturationReading.fromJson(Map<String, dynamic> json) {
    return OxygenSaturationReading(
      spO2: json['spO2'] as int,
      pulseRate: json['pulseRate'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spO2': spO2,
      'pulseRate': pulseRate,
    };
  }

  String get displayValue => '$spO2%';
}
