/// Repository contract for language validation
abstract class ILanguageValidationRepository {
  /// Check if language code is valid
  bool isValidLanguageCode(String code);

  /// Validate list of language codes
  void validateLanguageCodes(List<String> languageCodes, String sheetName);

  /// Get language name from code
  String getLanguageName(String code);

  /// Get all valid language codes
  Set<String> get validLanguageCodes;

  /// Get language names mapping
  Map<String, String> get languageNames;
}
