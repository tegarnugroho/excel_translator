import 'package:test/test.dart';
import '../../../lib/src/services/language_service.dart';

void main() {
  group('LanguageService Tests', () {
    late LanguageService languageService;

    setUp(() {
      languageService = LanguageService();
    });

    test('should validate common language codes', () {
      expect(languageService.isValidLanguageCode('en'), isTrue);
      expect(languageService.isValidLanguageCode('id'), isTrue);
      expect(languageService.isValidLanguageCode('es'), isTrue);
      expect(languageService.isValidLanguageCode('fr'), isTrue);
      expect(languageService.isValidLanguageCode('de'), isTrue);
    });

    test('should reject invalid language codes', () {
      expect(languageService.isValidLanguageCode('invalid'), isFalse);
      expect(languageService.isValidLanguageCode('xyz'), isFalse);
      expect(languageService.isValidLanguageCode(''), isFalse);
    });

    test('should validate locale format with underscore', () {
      expect(languageService.isValidLanguageCode('en_US'), isTrue);
      expect(languageService.isValidLanguageCode('pt_BR'), isTrue);
      expect(languageService.isValidLanguageCode('zh_CN'), isTrue);
    });

    test(
      'should validate locale format with dash (backward compatibility)',
      () {
        expect(languageService.isValidLanguageCode('en-US'), isTrue);
        expect(languageService.isValidLanguageCode('pt-BR'), isTrue);
        expect(languageService.isValidLanguageCode('zh-CN'), isTrue);
      },
    );

    test('should get language names', () {
      expect(languageService.getLanguageName('en'), isNotEmpty);
      expect(languageService.getLanguageName('id'), isNotEmpty);
      expect(languageService.getLanguageName('es'), isNotEmpty);
    });

    test('should return valid language codes set', () {
      final codes = languageService.validLanguageCodes;

      expect(codes, isNotEmpty);
      expect(codes.contains('en'), isTrue);
      expect(codes.contains('id'), isTrue);
      expect(codes.contains('es'), isTrue);
    });

    test('should filter valid language codes from list', () {
      final testCodes = ['en', 'invalid', 'id', 'xyz', 'es'];

      final validCodes = languageService.filterValidLanguageCodes(
        testCodes,
        'test_sheet',
      );

      expect(validCodes.keys, containsAll(['en', 'id', 'es']));
      expect(validCodes.keys, isNot(contains('invalid')));
      expect(validCodes.keys, isNot(contains('xyz')));
    });

    test('should throw when validating empty language codes', () {
      expect(
        () => languageService.validateLanguageCodes([], 'test_sheet'),
        throwsException,
      );
    });

    test('should throw when validating invalid language codes', () {
      expect(
        () => languageService.validateLanguageCodes([
          'invalid',
          'xyz',
        ], 'test_sheet'),
        throwsException,
      );
    });

    test('should pass validation for valid language codes', () {
      expect(
        () => languageService.validateLanguageCodes([
          'en',
          'id',
          'es',
        ], 'test_sheet'),
        returnsNormally,
      );
    });
  });
}
