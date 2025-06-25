import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

class DeviceTypeSelector extends StatelessWidget {
  final MedicalDeviceType selectedType;
  final ValueChanged<MedicalDeviceType> onTypeChanged;

  const DeviceTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Device Type:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: MedicalDeviceType.values
                  .where((type) => type != MedicalDeviceType.unknown)
                  .map((type) => _buildDeviceTypeChip(type))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTypeChip(MedicalDeviceType type) {
    final isSelected = type == selectedType;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getDeviceIcon(type),
                size: 16,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                _getShortDisplayName(type),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  String _getShortDisplayName(MedicalDeviceType type) {
    switch (type) {
      case MedicalDeviceType.bloodPressure:
        return 'Blood Pressure';
      case MedicalDeviceType.oxygenSaturation:
        return 'SpO2';
      case MedicalDeviceType.thermometer:
        return 'Temperature';
      case MedicalDeviceType.glucometer:
        return 'Glucose';
      case MedicalDeviceType.unknown:
        return 'Unknown';
    }
  }
}

// Expanded device type selector for settings or detailed selection
class DeviceTypeSelectorExpanded extends StatelessWidget {
  final MedicalDeviceType selectedType;
  final ValueChanged<MedicalDeviceType> onTypeChanged;

  const DeviceTypeSelectorExpanded({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medical Device Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...MedicalDeviceType.values
            .where((type) => type != MedicalDeviceType.unknown)
            .map((type) => _buildDeviceTypeTile(context, type))
            ,
      ],
    );
  }

  Widget _buildDeviceTypeTile(BuildContext context, MedicalDeviceType type) {
    final isSelected = type == selectedType;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onTypeChanged(type),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.greyLight,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.greyLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDeviceIcon(type),
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getDeviceDescription(type),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
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

  String _getDeviceDescription(MedicalDeviceType type) {
    switch (type) {
      case MedicalDeviceType.bloodPressure:
        return 'Systolic/Diastolic pressure readings';
      case MedicalDeviceType.oxygenSaturation:
        return 'Blood oxygen saturation levels';
      case MedicalDeviceType.thermometer:
        return 'Body temperature measurements';
      case MedicalDeviceType.glucometer:
        return 'Blood glucose level readings';
      case MedicalDeviceType.unknown:
        return 'Other medical devices';
    }
  }
}
