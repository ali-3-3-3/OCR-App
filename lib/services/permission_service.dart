import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../utils/app_utils.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  // Check if photos permission is granted (iOS)
  Future<bool> isPhotosPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request storage permission
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Request photos permission (iOS)
  Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // Request all necessary permissions for camera functionality
  Future<PermissionResult> requestCameraPermissions() async {
    final Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      if (AppUtils.isAndroid) Permission.storage,
      if (AppUtils.isIOS) Permission.photos,
    ].request();

    final cameraStatus = permissions[Permission.camera];
    final storageStatus = AppUtils.isAndroid
        ? permissions[Permission.storage]
        : permissions[Permission.photos];

    final cameraGranted = cameraStatus?.isGranted ?? false;
    final storageGranted = storageStatus?.isGranted ?? false;

    if (cameraGranted && storageGranted) {
      return PermissionResult.granted;
    } else if ((cameraStatus?.isPermanentlyDenied == true) ||
        (AppUtils.isAndroid && storageStatus?.isPermanentlyDenied == true) ||
        (AppUtils.isIOS && storageStatus?.isPermanentlyDenied == true)) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }

  // Check if all camera permissions are granted
  Future<bool> hasAllCameraPermissions() async {
    final cameraGranted = await isCameraPermissionGranted();
    final storageGranted = AppUtils.isAndroid
        ? await isStoragePermissionGranted()
        : await isPhotosPermissionGranted();

    return cameraGranted && storageGranted;
  }

  // Show permission rationale dialog
  Future<bool?> showPermissionRationale(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  // Handle permission denied scenarios
  Future<void> handlePermissionDenied(
    BuildContext context,
    PermissionResult result,
  ) async {
    switch (result) {
      case PermissionResult.denied:
        AppUtils.showSnackBar(
          context,
          'Camera permission is required to capture medical device images.',
          isError: true,
        );
        break;
      case PermissionResult.permanentlyDenied:
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Camera permission has been permanently denied. '
              'Please enable it in app settings to use the camera feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        if (shouldOpenSettings == true) {
          await openAppSettings();
        }
        break;
      case PermissionResult.granted:
        // Permission granted, no action needed
        break;
    }
  }

  // Request permission with rationale
  Future<PermissionResult> requestCameraPermissionWithRationale(
    BuildContext context,
  ) async {
    // Check if we should show rationale
    final shouldShowRationale =
        await Permission.camera.shouldShowRequestRationale;

    if (shouldShowRationale) {
      // Check if context is still valid after async operation
      if (!context.mounted) return PermissionResult.denied;

      final userWantsToGrant = await showPermissionRationale(
        context,
        title: 'Camera Permission Required',
        message:
            'This app needs camera access to capture medical device displays for OCR reading. '
            'This helps you digitize your health readings quickly and accurately.',
      );

      if (userWantsToGrant != true) {
        return PermissionResult.denied;
      }
    }

    return await requestCameraPermissions();
  }

  // Check and request permissions if needed
  Future<bool> ensureCameraPermissions(BuildContext context) async {
    // First check if permissions are already granted
    if (await hasAllCameraPermissions()) {
      return true;
    }

    // Check if context is still valid after async operation
    if (!context.mounted) return false;

    // Request permissions with rationale
    final result = await requestCameraPermissionWithRationale(context);

    if (result != PermissionResult.granted) {
      // Check if context is still valid after async operation
      if (!context.mounted) return false;
      await handlePermissionDenied(context, result);
      return false;
    }

    return true;
  }
}

enum PermissionResult { granted, denied, permanentlyDenied }
