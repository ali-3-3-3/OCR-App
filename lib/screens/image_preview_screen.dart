import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../services/image_service.dart' as image_service;
import '../services/ocr_provider.dart';
import '../utils/app_utils.dart';
import '../widgets/reading_category_selector.dart';
import '../widgets/ocr_loading_overlay.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;
  final MedicalDeviceType deviceType;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    required this.deviceType,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final image_service.ImageService _imageService = image_service.ImageService();
  String _currentImagePath = '';
  ReadingCategory _selectedCategory = ReadingCategory.other;
  String _notes = '';
  bool _isProcessing = false;
  image_service.ImageInfo? _imageInfo;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
    _loadImageInfo();
  }

  Future<void> _loadImageInfo() async {
    try {
      final info = await _imageService.getImageInfo(_currentImagePath);
      setState(() {
        _imageInfo = info;
      });
    } catch (e) {
      debugPrint('Failed to load image info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OcrProvider>(
      builder: (context, ocrProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Preview - ${widget.deviceType.displayName}'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: _isProcessing ? null : _cropImage,
                icon: const Icon(Icons.crop),
              ),
              IconButton(
                onPressed: _isProcessing ? null : _rotateImage,
                icon: const Icon(Icons.rotate_right),
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Image preview
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      color: Colors.black,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: Center(
                          child: Image.file(
                            File(_currentImagePath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Image info and controls
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image information
                            if (_imageInfo != null) _buildImageInfo(),

                            const SizedBox(height: 16),

                            // Reading category selector
                            const Text(
                              'Reading Category',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ReadingCategorySelector(
                              selectedCategory: _selectedCategory,
                              onCategoryChanged: (category) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Notes field
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Notes (Optional)',
                                hintText:
                                    'Add any additional notes about this reading...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onChanged: (value) {
                                _notes = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Loading overlay
              OcrLoadingOverlay(
                isVisible: ocrProvider.isProcessing,
                progress: ocrProvider.processingProgress,
                message: ocrProvider.processingMessage,
                onCancel: () {
                  // TODO: Implement cancel functionality
                },
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomActions(),
        );
      },
    );
  }

  Widget _buildImageInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_imageInfo!.resolution} • ${_imageInfo!.fileSizeFormatted}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
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
        child: Row(
          children: [
            // Retake button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isProcessing
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Retake'),
              ),
            ),

            const SizedBox(width: 16),

            // Process button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processImage,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.text_fields),
                label: Text(_isProcessing ? 'Processing...' : 'Extract Text'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _currentImagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _currentImagePath = croppedFile.path;
        });
        await _loadImageInfo();
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to crop image: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _rotateImage() async {
    try {
      final rotatedFile = await _imageService.rotateImage(
        _currentImagePath,
        90,
      );
      setState(() {
        _currentImagePath = rotatedFile.path;
      });
      await _loadImageInfo();
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to rotate image: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
    });

    // Get provider reference before async operations
    final ocrProvider = Provider.of<OcrProvider>(context, listen: false);

    try {
      // Process image for OCR
      final processedFile = await _imageService.processImageForOcr(
        _currentImagePath,
      );

      // Send to OCR service
      final reading = await ocrProvider.processImage(
        imageFile: processedFile,
        deviceType: widget.deviceType,
        category: _selectedCategory,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      if (reading != null && mounted) {
        // Navigate to results screen
        Navigator.of(
          context,
        ).pushReplacementNamed('/ocr-results', arguments: reading);
      } else if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to process image. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'OCR processing failed: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
