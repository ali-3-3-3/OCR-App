import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

class CaptureGuidelinesOverlay extends StatelessWidget {
  final MedicalDeviceType deviceType;

  const CaptureGuidelinesOverlay({
    super.key,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid lines for alignment
        _buildGridLines(),
        
        // Focus area rectangle
        _buildFocusArea(context),
        
        // Guidelines text
        _buildGuidelinesText(context),
      ],
    );
  }

  Widget _buildGridLines() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridLinesPainter(),
    );
  }

  Widget _buildFocusArea(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final focusWidth = screenSize.width * 0.8;
    final focusHeight = screenSize.height * 0.3;
    
    return Center(
      child: Container(
        width: focusWidth,
        height: focusHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            ...List.generate(4, (index) => _buildCornerIndicator(index)),
            
            // Center crosshair
            Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerIndicator(int index) {
    const size = 20.0;
    const thickness = 3.0;
    
    Widget indicator;
    Alignment alignment;
    
    switch (index) {
      case 0: // Top-left
        alignment = Alignment.topLeft;
        indicator = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: thickness),
              left: BorderSide(color: AppColors.primary, width: thickness),
            ),
          ),
        );
        break;
      case 1: // Top-right
        alignment = Alignment.topRight;
        indicator = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: thickness),
              right: BorderSide(color: AppColors.primary, width: thickness),
            ),
          ),
        );
        break;
      case 2: // Bottom-left
        alignment = Alignment.bottomLeft;
        indicator = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: thickness),
              left: BorderSide(color: AppColors.primary, width: thickness),
            ),
          ),
        );
        break;
      case 3: // Bottom-right
        alignment = Alignment.bottomRight;
        indicator = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: thickness),
              right: BorderSide(color: AppColors.primary, width: thickness),
            ),
          ),
        );
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Align(
      alignment: alignment,
      child: indicator,
    );
  }

  Widget _buildGuidelinesText(BuildContext context) {
    final guidelines = _getGuidelinesForDevice(deviceType);
    
    return Positioned(
      bottom: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceIcon(deviceType),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Capture Tips for ${deviceType.displayName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...guidelines.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  List<String> _getGuidelinesForDevice(MedicalDeviceType deviceType) {
    switch (deviceType) {
      case MedicalDeviceType.bloodPressure:
        return [
          'Position the display within the focus area',
          'Ensure good lighting on the screen',
          'Keep the camera steady and parallel to the display',
          'Make sure all numbers are clearly visible',
          'Avoid reflections and shadows on the screen',
        ];
      case MedicalDeviceType.oxygenSaturation:
        return [
          'Center the SpO2 and pulse readings in the frame',
          'Ensure the display is well-lit and clear',
          'Hold the camera steady for sharp focus',
          'Capture when readings are stable',
          'Avoid glare from the device screen',
        ];
      case MedicalDeviceType.thermometer:
        return [
          'Focus on the temperature display area',
          'Ensure the decimal point is clearly visible',
          'Use good lighting to avoid shadows',
          'Keep the camera parallel to the display',
          'Wait for the reading to stabilize',
        ];
      case MedicalDeviceType.glucometer:
        return [
          'Center the glucose reading in the focus area',
          'Ensure the unit (mg/dL or mmol/L) is visible',
          'Use adequate lighting for clear visibility',
          'Hold steady until the reading is complete',
          'Avoid reflections on the screen',
        ];
      case MedicalDeviceType.unknown:
        return [
          'Position the display within the focus area',
          'Ensure good lighting and clear visibility',
          'Keep the camera steady and focused',
          'Capture all relevant numbers and text',
          'Avoid shadows and reflections',
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
}

class GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.5;

    // Draw rule of thirds grid
    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    // Vertical lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(thirdWidth * i, 0),
        Offset(thirdWidth * i, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, thirdHeight * i),
        Offset(size.width, thirdHeight * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
