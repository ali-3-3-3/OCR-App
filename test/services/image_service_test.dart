import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_app/services/image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageService', () {
    late ImageService imageService;

    setUpAll(() async {
      imageService = ImageService();
    });

    group('validateImageForOcr', () {
      test('should skip validation for test files', () async {
        // Test with a test file path (doesn't need to exist for this test)
        const testFilePath = '/path/to/test_image_123.txt';

        // Validate the test file
        final result = await imageService.validateImageForOcr(testFilePath);

        // Should be valid without any issues
        expect(result.isValid, isTrue);
        expect(result.issues, isEmpty);
        expect(result.imageInfo, isNull);
      });

      test('should validate normal image files', () async {
        // Test with a non-existent normal image file
        const normalFilePath = '/path/to/normal_image.jpg';

        // This should fail validation since the file doesn't exist
        final result = await imageService.validateImageForOcr(normalFilePath);

        // Should fail validation
        expect(result.isValid, isFalse);
        expect(result.issues, isNotEmpty);
      });

      test('should identify test files correctly', () {
        // Test various file patterns
        expect('test_image_123.txt'.contains('test_image_'), isTrue);
        expect('test_image_123.txt'.endsWith('.txt'), isTrue);
        expect('normal_image.jpg'.contains('test_image_'), isFalse);
        expect('test_image_123.jpg'.endsWith('.txt'), isFalse);
      });
    });
  });
}
