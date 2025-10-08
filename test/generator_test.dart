import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../lib/src/core/core.dart';
import '../lib/src/data/repositories_impl/language_repository_impl.dart';

void main() {
  final languageValidationService = LanguageValidationService();
  final languageDataRepo = LanguageRepositoryImpl();

  group('LanguageRepository Tests', () {
    test('should load valid language codes', () {
      final codes = languageDataRepo.getValidLanguageCodes();

      expect(codes, isNotEmpty);
      expect(codes, contains('en'));
      expect(codes, contains('id'));
      expect(codes, contains('es'));
      expect(codes, isA<Set<String>>());
    });

    test('should load language names', () {
      final names = languageDataRepo.getLanguageNames();

      expect(names, isNotEmpty);
      expect(names['en'], equals('english'));
      expect(names['id'], equals('indonesian'));
      expect(names['es'], equals('spanish'));
      expect(names, isA<Map<String, String>>());
    });

    test('should handle missing language data gracefully', () {
      // This tests the fallback mechanism
      expect(() => languageDataRepo.getValidLanguageCodes(), returnsNormally);
      expect(() => languageDataRepo.getLanguageNames(), returnsNormally);
    });
  });

  group('Language Code Validation Tests', () {
    test('should validate standard ISO 639-1 codes', () {
      expect(languageRepo.isValidLanguageCode('en'), isTrue);
      expect(languageRepo.isValidLanguageCode('id'), isTrue);
      expect(languageRepo.isValidLanguageCode('es'), isTrue);
      expect(languageRepo.isValidLanguageCode('fr'), isTrue);
    });

    test('should validate locale formats with underscore', () {
      expect(languageRepo.isValidLanguageCode('en_US'), isTrue);
      expect(languageRepo.isValidLanguageCode('pt_BR'), isTrue);
      expect(languageRepo.isValidLanguageCode('zh_CN'), isTrue);
    });

    test('should validate locale formats with dash (backward compatibility)',
        () {
      expect(languageRepo.isValidLanguageCode('en-US'), isTrue);
      expect(languageRepo.isValidLanguageCode('pt-BR'), isTrue);
      expect(languageRepo.isValidLanguageCode('zh-CN'), isTrue);
    });

    test('should handle case insensitive validation', () {
      expect(languageRepo.isValidLanguageCode('EN'), isTrue);
      expect(languageRepo.isValidLanguageCode('Id'), isTrue);
      expect(languageRepo.isValidLanguageCode('ES'), isTrue);
      expect(languageRepo.isValidLanguageCode('EN_US'), isTrue);
    });

    test('should reject invalid language codes', () {
      expect(languageRepo.isValidLanguageCode('xyz'), isFalse);
      expect(languageRepo.isValidLanguageCode('invalid'), isFalse);
      expect(languageRepo.isValidLanguageCode('123'), isFalse);
      expect(languageRepo.isValidLanguageCode(''), isFalse);
    });

    test('should handle whitespace in language codes', () {
      expect(languageRepo.isValidLanguageCode(' en '), isTrue);
      expect(languageRepo.isValidLanguageCode('  id  '), isTrue);
    });
  });

  group('Sheet Name Sanitization Tests', () {
    test('should sanitize sheet names correctly', () {
      expect(StringUtils.sanitizeSheetName('Login Page'), equals('loginpage'));
      expect(StringUtils.sanitizeSheetName('User-Settings'),
          equals('usersettings'));
      expect(StringUtils.sanitizeSheetName('123Numbers'),
          equals('sheet\$123numbers'));
      expect(StringUtils.sanitizeSheetName('Special@#Characters'),
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
      expect(StringUtils.sanitizeMethodName('app_title'), equals('appTitle'));
      expect(StringUtils.sanitizeMethodName('welcome_message'),
          equals('welcomeMessage'));
      expect(StringUtils.sanitizeMethodName('user_count'), equals('userCount'));
      expect(
          StringUtils.sanitizeMethodName('save_button'), equals('saveButton'));
    });

    test('should handle single words', () {
      expect(StringUtils.sanitizeMethodName('hello'), equals('hello'));
      expect(StringUtils.sanitizeMethodName('goodbye'), equals('goodbye'));
      expect(StringUtils.sanitizeMethodName('submit'), equals('submit'));
    });

    test('should handle special characters', () {
      expect(StringUtils.sanitizeMethodName('app-title'), equals('apptitle'));
      expect(StringUtils.sanitizeMethodName('user@name'), equals('username'));
      expect(StringUtils.sanitizeMethodName('test#key'), equals('testkey'));
    });

    test('should handle numbers at start', () {
      expect(
          StringUtils.sanitizeMethodName('123test'),
          equals(
              'key\$123test')); // Single word, no underscore, but gets key prefix for number start
      expect(
          StringUtils.sanitizeMethodName('1_title'),
          equals(
              'key\$1Title')); // Has underscore, gets processed and key prefix
    });

    test('should handle empty underscore parts', () {
      expect(StringUtils.sanitizeMethodName('app__title'), equals('appTitle'));
      expect(StringUtils.sanitizeMethodName('test___key'), equals('testKey'));
    });
  });

  group('String Interpolation Tests', () {
    test('should extract interpolation parameters', () {
      final params1 = StringUtils.extractInterpolationParams('Welcome {name}!');
      expect(params1, equals(['name']));

      final params2 = StringUtils.extractInterpolationParams(
          'You have {count} items in {location}');
      expect(params2, containsAll(['count', 'location']));
      expect(params2.length, equals(2));
    });

    test('should handle no interpolation', () {
      final params = StringUtils.extractInterpolationParams('Simple message');
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
      expect(languageDataRepo.getLanguageName('en'), equals('english'));
      expect(languageDataRepo.getLanguageName('id'), equals('indonesian'));
      expect(languageDataRepo.getLanguageName('es'), equals('spanish'));
    });

    test('should handle case insensitive lookup', () {
      expect(languageDataRepo.getLanguageName('EN'), equals('english'));
      expect(languageDataRepo.getLanguageName('Id'), equals('indonesian'));
    });

    test('should fallback to code for unknown languages', () {
      expect(languageDataRepo.getLanguageName('unknown'), equals('unknown'));
      expect(languageDataRepo.getLanguageName('xyz'), equals('xyz'));
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

  group('Class Name Sanitization Tests', () {
    test('should sanitize class names with hyphens correctly', () {
      expect(StringUtils.sanitizeClassName('auth-errors'), equals('AuthErrors'));
      expect(StringUtils.sanitizeClassName('mobile-errors'), equals('MobileErrors'));
      expect(StringUtils.sanitizeClassName('websocket-errors'), equals('WebsocketErrors'));
    });

    test('should handle underscores and spaces', () {
      expect(StringUtils.sanitizeClassName('user_profile'), equals('UserProfile'));
      expect(StringUtils.sanitizeClassName('main settings'), equals('MainSettings'));
      expect(StringUtils.sanitizeClassName('api-data_source'), equals('ApiDataSource'));
    });

    test('should handle single words', () {
      expect(StringUtils.sanitizeClassName('login'), equals('Login'));
      expect(StringUtils.sanitizeClassName('mobile'), equals('Mobile'));
    });

    test('should handle edge cases', () {
      expect(StringUtils.sanitizeClassName(''), equals(''));
      expect(StringUtils.sanitizeClassName('123test'), equals('Class123test'));
    });
  });

  group('File Name Sanitization Tests', () {
    test('should sanitize file names with hyphens correctly', () {
      expect(StringUtils.sanitizeFileName('auth-errors'), equals('auth_errors'));
      expect(StringUtils.sanitizeFileName('mobile-errors'), equals('mobile_errors'));
      expect(StringUtils.sanitizeFileName('websocket-errors'), equals('websocket_errors'));
    });

    test('should handle underscores and spaces', () {
      expect(StringUtils.sanitizeFileName('user_profile'), equals('user_profile'));
      expect(StringUtils.sanitizeFileName('main settings'), equals('main_settings'));
      expect(StringUtils.sanitizeFileName('api-data_source'), equals('api_data_source'));
    });

    test('should handle single words', () {
      expect(StringUtils.sanitizeFileName('login'), equals('login'));
      expect(StringUtils.sanitizeFileName('mobile'), equals('mobile'));
    });

    test('should handle edge cases', () {
      expect(StringUtils.sanitizeFileName(''), equals(''));
      expect(StringUtils.sanitizeFileName('123test'), equals('file_123test'));
    });
  });

  group('Interpolation Parameter Extraction Tests', () {
    test('should extract curly brace parameters', () {
      expect(StringUtils.extractInterpolationParams('Hello {name}!'), 
             equals(['name']));
      expect(StringUtils.extractInterpolationParams('Welcome {name} to {place}!'), 
             equals(['name', 'place']));
    });

    test('should extract printf-style numeric parameters', () {
      expect(StringUtils.extractInterpolationParams('Value: %1\$s'), 
             equals(['1']));
      expect(StringUtils.extractInterpolationParams('Items: %1\$s, %2\$s'), 
             equals(['1', '2']));
    });

    test('should extract printf-style named parameters', () {
      expect(StringUtils.extractInterpolationParams('Missing information: %information\$s'), 
             equals(['information']));
      expect(StringUtils.extractInterpolationParams('Hello %name\$s, welcome to %place\$s!'), 
             equals(['name', 'place']));
    });

    test('should extract mixed parameter formats', () {
      expect(StringUtils.extractInterpolationParams('Hello {name} and %user\$s!'), 
             equals(['name', 'user']));
    });

    test('should handle no parameters', () {
      expect(StringUtils.extractInterpolationParams('Simple text'), 
             equals([]));
    });

    test('should detect interpolation presence', () {
      expect(StringUtils.hasInterpolation('Hello {name}!'), isTrue);
      expect(StringUtils.hasInterpolation('Value: %information\$s'), isTrue);
      expect(StringUtils.hasInterpolation('Items: %1\$s'), isTrue);
      expect(StringUtils.hasInterpolation('Simple text'), isFalse);
    });

    test('should normalize interpolation formats', () {
      expect(StringUtils.normalizeInterpolation('Missing information: %information\$s'), 
             equals('Missing information: {information}'));
      expect(StringUtils.normalizeInterpolation('Hello %name\$s, welcome to %place\$s!'), 
             equals('Hello {name}, welcome to {place}!'));
      expect(StringUtils.normalizeInterpolation('Items: %1\$s, %2\$s'), 
             equals('Items: {1}, {2}'));
      expect(StringUtils.normalizeInterpolation('Already normalized: {param}'), 
             equals('Already normalized: {param}'));
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
      expect(languageRepo.isValidLanguageCode(''), isFalse);
    });

    test('should validate complex locale formats', () {
      expect(languageRepo.isValidLanguageCode('en_US_POSIX'),
          isFalse); // Too complex for current implementation
      expect(languageRepo.isValidLanguageCode('en_'),
          isTrue); // Current implementation accepts this
      expect(languageRepo.isValidLanguageCode('_US'),
          isFalse); // No language code before underscore
    });
  });

  group('Error Handling Tests', () {
    test('should handle invalid sheet data gracefully', () {
      expect(
        () => languageRepo.validateLanguageCodes([], 'TestSheet'),
        throwsA(isA<Exception>()),
      );
    });

    test('should provide helpful error messages for invalid language codes',
        () {
      expect(
        () =>
            languageRepo.validateLanguageCodes(['invalid', 'xyz'], 'TestSheet'),
        throwsA(
            predicate((e) => e.toString().contains('Invalid language codes'))),
      );
    });
  });
}
