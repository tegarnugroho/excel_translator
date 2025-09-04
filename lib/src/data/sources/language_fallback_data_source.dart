// Fallback data source for language information
/// Provides fallback language data when JSON file is not available
class LanguageFallbackDataSource {
  /// Get fallback language codes
  static Set<String> getFallbackLanguageCodes() {
    return {
      'en',
      'id',
      'es',
      'fr',
      'de',
      'pt',
      'zh',
      'ja',
      'ko',
      'ar',
      'hi',
      'ru',
      'it',
      'nl',
      'pl',
      'tr',
      'sv',
      'da',
      'no',
      'fi',
      'he',
      'th',
      'vi',
      'uk'
    };
  }

  /// Get fallback language names mapping
  static Map<String, String> getFallbackLanguageNames() {
    return {
      'en': 'english',
      'id': 'indonesian',
      'es': 'spanish',
      'fr': 'french',
      'de': 'german',
      'pt': 'portuguese',
      'zh': 'chinese',
      'ja': 'japanese',
      'ko': 'korean',
      'ar': 'arabic',
      'hi': 'hindi',
      'ru': 'russian',
      'it': 'italian',
      'nl': 'dutch',
      'pl': 'polish',
      'tr': 'turkish',
      'sv': 'swedish',
      'da': 'danish',
      'no': 'norwegian',
      'fi': 'finnish',
      'he': 'hebrew',
      'th': 'thai',
      'vi': 'vietnamese',
      'uk': 'ukrainian'
    };
  }
}
