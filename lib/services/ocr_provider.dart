import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/ocr_reading.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

enum OcrState { idle, processing, success, error }

class OcrProvider extends ChangeNotifier {
  OcrState _state = OcrState.idle;
  OcrReading? _currentReading;
  List<OcrReading> _readings = [];
  String? _errorMessage;
  double _processingProgress = 0.0;
  String _processingMessage = '';
  final ApiService _apiService = ApiService();

  // Getters
  OcrState get state => _state;
  OcrReading? get currentReading => _currentReading;
  List<OcrReading> get readings => List.unmodifiable(_readings);
  String? get errorMessage => _errorMessage;
  double get processingProgress => _processingProgress;
  String get processingMessage => _processingMessage;
  bool get isProcessing => _state == OcrState.processing;

  // Process image with OCR
  Future<OcrReading?> processImage({
    required File imageFile,
    required MedicalDeviceType deviceType,
    required ReadingCategory category,
    String? notes,
  }) async {
    _setState(OcrState.processing);
    _processingProgress = 0.0;

    try {
      // Step 1: Preparing image
      _updateProgress(0.1, 'Preparing image...');
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate processing time

      // Step 2: Uploading image
      _updateProgress(0.3, 'Uploading image...');

      // Upload image and process with OCR
      final response = await _apiService.uploadFile(
        '/ocr/process',
        imageFile,
        fields: {
          'deviceType': deviceType.toString().split('.').last,
          'category': category.toString().split('.').last,
          'notes': notes ?? '',
        },
      );

      // Step 3: Processing with OCR
      _updateProgress(0.6, 'Analyzing content...');
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 4: Extracting text
      _updateProgress(0.8, 'Extracting text...');
      await Future.delayed(const Duration(milliseconds: 200));

      // Step 5: Parsing results
      _updateProgress(0.9, 'Parsing data...');

      // Parse response
      final readingData = response['reading'] as Map<String, dynamic>;
      final reading = OcrReading.fromJson(readingData);

      _currentReading = reading;
      _readings.insert(0, reading); // Add to beginning of list

      // Step 6: Complete
      _updateProgress(1.0, 'Complete!');
      await Future.delayed(const Duration(milliseconds: 200));

      _setState(OcrState.success);

      return reading;
    } catch (e) {
      _setError('OCR processing failed: $e');
      return null;
    }
  }

  // Load reading history
  Future<void> loadReadings({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/readings?page=$page&limit=$limit',
      );
      final readingsData = response['readings'] as List;

      final newReadings = readingsData
          .map((data) => OcrReading.fromJson(data as Map<String, dynamic>))
          .toList();

      if (page == 1) {
        _readings = newReadings;
      } else {
        _readings.addAll(newReadings);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load readings: $e');
    }
  }

  // Update reading
  Future<bool> updateReading(OcrReading reading) async {
    try {
      final response = await _apiService.put(
        '/readings/${reading.id}',
        body: reading.toJson(),
      );

      final updatedReading = OcrReading.fromJson(
        response['reading'] as Map<String, dynamic>,
      );

      // Update in local list
      final index = _readings.indexWhere((r) => r.id == reading.id);
      if (index != -1) {
        _readings[index] = updatedReading;
      }

      // Update current reading if it's the same
      if (_currentReading?.id == reading.id) {
        _currentReading = updatedReading;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update reading: $e');
      return false;
    }
  }

  // Delete reading
  Future<bool> deleteReading(String readingId) async {
    try {
      await _apiService.delete('/readings/$readingId');

      // Remove from local list
      _readings.removeWhere((r) => r.id == readingId);

      // Clear current reading if it's the deleted one
      if (_currentReading?.id == readingId) {
        _currentReading = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete reading: $e');
      return false;
    }
  }

  // Search readings
  List<OcrReading> searchReadings({
    String? query,
    MedicalDeviceType? deviceType,
    ReadingCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _readings.where((reading) {
      // Text search
      if (query != null && query.isNotEmpty) {
        final searchText = query.toLowerCase();
        final matchesNotes =
            reading.notes?.toLowerCase().contains(searchText) ?? false;
        final matchesDevice = reading.deviceType.displayName
            .toLowerCase()
            .contains(searchText);
        if (!matchesNotes && !matchesDevice) return false;
      }

      // Device type filter
      if (deviceType != null && reading.deviceType != deviceType) {
        return false;
      }

      // Category filter
      if (category != null && reading.category != category) {
        return false;
      }

      // Date range filter
      if (startDate != null && reading.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && reading.timestamp.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  // Get readings by device type
  List<OcrReading> getReadingsByDeviceType(MedicalDeviceType deviceType) {
    return _readings.where((r) => r.deviceType == deviceType).toList();
  }

  // Get recent readings
  List<OcrReading> getRecentReadings({int limit = 10}) {
    final sortedReadings = List<OcrReading>.from(_readings);
    sortedReadings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedReadings.take(limit).toList();
  }

  // Clear current reading
  void clearCurrentReading() {
    _currentReading = null;
    _setState(OcrState.idle);
  }

  // Private methods
  void _setState(OcrState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _state = OcrState.error;
    _errorMessage = error;
    _processingProgress = 0.0;
    notifyListeners();
  }

  void _updateProgress(double progress, [String? message]) {
    _processingProgress = progress;
    if (message != null) {
      _processingMessage = message;
    }
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == OcrState.error) {
      _setState(OcrState.idle);
    }
  }
}
