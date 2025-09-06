import 'package:test/test.dart';
import '../../../../lib/src/data/sources/language_fallback_data_source.dart';

void main() {
  group('LanguageFallbackDataSource Tests', () {
    test('should provide fallback language codes', () {
      final codes = LanguageFallbackDataSource.getFallbackLanguageCodes();

      expect(codes, isNotEmpty);
      expect(codes, isA<Set<String>>());
      expect(codes, contains('en'));
      expect(codes, contains('id'));
      expect(codes, contains('es'));
      expect(codes, contains('fr'));
      expect(codes, contains('de'));
    });

    test('should provide fallback language names mapping', () {
      final names = LanguageFallbackDataSource.getFallbackLanguageNames();

      expect(names, isNotEmpty);
      expect(names, isA<Map<String, String>>());
      expect(names['en'], equals('english'));
      expect(names['id'], equals('indonesian'));
      expect(names['es'], equals('spanish'));
      expect(names['fr'], equals('french'));
      expect(names['de'], equals('german'));
    });

    test('should have consistent data between codes and names', () {
      final codes = LanguageFallbackDataSource.getFallbackLanguageCodes();
      final names = LanguageFallbackDataSource.getFallbackLanguageNames();

      // Every code should have a corresponding name
      for (final code in codes) {
        expect(names.containsKey(code), isTrue,
            reason: 'Language code "$code" should have a corresponding name');
      }

      // Every name key should be in the codes set
      for (final code in names.keys) {
        expect(codes.contains(code), isTrue,
            reason: 'Name key "$code" should be in the language codes set');
      }
    });

    test('should provide non-empty language names', () {
      final names = LanguageFallbackDataSource.getFallbackLanguageNames();

      for (final entry in names.entries) {
        expect(entry.value, isNotEmpty,
            reason: 'Language name for "${entry.key}" should not be empty');
      }
    });

    test('should provide at least common languages', () {
      final codes = LanguageFallbackDataSource.getFallbackLanguageCodes();
      final names = LanguageFallbackDataSource.getFallbackLanguageNames();

      // Test for some common languages
      final commonLanguages = [
        'en',
        'es',
        'fr',
        'de',
        'it',
        'pt',
        'zh',
        'ja',
        'ko',
        'ru'
      ];

      for (final lang in commonLanguages) {
        expect(codes.contains(lang), isTrue,
            reason: 'Should contain common language code: $lang');
        expect(names.containsKey(lang), isTrue,
            reason: 'Should contain name for common language: $lang');
      }
    });

    test('should provide immutable data structures', () {
      final codes1 = LanguageFallbackDataSource.getFallbackLanguageCodes();
      final codes2 = LanguageFallbackDataSource.getFallbackLanguageCodes();
      final names1 = LanguageFallbackDataSource.getFallbackLanguageNames();
      final names2 = LanguageFallbackDataSource.getFallbackLanguageNames();

      // Should be separate instances but with same content
      expect(identical(codes1, codes2), isFalse);
      expect(identical(names1, names2), isFalse);
      expect(codes1, equals(codes2));
      expect(names1, equals(names2));
    });

    test('should provide reasonable number of languages', () {
      final codes = LanguageFallbackDataSource.getFallbackLanguageCodes();
      final names = LanguageFallbackDataSource.getFallbackLanguageNames();

      // Should have a reasonable number of languages (not too few, not too many)
      expect(codes.length, greaterThan(10));
      expect(codes.length, lessThan(100));
      expect(names.length, equals(codes.length));
    });
  });
}
