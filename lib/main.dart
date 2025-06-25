import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'screens/camera_screen.dart';
import 'screens/gallery_picker_screen.dart';
import 'screens/capture_guidelines_screen.dart';
import 'screens/image_preview_screen.dart';
import 'screens/ocr_results_screen.dart';
import 'services/ocr_provider.dart';

void main() {
  runApp(const OcrMedicalApp());
}

class OcrMedicalApp extends StatelessWidget {
  const OcrMedicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OcrProvider(),
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/camera': (context) => const CameraScreen(),
          '/gallery-picker': (context) => const GalleryPickerScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/capture-guidelines':
              return MaterialPageRoute(
                builder: (context) => const CaptureGuidelinesScreen(),
              );
            case '/image-preview':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => ImagePreviewScreen(
                  imagePath: args['imagePath'],
                  deviceType: args['deviceType'],
                ),
              );
            case '/ocr-results':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) =>
                    OcrResultsScreen(reading: args['reading']),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Welcome to OCR Medical Reader',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Capture and read medical device displays',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const CameraScreen()));
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
