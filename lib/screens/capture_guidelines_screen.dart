import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../widgets/device_type_selector.dart';

class CaptureGuidelinesScreen extends StatefulWidget {
  const CaptureGuidelinesScreen({super.key});

  @override
  State<CaptureGuidelinesScreen> createState() => _CaptureGuidelinesScreenState();
}

class _CaptureGuidelinesScreenState extends State<CaptureGuidelinesScreen> {
  MedicalDeviceType _selectedDeviceType = MedicalDeviceType.bloodPressure;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Guidelines'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Device type selector
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            color: AppColors.surfaceVariant,
            child: DeviceTypeSelectorExpanded(
              selectedType: _selectedDeviceType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedDeviceType = type;
                });
              },
            ),
          ),
          
          // Guidelines content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGeneralGuidelines(),
                  const SizedBox(height: 24),
                  _buildDeviceSpecificGuidelines(),
                  const SizedBox(height: 24),
                  _buildTroubleshootingTips(),
                  const SizedBox(height: 24),
                  _buildExampleImages(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildGeneralGuidelines() {
    return _buildGuidelineSection(
      title: 'General Capture Tips',
      icon: Icons.camera_alt,
      color: AppColors.primary,
      guidelines: [
        'Ensure good lighting - avoid shadows and reflections',
        'Hold the device steady to prevent blur',
        'Keep the camera parallel to the display',
        'Fill the frame with the device display',
        'Wait for readings to stabilize before capturing',
        'Clean the device screen if necessary',
      ],
    );
  }

  Widget _buildDeviceSpecificGuidelines() {
    final guidelines = _getDeviceSpecificGuidelines(_selectedDeviceType);
    
    return _buildGuidelineSection(
      title: '${_selectedDeviceType.displayName} Specific Tips',
      icon: _getDeviceIcon(_selectedDeviceType),
      color: _getDeviceColor(_selectedDeviceType),
      guidelines: guidelines,
    );
  }

  Widget _buildTroubleshootingTips() {
    return _buildGuidelineSection(
      title: 'Troubleshooting',
      icon: Icons.help_outline,
      color: AppColors.warning,
      guidelines: [
        'If text is blurry: Move closer or use better lighting',
        'If numbers are cut off: Adjust framing to include entire display',
        'If reflection is visible: Change angle or lighting position',
        'If reading is unstable: Wait for device to complete measurement',
        'If OCR fails: Try cropping to focus on numbers only',
        'For low confidence: Retake with better conditions',
      ],
    );
  }

  Widget _buildExampleImages() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Example Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'For best results, your captured images should look similar to these examples:',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildExampleCard(
                  'Good Example',
                  'Clear, well-lit display with all numbers visible',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExampleCard(
                  'Poor Example',
                  'Blurry, dark, or partially visible display',
                  Icons.cancel,
                  AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> guidelines,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...guidelines.map((guideline) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    guideline,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/camera');
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Start Capturing'),
        ),
      ),
    );
  }

  List<String> _getDeviceSpecificGuidelines(MedicalDeviceType deviceType) {
    switch (deviceType) {
      case MedicalDeviceType.bloodPressure:
        return [
          'Capture both systolic and diastolic readings clearly',
          'Include pulse rate if displayed',
          'Ensure the pressure unit (mmHg) is visible',
          'Wait for the measurement cycle to complete',
          'Position cuff properly before measuring',
          'Avoid movement during measurement',
        ];
      case MedicalDeviceType.oxygenSaturation:
        return [
          'Capture SpO2 percentage and pulse rate',
          'Wait for stable readings (usually 10-15 seconds)',
          'Ensure finger is properly positioned in sensor',
          'Avoid nail polish or artificial nails',
          'Keep hand still during measurement',
          'Check for good signal quality indicator',
        ];
      case MedicalDeviceType.thermometer:
        return [
          'Wait for the final temperature reading',
          'Include the temperature unit (°C or °F)',
          'Ensure decimal places are clearly visible',
          'Follow device-specific measurement instructions',
          'Allow thermometer to stabilize before reading',
          'Clean sensor before and after use',
        ];
      case MedicalDeviceType.glucometer:
        return [
          'Capture glucose reading and unit (mg/dL or mmol/L)',
          'Wait for reading to stabilize',
          'Include date/time if displayed',
          'Ensure test strip is properly inserted',
          'Use adequate blood sample size',
          'Check expiration date of test strips',
        ];
      case MedicalDeviceType.unknown:
        return [
          'Capture all visible numbers and text',
          'Include units of measurement if shown',
          'Wait for readings to stabilize',
          'Ensure entire display is visible',
          'Note any error messages or indicators',
          'Follow device-specific instructions',
        ];
    }
  }

  IconData _getDeviceIcon(MedicalDeviceType type) {
    switch (type) {
      case MedicalDeviceType.bloodPressure:
        return Icons.favorite;
      case MedicalDeviceType.oxygenSaturation:
        return Icons.air;
      case MedicalDeviceType.thermometer:
        return Icons.thermostat;
      case MedicalDeviceType.glucometer:
        return Icons.water_drop;
      case MedicalDeviceType.unknown:
        return Icons.device_unknown;
    }
  }

  Color _getDeviceColor(MedicalDeviceType type) {
    switch (type) {
      case MedicalDeviceType.bloodPressure:
        return AppColors.bloodPressure;
      case MedicalDeviceType.oxygenSaturation:
        return AppColors.oxygenSaturation;
      case MedicalDeviceType.thermometer:
        return AppColors.temperature;
      case MedicalDeviceType.glucometer:
        return AppColors.glucose;
      case MedicalDeviceType.unknown:
        return AppColors.grey;
    }
  }
}
