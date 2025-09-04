import 'package:test/test.dart';
import '../../../lib/src/application/translator_service.dart';

void main() {
  group('TranslatorService Tests', () {
    test('should create service with factory constructor', () {
      // Act
      final service = TranslatorService.create();

      // Assert
      expect(service, isNotNull);
      expect(service, isA<TranslatorService>());
    });

    test('should have all required dependencies injected', () {
      // This test verifies that the service can be instantiated
      // with all its dependencies properly wired
      expect(() => TranslatorService.create(), returnsNormally);
    });

    test('should provide access to language validation methods', () {
      // Act
      final service = TranslatorService.create();

      // Assert - Test basic language validation functionality
      expect(service.isValidLanguageCode('en'), isTrue);
      expect(service.isValidLanguageCode('id'), isTrue);
      expect(service.isValidLanguageCode('invalid_code'), isFalse);
    });

    test('should provide language name lookup functionality', () {
      // Act
      final service = TranslatorService.create();

      // Assert - Test language name lookup
      expect(service.getLanguageName('en'), isNotEmpty);
      expect(service.getLanguageName('id'), isNotEmpty);
      expect(service.getLanguageName('es'), isNotEmpty);
    });

    test('should handle invalid language codes gracefully', () {
      // Act
      final service = TranslatorService.create();

      // Assert - Should not throw for invalid codes
      expect(() => service.isValidLanguageCode(''), returnsNormally);
      expect(() => service.isValidLanguageCode('invalid'), returnsNormally);
      expect(() => service.getLanguageName('invalid'), returnsNormally);
    });
  });
}
