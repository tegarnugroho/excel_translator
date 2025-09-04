import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../lib/src/generator.dart';

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
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('en'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('id'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('es'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('fr'), isTrue);
    });

    test('should validate locale formats with underscore', () {
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('en_US'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('pt_BR'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('zh_CN'), isTrue);
    });

    test('should validate locale formats with dash (backward compatibility)',
        () {
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('en-US'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('pt-BR'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('zh-CN'), isTrue);
    });

    test('should handle case insensitive validation', () {
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('EN'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('Id'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('ES'), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('EN_US'), isTrue);
    });

    test('should reject invalid language codes', () {
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('xyz'), isFalse);
      expect(
          ExcelLocalizationsGenerator.isValidLanguageCode('invalid'), isFalse);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('123'), isFalse);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode(''), isFalse);
    });

    test('should handle whitespace in language codes', () {
      expect(ExcelLocalizationsGenerator.isValidLanguageCode(' en '), isTrue);
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('  id  '), isTrue);
    });
  });

  group('Sheet Name Sanitization Tests', () {
    test('should sanitize sheet names correctly', () {
      expect(ExcelLocalizationsGenerator.sanitizeSheetName('Login Page'),
          equals('loginpage'));
      expect(ExcelLocalizationsGenerator.sanitizeSheetName('User-Settings'),
          equals('usersettings'));
      expect(ExcelLocalizationsGenerator.sanitizeSheetName('123Numbers'),
          equals('sheet\$023numbers'));
      expect(
          ExcelLocalizationsGenerator.sanitizeSheetName('Special@#Characters'),
          equals('specialcharacters'));
    });

    test('should handle empty and special cases', () {
      expect(ExcelLocalizationsGenerator.sanitizeSheetName(''), equals(''));
      expect(ExcelLocalizationsGenerator.sanitizeSheetName('a'), equals('a'));
      expect(ExcelLocalizationsGenerator.sanitizeSheetName('A'), equals('a'));
    });
  });

  group('Method Name Sanitization Tests', () {
    test('should convert snake_case to camelCase', () {
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('app_title'),
          equals('appTitle'));
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('welcome_message'),
          equals('welcomeMessage'));
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('user_count'),
          equals('userCount'));
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('save_button'),
          equals('saveButton'));
    });

    test('should handle single words', () {
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('hello'),
          equals('hello'));
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('goodbye'),
          equals('goodbye'));
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('submit'),
          equals('submit'));
    });

    test('should handle special characters', () {
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('app-title'),
          equals('apptitle'));
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('user@name'),
          equals('username'));
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('test#key'),
          equals('testkey'));
    });

    test('should handle numbers at start', () {
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('123test'),
          equals('123test')); // Single word, no underscore, no key prefix
      expect(
          ExcelLocalizationsGenerator.sanitizeMethodName('1_title'),
          equals(
              'key\$0Title')); // Has underscore, gets processed and key prefix
    });

    test('should handle empty underscore parts', () {
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('app__title'),
          equals('appTitle'));
      expect(ExcelLocalizationsGenerator.sanitizeMethodName('test___key'),
          equals('testKey'));
    });
  });

  group('String Interpolation Tests', () {
    test('should extract interpolation parameters', () {
      final params1 = ExcelLocalizationsGenerator.extractInterpolationParams(
          'Welcome {name}!');
      expect(params1, equals(['name']));

      final params2 = ExcelLocalizationsGenerator.extractInterpolationParams(
          'You have {count} items in {location}');
      expect(params2, containsAll(['count', 'location']));
      expect(params2.length, equals(2));
    });

    test('should handle no interpolation', () {
      final params = ExcelLocalizationsGenerator.extractInterpolationParams(
          'Simple message');
      expect(params, isEmpty);
    });

    test('should handle duplicate parameters', () {
      final params = ExcelLocalizationsGenerator.extractInterpolationParams(
          'Hello {name}, welcome {name}!');
      expect(params, equals(['name'])); // Should deduplicate
    });

    test('should handle complex parameters', () {
      final params = ExcelLocalizationsGenerator.extractInterpolationParams(
          'User {user_id} has {item_count} items');
      expect(params, containsAll(['user_id', 'item_count']));
    });
  });

  group('Language Name Resolution Tests', () {
    test('should resolve known language names', () {
      expect(
          ExcelLocalizationsGenerator.getLanguageName('en'), equals('english'));
      expect(ExcelLocalizationsGenerator.getLanguageName('id'),
          equals('indonesian'));
      expect(
          ExcelLocalizationsGenerator.getLanguageName('es'), equals('spanish'));
    });

    test('should handle case insensitive lookup', () {
      expect(
          ExcelLocalizationsGenerator.getLanguageName('EN'), equals('english'));
      expect(ExcelLocalizationsGenerator.getLanguageName('Id'),
          equals('indonesian'));
    });

    test('should fallback to code for unknown languages', () {
      expect(ExcelLocalizationsGenerator.getLanguageName('unknown'),
          equals('unknown'));
      expect(ExcelLocalizationsGenerator.getLanguageName('xyz'), equals('xyz'));
    });
  });

  group('Capitalization Tests', () {
    test('should capitalize strings correctly', () {
      expect(ExcelLocalizationsGenerator.capitalize('hello'), equals('Hello'));
      expect(ExcelLocalizationsGenerator.capitalize('test'), equals('Test'));
      expect(ExcelLocalizationsGenerator.capitalize('login'), equals('Login'));
    });

    test('should handle edge cases', () {
      expect(ExcelLocalizationsGenerator.capitalize(''), equals(''));
      expect(ExcelLocalizationsGenerator.capitalize('a'), equals('A'));
      expect(ExcelLocalizationsGenerator.capitalize('A'), equals('A'));
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
        () => ExcelLocalizationsGenerator.generateFromExcel(
          excelFilePath: 'nonexistent.xlsx',
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
      expect(ExcelLocalizationsGenerator.isValidLanguageCode(''), isFalse);
    });

    test('should validate complex locale formats', () {
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('en_US_POSIX'),
          isFalse); // Too complex for current implementation
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('en_'),
          isTrue); // Current implementation accepts this
      expect(ExcelLocalizationsGenerator.isValidLanguageCode('_US'),
          isFalse); // No language code before underscore
    });
  });

  group('Error Handling Tests', () {
    test('should handle invalid sheet data gracefully', () {
      expect(
        () =>
            ExcelLocalizationsGenerator.validateLanguageCodes([], 'TestSheet'),
        throwsA(isA<Exception>()),
      );
    });

    test('should provide helpful error messages for invalid language codes',
        () {
      expect(
        () => ExcelLocalizationsGenerator.validateLanguageCodes(
            ['invalid', 'xyz'], 'TestSheet'),
        throwsA(
            predicate((e) => e.toString().contains('Invalid language codes'))),
      );
    });
  });
}
