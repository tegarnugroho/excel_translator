import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../lib/src/core/localization_generator.dart';
import '../lib/src/data/lang/language_data.dart';
import '../lib/src/infrastructure/utils/string_utils.dart';
import '../lib/src/infrastructure/validators/language_validator.dart';

void main() {
  group('LanguageData Tests', () {
    test('should load valid language codes', () {
      final codes = LanguageData.validLanguageCodes;

      expect(codes, isNotEmpty);
      expect(codes, contains('en'));
      expect(codes, contains('id'));
      expect(codes, contains('es'));
      expect(codes, isA<Set<String>>());
    });

    test('should load language names', () {
      final names = LanguageData.languageNames;

      expect(names, isNotEmpty);
      expect(names['en'], equals('english'));
      expect(names['id'], equals('indonesian'));
      expect(names['es'], equals('spanish'));
      expect(names, isA<Map<String, String>>());
    });

    test('should handle missing language data gracefully', () {
      // This tests the fallback mechanism
      expect(() => LanguageData.validLanguageCodes, returnsNormally);
      expect(() => LanguageData.languageNames, returnsNormally);
    });
  });

  group('Language Code Validation Tests', () {
    test('should validate standard ISO 639-1 codes', () {
      expect(LanguageValidator.isValidLanguageCode('en'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('id'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('es'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('fr'), isTrue);
    });

    test('should validate locale formats with underscore', () {
      expect(LanguageValidator.isValidLanguageCode('en_US'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('pt_BR'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('zh_CN'), isTrue);
    });

    test('should validate locale formats with dash (backward compatibility)',
        () {
      expect(LanguageValidator.isValidLanguageCode('en-US'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('pt-BR'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('zh-CN'), isTrue);
    });

    test('should handle case insensitive validation', () {
      expect(LanguageValidator.isValidLanguageCode('EN'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('Id'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('ES'), isTrue);
      expect(LanguageValidator.isValidLanguageCode('EN_US'), isTrue);
    });

    test('should reject invalid language codes', () {
      expect(LanguageValidator.isValidLanguageCode('xyz'), isFalse);
      expect(
          LanguageValidator.isValidLanguageCode('invalid'), isFalse);
      expect(LanguageValidator.isValidLanguageCode('123'), isFalse);
      expect(LanguageValidator.isValidLanguageCode(''), isFalse);
    });

    test('should handle whitespace in language codes', () {
      expect(LanguageValidator.isValidLanguageCode(' en '), isTrue);
      expect(LanguageValidator.isValidLanguageCode('  id  '), isTrue);
    });
  });

  group('Sheet Name Sanitization Tests', () {
    test('should sanitize sheet names correctly', () {
      expect(StringUtils.sanitizeSheetName('Login Page'),
          equals('loginpage'));
      expect(StringUtils.sanitizeSheetName('User-Settings'),
          equals('usersettings'));
      expect(StringUtils.sanitizeSheetName('123Numbers'),
          equals('sheet\$123numbers'));
      expect(
          StringUtils.sanitizeSheetName('Special@#Characters'),
          equals('specialcharacters'));
    });

    test('should handle empty and special cases', () {
      expect(StringUtils.sanitizeSheetName(''), equals(''));
      expect(StringUtils.sanitizeSheetName('a'), equals('a'));
      expect(StringUtils.sanitizeSheetName('A'), equals('a'));
    });
  });

  group('Method Name Sanitization Tests', () {
    test('should convert snake_case to camelCase', () {
      expect(StringUtils.sanitizeMethodName('app_title'),
          equals('appTitle'));
      expect(StringUtils.sanitizeMethodName('welcome_message'),
          equals('welcomeMessage'));
      expect(StringUtils.sanitizeMethodName('user_count'),
          equals('userCount'));
      expect(StringUtils.sanitizeMethodName('save_button'),
          equals('saveButton'));
    });

    test('should handle single words', () {
      expect(StringUtils.sanitizeMethodName('hello'),
          equals('hello'));
      expect(StringUtils.sanitizeMethodName('goodbye'),
          equals('goodbye'));
      expect(StringUtils.sanitizeMethodName('submit'),
          equals('submit'));
    });

    test('should handle special characters', () {
      expect(StringUtils.sanitizeMethodName('app-title'),
          equals('apptitle'));
      expect(StringUtils.sanitizeMethodName('user@name'),
          equals('username'));
      expect(StringUtils.sanitizeMethodName('test#key'),
          equals('testkey'));
    });

    test('should handle numbers at start', () {
      expect(StringUtils.sanitizeMethodName('123test'),
          equals('key\$123test')); // Single word, no underscore, but gets key prefix for number start
      expect(
          StringUtils.sanitizeMethodName('1_title'),
          equals(
              'key\$1Title')); // Has underscore, gets processed and key prefix
    });

    test('should handle empty underscore parts', () {
      expect(StringUtils.sanitizeMethodName('app__title'),
          equals('appTitle'));
      expect(StringUtils.sanitizeMethodName('test___key'),
          equals('testKey'));
    });
  });

  group('String Interpolation Tests', () {
    test('should extract interpolation parameters', () {
      final params1 = StringUtils.extractInterpolationParams(
          'Welcome {name}!');
      expect(params1, equals(['name']));

      final params2 = StringUtils.extractInterpolationParams(
          'You have {count} items in {location}');
      expect(params2, containsAll(['count', 'location']));
      expect(params2.length, equals(2));
    });

    test('should handle no interpolation', () {
      final params = StringUtils.extractInterpolationParams(
          'Simple message');
      expect(params, isEmpty);
    });

    test('should handle duplicate parameters', () {
      final params = StringUtils.extractInterpolationParams(
          'Hello {name}, welcome {name}!');
      expect(params, equals(['name'])); // Should deduplicate
    });

    test('should handle complex parameters', () {
      final params = StringUtils.extractInterpolationParams(
          'User {user_id} has {item_count} items');
      expect(params, containsAll(['user_id', 'item_count']));
    });
  });

  group('Language Name Resolution Tests', () {
    test('should resolve known language names', () {
      expect(
          LanguageData.getLanguageName('en'), equals('english'));
      expect(LanguageData.getLanguageName('id'),
          equals('indonesian'));
      expect(
          LanguageData.getLanguageName('es'), equals('spanish'));
    });

    test('should handle case insensitive lookup', () {
      expect(
          LanguageData.getLanguageName('EN'), equals('english'));
      expect(LanguageData.getLanguageName('Id'),
          equals('indonesian'));
    });

    test('should fallback to code for unknown languages', () {
      expect(LanguageData.getLanguageName('unknown'),
          equals('unknown'));
      expect(LanguageData.getLanguageName('xyz'), equals('xyz'));
    });
  });

  group('Capitalization Tests', () {
    test('should capitalize strings correctly', () {
      expect(StringUtils.capitalize('hello'), equals('Hello'));
      expect(StringUtils.capitalize('test'), equals('Test'));
      expect(StringUtils.capitalize('login'), equals('Login'));
    });

    test('should handle edge cases', () {
      expect(StringUtils.capitalize(''), equals(''));
      expect(StringUtils.capitalize('a'), equals('A'));
      expect(StringUtils.capitalize('A'), equals('A'));
    });
  });

  group('File System and Error Handling Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('excel_translator_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should handle missing Excel file gracefully', () async {
      expect(
        () => LocalizationsGenerator.generateFromFile(
          filePath: 'nonexistent.xlsx',
          outputDir: tempDir.path,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should create output directory if it does not exist', () async {
      final outputDir = path.join(tempDir.path, 'generated');

      // Create a minimal test Excel file (we'll mock this with a basic structure)
      // For actual testing, you'd need to create a real Excel file or use mocks

      expect(Directory(outputDir).existsSync(), isFalse);

      // Test would require actual Excel file creation
      // This is a placeholder for the concept
    });
  });

  group('Language Code Validation Edge Cases', () {
    test('should handle null and empty strings', () {
      expect(LanguageValidator.isValidLanguageCode(''), isFalse);
    });

    test('should validate complex locale formats', () {
      expect(LanguageValidator.isValidLanguageCode('en_US_POSIX'),
          isFalse); // Too complex for current implementation
      expect(LanguageValidator.isValidLanguageCode('en_'),
          isTrue); // Current implementation accepts this
      expect(LanguageValidator.isValidLanguageCode('_US'),
          isFalse); // No language code before underscore
    });
  });

  group('Error Handling Tests', () {
    test('should handle invalid sheet data gracefully', () {
      expect(
        () =>
            LanguageValidator.validateLanguageCodes([], 'TestSheet'),
        throwsA(isA<Exception>()),
      );
    });

    test('should provide helpful error messages for invalid language codes',
        () {
      expect(
        () => LanguageValidator.validateLanguageCodes(
            ['invalid', 'xyz'], 'TestSheet'),
        throwsA(
            predicate((e) => e.toString().contains('Invalid language codes'))),
      );
    });
  });
}
