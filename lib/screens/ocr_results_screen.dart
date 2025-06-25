import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../models/ocr_reading.dart';
import '../services/ocr_provider.dart';
import '../utils/app_utils.dart';
import '../widgets/confidence_indicator.dart';
import '../widgets/reading_value_display.dart';

class OcrResultsScreen extends StatefulWidget {
  final OcrReading reading;

  const OcrResultsScreen({
    super.key,
    required this.reading,
  });

  @override
  State<OcrResultsScreen> createState() => _OcrResultsScreenState();
}

class _OcrResultsScreenState extends State<OcrResultsScreen> {
  late OcrReading _currentReading;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentReading = widget.reading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentReading.deviceType.displayName} Results'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isEditing ? _saveReading : _toggleEdit,
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Confidence and timestamp header
            _buildHeaderInfo(),
            
            const SizedBox(height: 24),
            
            // Main reading display
            _buildReadingDisplay(),
            
            const SizedBox(height: 24),
            
            // Original image
            _buildOriginalImage(),
            
            const SizedBox(height: 24),
            
            // Additional details
            _buildAdditionalDetails(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHeaderInfo() {
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
                _getDeviceIcon(_currentReading.deviceType),
                color: _getDeviceColor(_currentReading.deviceType),
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentReading.deviceType.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ConfidenceIndicator(confidence: _currentReading.confidenceScore),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                AppUtils.formatDateTime(_currentReading.timestamp),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(_currentReading.category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentReading.category.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extracted Readings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ReadingValueDisplay(
            reading: _currentReading,
            isEditing: _isEditing,
            onValueChanged: _updateReadingValue,
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalImage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Original Image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_currentReading.imagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: AppColors.greyLight,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Image not available',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyLight),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_currentReading.notes != null && _currentReading.notes!.isNotEmpty) ...[
            _buildDetailRow('Notes', _currentReading.notes!),
            const SizedBox(height: 8),
          ],
          _buildDetailRow('Confidence', '${(_currentReading.confidenceScore * 100).toInt()}%'),
          const SizedBox(height: 8),
          _buildDetailRow('Manually Edited', _currentReading.isManuallyEdited ? 'Yes' : 'No'),
          const SizedBox(height: 8),
          _buildDetailRow('Created', AppUtils.formatDateTime(_currentReading.createdAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/history');
                },
                icon: const Icon(Icons.history),
                label: const Text('View History'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/camera');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('New Reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveReading() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final ocrProvider = Provider.of<OcrProvider>(context, listen: false);
      final success = await ocrProvider.updateReading(_currentReading);
      
      if (success) {
        setState(() {
          _isEditing = false;
        });
        if (mounted) {
          AppUtils.showSnackBar(context, 'Reading updated successfully');
        }
      } else {
        if (mounted) {
          AppUtils.showSnackBar(context, 'Failed to update reading', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error updating reading: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _updateReadingValue(Map<String, dynamic> newData) {
    setState(() {
      _currentReading = _currentReading.copyWith(
        extractedData: newData,
        isManuallyEdited: true,
        updatedAt: DateTime.now(),
      );
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareReading();
        break;
      case 'delete':
        _deleteReading();
        break;
    }
  }

  void _shareReading() {
    // TODO: Implement sharing functionality
    AppUtils.showSnackBar(context, 'Sharing functionality coming soon');
  }

  Future<void> _deleteReading() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Delete Reading',
      message: 'Are you sure you want to delete this reading? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
    );

    if (confirmed == true) {
      try {
        final ocrProvider = Provider.of<OcrProvider>(context, listen: false);
        final success = await ocrProvider.deleteReading(_currentReading.id);
        
        if (success && mounted) {
          Navigator.of(context).pop();
          AppUtils.showSnackBar(context, 'Reading deleted successfully');
        } else if (mounted) {
          AppUtils.showSnackBar(context, 'Failed to delete reading', isError: true);
        }
      } catch (e) {
        if (mounted) {
          AppUtils.showSnackBar(context, 'Error deleting reading: $e', isError: true);
        }
      }
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

  Color _getCategoryColor(ReadingCategory category) {
    switch (category) {
      case ReadingCategory.morning:
        return Colors.orange;
      case ReadingCategory.afternoon:
        return Colors.blue;
      case ReadingCategory.evening:
        return Colors.purple;
      case ReadingCategory.beforeMedication:
        return Colors.red;
      case ReadingCategory.afterMedication:
        return Colors.green;
      case ReadingCategory.beforeExercise:
        return Colors.teal;
      case ReadingCategory.afterExercise:
        return Colors.indigo;
      case ReadingCategory.other:
        return Colors.grey;
    }
  }
}
