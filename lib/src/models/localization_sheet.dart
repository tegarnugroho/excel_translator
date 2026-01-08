import 'translation.dart';
import 'language.dart';

/// Represents a sheet of localizations with translations and supported languages
class LocalizationSheet {
  final String name;
  final List<Translation> translations;
  final List<Language> supportedLanguages;

  const LocalizationSheet({
    required this.name,
    required this.translations,
    required this.supportedLanguages,
  });

  /// Get all language codes supported by this sheet
  List<String> get languageCodes {
    return supportedLanguages.map((lang) => lang.fullCode).toList();
  }

  /// Get translation by key
  Translation? getTranslation(String key) {
    try {
      return translations.firstWhere((t) => t.key == key);
    } catch (e) {
      return null;
    }
  }

  /// Get value for specific key and language
  String? getValue(String key, String languageCode) {
    final translation = getTranslation(key);
    return translation?.values[languageCode];
  }

  /// Check if sheet contains a specific translation key
  bool hasKey(String key) {
    return translations.any((t) => t.key == key);
  }

  /// Check if sheet supports a specific language
  bool supportsLanguage(String languageCode) {
    return supportedLanguages.any((lang) => lang.fullCode == languageCode);
  }

  LocalizationSheet copyWith({
    String? name,
    List<Translation>? translations,
    List<Language>? supportedLanguages,
  }) {
    return LocalizationSheet(
      name: name ?? this.name,
      translations: translations ?? this.translations,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
    );
  }

  @override
  String toString() {
    return 'LocalizationSheet(name: $name, translations: ${translations.length}, languages: ${languageCodes.join(', ')})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocalizationSheet &&
        other.name == name &&
        _listEquals(other.translations, translations) &&
        _listEquals(other.supportedLanguages, supportedLanguages);
  }

  @override
  int get hashCode =>
      name.hashCode ^ translations.hashCode ^ supportedLanguages.hashCode;

  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
