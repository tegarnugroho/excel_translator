import 'package:test/test.dart';
import '../../../../lib/src/domain/entities/language.dart';

void main() {
  group('Language Entity Tests', () {
    test('should create language with basic code and name', () {
      const language = Language(
        code: 'en',
        name: 'English',
      );

      expect(language.code, equals('en'));
      expect(language.name, equals('English'));
      expect(language.region, isNull);
      expect(language.fullCode, equals('en'));
      expect(language.hasRegion, isFalse);
    });

    test('should create language with region', () {
      const language = Language(
        code: 'en',
        name: 'English',
        region: 'US',
      );

      expect(language.code, equals('en'));
      expect(language.name, equals('English'));
      expect(language.region, equals('US'));
      expect(language.fullCode, equals('en_US'));
      expect(language.hasRegion, isTrue);
    });

    test('should create locale-specific language using named constructor', () {
      final language = Language.locale(
        code: 'pt',
        name: 'Portuguese',
        region: 'BR',
      );

      expect(language.code, equals('pt'));
      expect(language.name, equals('Portuguese'));
      expect(language.region, equals('BR'));
      expect(language.fullCode, equals('pt_BR'));
      expect(language.hasRegion, isTrue);
    });

    test('should handle empty region correctly', () {
      const language = Language(
        code: 'fr',
        name: 'French',
        region: '',
      );

      expect(language.fullCode, equals('fr'));
      expect(language.hasRegion, isFalse);
    });

    test('should create copy with modified fields using copyWith', () {
      const original = Language(
        code: 'es',
        name: 'Spanish',
        region: 'ES',
      );

      final modified = original.copyWith(
        name: 'Español',
        region: 'MX',
      );

      expect(modified.code, equals('es')); // unchanged
      expect(modified.name, equals('Español'));
      expect(modified.region, equals('MX'));
      expect(modified.fullCode, equals('es_MX'));
    });

    test('should implement equality correctly', () {
      const language1 = Language(
        code: 'de',
        name: 'German',
        region: 'DE',
      );

      const language2 = Language(
        code: 'de',
        name: 'German',
        region: 'DE',
      );

      const language3 = Language(
        code: 'de',
        name: 'German',
        region: 'AT',
      );

      expect(language1, equals(language2));
      expect(language1, isNot(equals(language3)));
    });

    test('should implement hashCode correctly', () {
      const language1 = Language(
        code: 'it',
        name: 'Italian',
        region: 'IT',
      );

      const language2 = Language(
        code: 'it',
        name: 'Italian',
        region: 'IT',
      );

      expect(language1.hashCode, equals(language2.hashCode));
    });

    test('should provide meaningful toString representation', () {
      const language = Language(
        code: 'ja',
        name: 'Japanese',
        region: 'JP',
      );

      final stringRepresentation = language.toString();

      expect(stringRepresentation, contains('Language'));
      expect(stringRepresentation, contains('ja'));
      expect(stringRepresentation, contains('Japanese'));
      expect(stringRepresentation, contains('JP'));
    });
  });
}
