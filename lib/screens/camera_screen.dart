import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../services/permission_service.dart';
import '../utils/app_utils.dart';
import '../widgets/device_type_selector.dart';
import '../widgets/capture_guidelines_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;
  MedicalDeviceType _selectedDeviceType = MedicalDeviceType.bloodPressure;
  bool _showGuidelines = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check permissions first
      final hasPermissions = await PermissionService().ensureCameraPermissions(context);
      if (!hasPermissions) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Camera permission is required';
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Initialize camera controller with back camera
      final backCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      
      // Navigate to image preview screen
      if (mounted) {
        Navigator.of(context).pushNamed(
          '/image-preview',
          arguments: {
            'imagePath': image.path,
            'deviceType': _selectedDeviceType,
          },
        );
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
          _isCapturing = false;
        });
      }
    }
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;

    try {
      final currentFlashMode = _cameraController!.value.flashMode;
      final newFlashMode = currentFlashMode == FlashMode.off 
          ? FlashMode.torch 
          : FlashMode.off;
      
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {});
    } catch (e) {
      AppUtils.showSnackBar(
        context,
        'Failed to toggle flash: $e',
        isError: true,
      );
    }
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;

    try {
      final currentCamera = _cameraController!.description;
      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentCamera.lensDirection,
      );

      await _cameraController!.dispose();
      
      _cameraController = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      AppUtils.showSnackBar(
        context,
        'Failed to switch camera: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Capture Medical Device'),
        actions: [
          if (_isCameraInitialized) ...[
            IconButton(
              onPressed: _toggleFlash,
              icon: Icon(
                _cameraController?.value.flashMode == FlashMode.torch
                    ? Icons.flash_on
                    : Icons.flash_off,
              ),
            ),
            if (_cameras.length > 1)
              IconButton(
                onPressed: _switchCamera,
                icon: const Icon(Icons.flip_camera_ios),
              ),
            IconButton(
              onPressed: () {
                setState(() {
                  _showGuidelines = !_showGuidelines;
                });
              },
              icon: Icon(
                _showGuidelines ? Icons.grid_off : Icons.grid_on,
              ),
            ),
          ],
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // Guidelines overlay
        if (_showGuidelines)
          Positioned.fill(
            child: CaptureGuidelinesOverlay(deviceType: _selectedDeviceType),
          ),
        
        // Device type selector
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: DeviceTypeSelector(
            selectedType: _selectedDeviceType,
            onTypeChanged: (type) {
              setState(() {
                _selectedDeviceType = type;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery button
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/gallery-picker');
              },
              icon: const Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 32,
              ),
            ),
            
            // Capture button
            GestureDetector(
              onTap: _captureImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: _isCapturing ? AppColors.primary : Colors.transparent,
                ),
                child: _isCapturing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 32,
                      ),
              ),
            ),
            
            // Settings button
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/camera-settings');
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
