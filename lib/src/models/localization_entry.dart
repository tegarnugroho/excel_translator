// Models for Excel Translator
class LocalizationEntry {
  final String key;
  final Map<String, String> translations;

  const LocalizationEntry({
    required this.key,
    required this.translations,
  });

  @override
  String toString() {
    return 'LocalizationEntry(key: $key, translations: $translations)';
  }
}