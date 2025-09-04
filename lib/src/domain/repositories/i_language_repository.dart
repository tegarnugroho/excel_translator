/// Repository contract for language data management
abstract class ILanguageRepository {
  /// Get all valid language codes
  Set<String> getValidLanguageCodes();
  
  /// Get language names mapping (code -> name)
  Map<String, String> getLanguageNames();
  
  /// Get language name for a specific code
  String getLanguageName(String code);
  
  /// Check if a language code is valid
  bool isValidLanguageCode(String code);
  
  /// Reload language data (useful for testing or config changes)
  Future<void> reload();
}
