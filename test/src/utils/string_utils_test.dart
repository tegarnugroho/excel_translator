import 'package:test/test.dart';
import '../../../lib/src/utils/string_utils.dart';

void main() {
  group('StringUtils Tests', () {
    group('interpolation parameter sanitization', () {
      test('should convert underscore parameters to camelCase', () {
        expect(StringUtils.sanitizeInterpolationParam('user_name'), equals('userName'));
        expect(StringUtils.sanitizeInterpolationParam('first_name'), equals('firstName'));
        expect(StringUtils.sanitizeInterpolationParam('user_id'), equals('userId'));
      });

      test('should convert kebab-case parameters to camelCase', () {
        expect(StringUtils.sanitizeInterpolationParam('user-name'), equals('userName'));
        expect(StringUtils.sanitizeInterpolationParam('first-name'), equals('firstName'));
      });

      test('should keep simple parameters unchanged', () {
        expect(StringUtils.sanitizeInterpolationParam('name'), equals('name'));
        expect(StringUtils.sanitizeInterpolationParam('id'), equals('id'));
        expect(StringUtils.sanitizeInterpolationParam('userName'), equals('userName'));
      });

      test('should keep numeric parameters unchanged', () {
        expect(StringUtils.sanitizeInterpolationParam('1'), equals('1'));
        expect(StringUtils.sanitizeInterpolationParam('123'), equals('123'));
      });

      test('should handle empty string', () {
        expect(StringUtils.sanitizeInterpolationParam(''), equals(''));
      });
    });

    group('extractInterpolationParams', () {
      test('should extract curly brace format parameters', () {
        final params = StringUtils.extractInterpolationParams('Hello {name}');
        expect(params, contains('name'));
      });

      test('should extract and sanitize underscore parameters', () {
        final params = StringUtils.extractInterpolationParams('Welcome {user_name}!');
        expect(params, contains('userName'));
        expect(params, isNot(contains('user_name')));
      });

      test('should extract printf-style parameters', () {
        final params = StringUtils.extractInterpolationParams('Hello %name\$s');
        expect(params, contains('name'));
      });

      test('should extract multiple parameters', () {
        final params = StringUtils.extractInterpolationParams(
          'Hello {user_name}, your ID is {user_id}',
        );
        expect(params.length, equals(2));
        expect(params, contains('userName'));
        expect(params, contains('userId'));
      });

      test('should handle mixed parameter styles', () {
        final params = StringUtils.extractInterpolationParams(
          'User {user_name} has ID %user_id\$s',
        );
        expect(params, contains('userName'));
        expect(params, contains('userId'));
      });

      test('should return empty list for no parameters', () {
        final params = StringUtils.extractInterpolationParams('Hello world');
        expect(params, isEmpty);
      });
    });

    group('normalizeInterpolation', () {
      test('should normalize underscore parameters in curly braces', () {
        final result = StringUtils.normalizeInterpolation('Hello {user_name}');
        expect(result, contains('{userName}'));
        expect(result, isNot(contains('{user_name}')));
      });

      test('should convert printf-style to camelCase curly braces', () {
        final result = StringUtils.normalizeInterpolation('Hello %user_name\$s');
        expect(result, equals('Hello {userName}'));
      });

      test('should preserve simple parameters', () {
        final result = StringUtils.normalizeInterpolation('Hello {name}');
        expect(result, equals('Hello {name}'));
      });

      test('should handle multiple parameters', () {
        final result = StringUtils.normalizeInterpolation(
          'Hello {user_name}, welcome to {app_name}!',
        );
        expect(result, contains('{userName}'));
        expect(result, contains('{appName}'));
        expect(result, isNot(contains('{user_name}')));
        expect(result, isNot(contains('{app_name}')));
      });

      test('should handle mixed printf and curly brace styles', () {
        final result = StringUtils.normalizeInterpolation(
          'User %user_name\$s has ID {user_id}',
        );
        expect(result, equals('User {userName} has ID {userId}'));
      });
    });

    group('toCamelCase', () {
      test('should convert snake_case to camelCase', () {
        expect(StringUtils.toCamelCase('user_name'), equals('userName'));
        expect(StringUtils.toCamelCase('first_name_last'), equals('firstNameLast'));
      });

      test('should convert kebab-case to camelCase', () {
        expect(StringUtils.toCamelCase('user-name'), equals('userName'));
        expect(StringUtils.toCamelCase('first-name-last'), equals('firstNameLast'));
      });

      test('should handle simple strings', () {
        expect(StringUtils.toCamelCase('name'), equals('name'));
        expect(StringUtils.toCamelCase('ID'), equals('id'));
      });

      test('should handle empty string', () {
        expect(StringUtils.toCamelCase(''), equals(''));
      });
    });

    group('sanitizeMethodName', () {
      test('should convert snake_case keys to camelCase', () {
        expect(
          StringUtils.sanitizeMethodName('welcome_message'),
          equals('welcomeMessage'),
        );
        expect(
          StringUtils.sanitizeMethodName('user_login_title'),
          equals('userLoginTitle'),
        );
      });

      test('should handle simple keys', () {
        expect(StringUtils.sanitizeMethodName('title'), equals('title'));
        expect(StringUtils.sanitizeMethodName('hello'), equals('hello'));
      });

      test('should reject empty keys', () {
        expect(StringUtils.sanitizeMethodName(''), equals(''));
      });
    });

    group('hasInterpolation', () {
      test('should detect curly brace interpolation', () {
        expect(StringUtils.hasInterpolation('Hello {name}'), isTrue);
      });

      test('should detect printf-style interpolation', () {
        expect(StringUtils.hasInterpolation('Hello %name\$s'), isTrue);
      });

      test('should detect underscore params', () {
        expect(StringUtils.hasInterpolation('Hello {user_name}'), isTrue);
      });

      test('should return false for no interpolation', () {
        expect(StringUtils.hasInterpolation('Hello world'), isFalse);
      });
    });
  });
}
