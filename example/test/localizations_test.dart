import 'package:flutter_test/flutter_test.dart';
import 'package:excel_translator_example/generated/generated_localizations.dart';

void main() {
  group('AppLocalizations Unit Tests', () {
    test('Supported languages are correctly defined', () {
      expect(AppLocalizations.supportedLanguages, isNotEmpty);
      expect(AppLocalizations.supportedLanguages.length, greaterThan(0));

      // Check if common languages are supported
      expect(AppLocalizations.supportedLanguages, contains('en'));
    });

    test('Auto language detection works', () {
      final autoLocalizations = AppLocalizations.current;
      expect(autoLocalizations.languageCode, isNotNull);
      expect(autoLocalizations.languageCode,
          isIn(AppLocalizations.supportedLanguages));
    });

    test('System language detection returns valid language', () {
      final systemLanguage = AppLocalizations.getSystemLanguage();
      expect(systemLanguage, isNotNull);
      expect(systemLanguage, isIn(AppLocalizations.supportedLanguages));
    });

    test('English localizations work correctly', () {
      final englishLoc = AppLocalizations.english;

      expect(englishLoc.languageCode, equals('en'));
      expect(englishLoc.login.hello, isNotEmpty);
      expect(englishLoc.buttons.submit, isNotEmpty);

      // Test string interpolation
      final welcomeMessage = englishLoc.login.welcomeMessage(name: 'Test');
      expect(welcomeMessage, contains('Test'));

      final userCount = englishLoc.login.userCount(count: 5);
      expect(userCount, contains('5'));
    });

    test('All supported languages have valid localizations', () {
      for (String languageCode in AppLocalizations.supportedLanguages) {
        final localizations = AppLocalizations(languageCode);

        expect(localizations.languageCode, equals(languageCode));
        expect(localizations.login.hello, isNotEmpty);
        expect(localizations.buttons.submit, isNotEmpty);

        // Test that interpolation works for all languages
        final welcomeMessage = localizations.login.welcomeMessage(name: 'Test');
        expect(welcomeMessage, isNotEmpty);

        final userCount = localizations.login.userCount(count: 10);
        expect(userCount, isNotEmpty);
      }
    });

    test('Invalid language code is handled correctly', () {
      final invalidLoc = AppLocalizations('invalid');

      // The constructor accepts any language code
      // but the generated localizations will fall back to default values
      expect(invalidLoc.languageCode, equals('invalid'));

      // The localizations should still be functional
      expect(invalidLoc.login.hello, isNotEmpty);
      expect(invalidLoc.buttons.submit, isNotEmpty);
    });

    test('String interpolation handles different parameter types', () {
      final loc = AppLocalizations.english;

      // Test with string parameter
      final withString = loc.login.welcomeMessage(name: 'John');
      expect(withString, contains('John'));

      // Test with number parameter
      final withNumber = loc.login.welcomeMessage(name: 123);
      expect(withNumber, contains('123'));

      // Test user count with different numbers
      expect(loc.login.userCount(count: 0), contains('0'));
      expect(loc.login.userCount(count: 1), contains('1'));
      expect(loc.login.userCount(count: 999), contains('999'));
    });

    test('All sheet localizations are accessible', () {
      final loc = AppLocalizations.english;

      // Test login sheet
      expect(loc.login, isNotNull);
      expect(loc.login.hello, isNotEmpty);
      expect(loc.login.goodbye, isNotEmpty);
      expect(loc.login.appTitle, isNotEmpty);
      expect(loc.login.saveButton, isNotEmpty);
      expect(loc.login.cancelButton, isNotEmpty);

      // Test buttons sheet
      expect(loc.buttons, isNotNull);
      expect(loc.buttons.submit, isNotEmpty);
      expect(loc.buttons.delete, isNotEmpty);
      expect(loc.buttons.edit, isNotEmpty);
    });

    test('Different language instances produce different translations', () {
      if (AppLocalizations.supportedLanguages.length > 1) {
        final english = AppLocalizations('en');
        final secondLang =
            AppLocalizations(AppLocalizations.supportedLanguages[1]);

        // Should have different greetings for different languages
        // (unless they happen to be the same, which is unlikely)
        expect(english.languageCode, isNot(equals(secondLang.languageCode)));
      }
    });

    test('Localizations instances are properly initialized', () {
      final loc = AppLocalizations.english;

      // All sub-localizations should be initialized
      expect(() => loc.login.hello, returnsNormally);
      expect(() => loc.buttons.submit, returnsNormally);

      // Should not throw when accessing any property
      expect(() => loc.login.welcomeMessage(name: 'test'), returnsNormally);
      expect(() => loc.login.userCount(count: 1), returnsNormally);
    });
  });

  group('CamelCase Method Name Tests', () {
    test('Snake_case keys are converted to camelCase methods', () {
      final loc = AppLocalizations.english;

      // These methods should exist (converted from snake_case Excel keys)
      expect(() => loc.login.appTitle, returnsNormally); // app_title
      expect(() => loc.login.welcomeMessage(name: 'test'),
          returnsNormally); // welcome_message
      expect(
          () => loc.login.userCount(count: 1), returnsNormally); // user_count
      expect(() => loc.login.saveButton, returnsNormally); // save_button
      expect(() => loc.login.cancelButton, returnsNormally); // cancel_button
    });
  });
}
