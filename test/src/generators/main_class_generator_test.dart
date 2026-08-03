import 'package:excel_translator/src/generators/main_class_generator.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('MainClassGenerator locale resolution', () {
    final sheets = [buildTrickySheet()];

    test('emits resolveLanguage even without Flutter delegates', () {
      final source = MainClassGenerator().generateClassAndDelegate(
        sheets,
        'AppLocalizations',
        false,
      );

      expect(source, contains('static String? resolveLanguage(String languageTag)'));
      expect(source, isNot(contains('BuildContext')));
    });

    test('of(context) resolves the full locale, not just the language code', () {
      final source = MainClassGenerator().generateClassAndDelegate(
        sheets,
        'AppLocalizations',
        true,
      );

      expect(
        source,
        contains('resolveLanguage(locale.toLanguageTag()) ?? supportedLanguages.first'),
      );
      expect(source, isNot(contains('return AppLocalizations(locale.languageCode);')));
    });

    test('delegate accepts locales that only match a country variant', () {
      final source = MainClassGenerator().generateClassAndDelegate(
        sheets,
        'AppLocalizations',
        true,
      );

      expect(
        source,
        contains(
          'return AppLocalizations.resolveLanguage(locale.toLanguageTag()) != null;',
        ),
      );
      expect(
        source,
        isNot(contains('supportedLanguages.contains(locale.languageCode)')),
      );
    });

    test('supported languages keep the normalized sheet codes', () {
      final source = MainClassGenerator().generateClassAndDelegate(
        sheets,
        'AppLocalizations',
        false,
      );

      expect(source, contains("'en_us',"));
      expect(source, contains("'id',"));
    });
  });
}
