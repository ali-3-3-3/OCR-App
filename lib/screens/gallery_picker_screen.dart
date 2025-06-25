import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../services/permission_service.dart';
import '../services/image_service.dart';
import '../utils/app_utils.dart';
import '../utils/test_image_generator.dart';
import '../widgets/device_type_selector.dart';

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final ImageService _imageService = ImageService();
  MedicalDeviceType _selectedDeviceType = MedicalDeviceType.bloodPressure;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Image'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device type selector
            const Text(
              'Select Device Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            DeviceTypeSelectorExpanded(
              selectedType: _selectedDeviceType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedDeviceType = type;
                });
              },
            ),

            const SizedBox(height: 32),

            // Image selection options
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Gallery option
            _buildImageSourceOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              subtitle: 'Select an existing photo from your device',
              color: AppColors.primary,
              onTap: () => _pickImageFromGallery(),
            ),

            const SizedBox(height: 16),

            // Camera option
            _buildImageSourceOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              subtitle: 'Capture a new photo with your camera',
              color: AppColors.secondary,
              onTap: () => _pickImageFromCamera(),
            ),

            const SizedBox(height: 16),

            // Test image option
            _buildImageSourceOption(
              icon: Icons.science,
              title: 'Use Test Image',
              subtitle: 'Use a sample blood pressure reading for testing',
              color: AppColors.accent,
              onTap: () => _useTestImage(),
            ),

            const SizedBox(height: 32),

            // Tips section
            _buildTipsSection(),

            const SizedBox(height: 32), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyLight),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
              SizedBox(width: 8),
              Text(
                'Tips for Better OCR Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getTipsForDevice(_selectedDeviceType)
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              ,
        ],
      ),
    );
  }

  List<String> _getTipsForDevice(MedicalDeviceType deviceType) {
    switch (deviceType) {
      case MedicalDeviceType.bloodPressure:
        return [
          'Ensure the display shows clear systolic and diastolic readings',
          'Make sure the image is well-lit and not blurry',
          'Include the entire display area in the photo',
          'Avoid reflections and shadows on the screen',
        ];
      case MedicalDeviceType.oxygenSaturation:
        return [
          'Capture both SpO2 percentage and pulse rate if available',
          'Ensure the display is stable and not changing',
          'Use good lighting to make numbers clearly visible',
          'Keep the camera steady to avoid blur',
        ];
      case MedicalDeviceType.thermometer:
        return [
          'Make sure the temperature reading is complete and stable',
          'Include the unit (°C or °F) in the image',
          'Ensure the decimal point is clearly visible',
          'Use adequate lighting for sharp text',
        ];
      case MedicalDeviceType.glucometer:
        return [
          'Capture the glucose reading when it\'s stable',
          'Include the measurement unit (mg/dL or mmol/L)',
          'Ensure the display is well-lit and clear',
          'Avoid glare and reflections on the screen',
        ];
      case MedicalDeviceType.unknown:
        return [
          'Capture all visible numbers and text clearly',
          'Use good lighting and keep the image sharp',
          'Include the entire display area',
          'Avoid shadows and reflections',
        ];
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check gallery permissions
      final hasPermissions = await PermissionService().ensureGalleryPermissions(
        context,
      );
      if (!hasPermissions) {
        return;
      }

      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth,
        maxHeight: AppConstants.maxImageHeight,
        imageQuality: AppConstants.imageQuality,
      );

      if (image != null) {
        await _processSelectedImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to select image: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check permissions
      final hasPermissions = await PermissionService().ensureCameraPermissions(
        context,
      );
      if (!hasPermissions) {
        return;
      }

      // Take photo with camera
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth,
        maxHeight: AppConstants.maxImageHeight,
        imageQuality: AppConstants.imageQuality,
      );

      if (image != null) {
        await _processSelectedImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to capture image: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processSelectedImage(String imagePath) async {
    try {
      // Validate the image
      final validation = await _imageService.validateImageForOcr(imagePath);

      if (!validation.isValid) {
        if (mounted) {
          _showValidationDialog(validation.issues);
        }
        return;
      }

      // Navigate to image preview screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          '/image-preview',
          arguments: {
            'imagePath': imagePath,
            'deviceType': _selectedDeviceType,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to process image: $e',
          isError: true,
        );
      }
    }
  }

  void _showValidationDialog(List<String> issues) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Quality Issues'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The selected image has the following issues:'),
            const SizedBox(height: 12),
            ...issues
                .map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(color: AppColors.error),
                        ),
                        Expanded(child: Text(issue)),
                      ],
                    ),
                  ),
                )
                ,
            const SizedBox(height: 12),
            const Text(
              'You can still proceed, but OCR accuracy may be reduced.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Choose Different Image'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Proceed anyway
            },
            child: const Text('Proceed Anyway'),
          ),
        ],
      ),
    );
  }

  Future<void> _useTestImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a test image based on selected device type
      final testImagePath = await TestImageGenerator.generateTestImage(
        _selectedDeviceType,
      );

      await _processSelectedImage(testImagePath);
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to create test image: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
