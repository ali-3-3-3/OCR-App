import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../models/ocr_reading.dart';

class ReadingValueDisplay extends StatefulWidget {
  final OcrReading reading;
  final bool isEditing;
  final Function(Map<String, dynamic>) onValueChanged;

  const ReadingValueDisplay({
    super.key,
    required this.reading,
    required this.isEditing,
    required this.onValueChanged,
  });

  @override
  State<ReadingValueDisplay> createState() => _ReadingValueDisplayState();
}

class _ReadingValueDisplayState extends State<ReadingValueDisplay> {
  late Map<String, dynamic> _currentData;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _currentData = Map<String, dynamic>.from(widget.reading.extractedData);
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ReadingValueDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reading != oldWidget.reading) {
      _currentData = Map<String, dynamic>.from(widget.reading.extractedData);
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _controllers.clear();
    _currentData.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.reading.deviceType) {
      case MedicalDeviceType.bloodPressure:
        return _buildBloodPressureDisplay();
      case MedicalDeviceType.oxygenSaturation:
        return _buildOxygenSaturationDisplay();
      case MedicalDeviceType.thermometer:
        return _buildTemperatureDisplay();
      case MedicalDeviceType.glucometer:
        return _buildGlucoseDisplay();
      case MedicalDeviceType.unknown:
        return _buildGenericDisplay();
    }
  }

  Widget _buildBloodPressureDisplay() {
    final systolic = _currentData['systolic'] ?? 0;
    final diastolic = _currentData['diastolic'] ?? 0;
    final pulse = _currentData['pulse'];
    final unit = _currentData['unit'] ?? 'mmHg';

    return Column(
      children: [
        // Main blood pressure reading
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bloodPressure.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bloodPressure.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEditableValue(
                'systolic',
                systolic.toString(),
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.bloodPressure,
                inputType: TextInputType.number,
                validator: (value) => _validateBloodPressure(value, true),
              ),
              const Text(
                ' / ',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bloodPressure,
                ),
              ),
              _buildEditableValue(
                'diastolic',
                diastolic.toString(),
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.bloodPressure,
                inputType: TextInputType.number,
                validator: (value) => _validateBloodPressure(value, false),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        if (pulse != null) ...[
          const SizedBox(height: 16),
          _buildValueRow(
            'Pulse Rate',
            Icons.favorite,
            _buildEditableValue(
              'pulse',
              pulse.toString(),
              suffix: ' bpm',
              inputType: TextInputType.number,
              validator: _validatePulse,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOxygenSaturationDisplay() {
    final spO2 = _currentData['spO2'] ?? 0;
    final pulseRate = _currentData['pulseRate'];

    return Column(
      children: [
        // Main SpO2 reading
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.oxygenSaturation.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.oxygenSaturation.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEditableValue(
                'spO2',
                spO2.toString(),
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.oxygenSaturation,
                inputType: TextInputType.number,
                validator: _validateSpO2,
              ),
              const Text(
                '%',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        if (pulseRate != null) ...[
          const SizedBox(height: 16),
          _buildValueRow(
            'Pulse Rate',
            Icons.favorite,
            _buildEditableValue(
              'pulseRate',
              pulseRate.toString(),
              suffix: ' bpm',
              inputType: TextInputType.number,
              validator: _validatePulse,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTemperatureDisplay() {
    final temperature = _currentData['temperature'] ?? 0.0;
    final unit = _currentData['unit'] ?? '°C';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.temperature.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.temperature.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEditableValue(
            'temperature',
            temperature.toString(),
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.temperature,
            inputType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateTemperature,
          ),
          const SizedBox(width: 8),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlucoseDisplay() {
    final glucose = _currentData['glucose'] ?? 0.0;
    final unit = _currentData['unit'] ?? 'mg/dL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glucose.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glucose.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEditableValue(
            'glucose',
            glucose.toString(),
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.glucose,
            inputType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validateGlucose,
          ),
          const SizedBox(width: 8),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericDisplay() {
    return Column(
      children: _currentData.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildValueRow(
            entry.key,
            Icons.info,
            _buildEditableValue(
              entry.key,
              entry.value.toString(),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildValueRow(String label, IconData icon, Widget valueWidget) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildEditableValue(
    String key,
    String value, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textPrimary,
    String suffix = '',
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    if (!widget.isEditing) {
      return Text(
        '$value$suffix',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      );
    }

    return SizedBox(
      width: fontSize * 3, // Approximate width based on font size
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: inputType,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          suffix: suffix.isNotEmpty ? Text(suffix) : null,
        ),
        onChanged: (newValue) {
          _updateValue(key, newValue);
        },
        validator: validator,
      ),
    );
  }

  void _updateValue(String key, String value) {
    setState(() {
      // Try to parse as number if possible
      if (key == 'systolic' || key == 'diastolic' || key == 'pulse' || 
          key == 'spO2' || key == 'pulseRate') {
        _currentData[key] = int.tryParse(value) ?? 0;
      } else if (key == 'temperature' || key == 'glucose') {
        _currentData[key] = double.tryParse(value) ?? 0.0;
      } else {
        _currentData[key] = value;
      }
    });
    
    widget.onValueChanged(_currentData);
  }

  String? _validateBloodPressure(String? value, bool isSystolic) {
    final intValue = int.tryParse(value ?? '');
    if (intValue == null) return 'Invalid number';
    
    if (isSystolic) {
      if (intValue < 70 || intValue > 250) return 'Range: 70-250';
    } else {
      if (intValue < 40 || intValue > 150) return 'Range: 40-150';
    }
    
    return null;
  }

  String? _validatePulse(String? value) {
    final intValue = int.tryParse(value ?? '');
    if (intValue == null) return 'Invalid number';
    if (intValue < 30 || intValue > 220) return 'Range: 30-220';
    return null;
  }

  String? _validateSpO2(String? value) {
    final intValue = int.tryParse(value ?? '');
    if (intValue == null) return 'Invalid number';
    if (intValue < 70 || intValue > 100) return 'Range: 70-100';
    return null;
  }

  String? _validateTemperature(String? value) {
    final doubleValue = double.tryParse(value ?? '');
    if (doubleValue == null) return 'Invalid number';
    
    final unit = _currentData['unit'] ?? '°C';
    if (unit == '°C') {
      if (doubleValue < 30.0 || doubleValue > 45.0) return 'Range: 30-45°C';
    } else {
      if (doubleValue < 86.0 || doubleValue > 113.0) return 'Range: 86-113°F';
    }
    
    return null;
  }

  String? _validateGlucose(String? value) {
    final doubleValue = double.tryParse(value ?? '');
    if (doubleValue == null) return 'Invalid number';
    
    final unit = _currentData['unit'] ?? 'mg/dL';
    if (unit == 'mg/dL') {
      if (doubleValue < 20.0 || doubleValue > 600.0) return 'Range: 20-600';
    } else {
      if (doubleValue < 1.1 || doubleValue > 33.3) return 'Range: 1.1-33.3';
    }
    
    return null;
  }
}
