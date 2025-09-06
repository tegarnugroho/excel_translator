import '../repositories/repositories.dart';

/// Use case for validating language codes
class ValidateLanguageCodesUseCase {
  final ILanguageValidationRepository _languageValidationRepository;

  const ValidateLanguageCodesUseCase(this._languageValidationRepository);

  /// Execute validation for a single language code
  bool execute(String languageCode) {
    return _languageValidationRepository.isValidLanguageCode(languageCode);
  }

  /// Execute validation for multiple language codes
  void executeForSheet(List<String> languageCodes, String sheetName) {
    _languageValidationRepository.validateLanguageCodes(
        languageCodes, sheetName);
  }

  /// Get language name
  String getLanguageName(String code) {
    return _languageValidationRepository.getLanguageName(code);
  }
}
