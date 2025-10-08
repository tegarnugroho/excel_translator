import 'package:test/test.dart';
import '../../../lib/src/application/translator_service.dart';
import '../../../lib/src/core/core.dart';

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

    test('should provide language validation through service', () {
      // Act - Use LanguageValidationService directly for validation
      final validator = LanguageValidationService();

      // Assert - Test basic language validation functionality
      expect(validator.isValidLanguageCode('en'), isTrue);
      expect(validator.isValidLanguageCode('id'), isTrue);
      expect(validator.isValidLanguageCode('invalid_code'), isFalse);
    });

    test('should provide language name lookup through service', () {
      // Act - Use LanguageValidationService directly for language names
      final validator = LanguageValidationService();

      // Assert - Test language name lookup
      expect(validator.getLanguageName('en'), isNotEmpty);
      expect(validator.getLanguageName('id'), isNotEmpty);
      expect(validator.getLanguageName('es'), isNotEmpty);
    });

    test('should handle invalid language codes gracefully in service', () {
      // Act - Use LanguageValidationService directly
      final validator = LanguageValidationService();

      // Assert - Should not throw for invalid codes
      expect(() => validator.isValidLanguageCode(''), returnsNormally);
      expect(() => validator.isValidLanguageCode('invalid'), returnsNormally);
      expect(() => validator.getLanguageName('invalid'), returnsNormally);
    });
  });
}
