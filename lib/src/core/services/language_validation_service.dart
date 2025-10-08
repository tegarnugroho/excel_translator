import '../../domain/repositories/repositories.dart';
import '../../data/repositories_impl/language_repository_impl.dart';

/// Service for language code validation
class LanguageValidationService {
  final ILanguageRepository _languageRepository;

  LanguageValidationService({
    ILanguageRepository? languageRepository,
  }) : _languageRepository = languageRepository ?? LanguageRepositoryImpl();

  /// Check if language code is valid
  bool isValidLanguageCode(String code) {
    final normalizedCode = code.toLowerCase().trim();

    // Check exact match with ISO 639-1 codes
    if (_languageRepository.getValidLanguageCodes().contains(normalizedCode)) {
      return true;
    }

    // Check if it's a locale format like 'en_US', 'pt_BR' (underscore format)
    if (normalizedCode.contains('_')) {
      final parts = normalizedCode.split('_');
      if (parts.length == 2 &&
          _languageRepository.getValidLanguageCodes().contains(parts[0])) {
        return true;
      }
    }

    // Check if it's a locale format like 'en-US', 'pt-BR' (dash format - backward compatibility)
    if (normalizedCode.contains('-')) {
      final parts = normalizedCode.split('-');
      if (parts.length == 2 &&
          _languageRepository.getValidLanguageCodes().contains(parts[0])) {
        return true;
      }
    }

    return false;
  }

  /// Validate list of language codes (throws exception if invalid)
  void validateLanguageCodes(List<String> languageCodes, String sheetName) {
    if (languageCodes.isEmpty) {
      throw Exception(
          'Sheet "$sheetName": No language codes found in header row.\n'
          'Please ensure the first row contains valid language codes (e.g., en, id, es).');
    }

    final invalidCodes = <String>[];
    for (final code in languageCodes) {
      if (!isValidLanguageCode(code)) {
        invalidCodes.add(code);
      }
    }

    if (invalidCodes.isNotEmpty) {
      throw Exception(
          'Sheet "$sheetName": Invalid language codes found in header: ${invalidCodes.join(', ')}\n'
          'Valid language codes are ISO 639-1 codes like: en, id, es, fr, de, pt, etc.\n'
          'You can also use locale formats like: en_US, pt_BR, zh_CN (preferred) or en-US, pt-BR, zh-CN');
    }

    print(
        '✅ Sheet "$sheetName": Valid language codes found: ${languageCodes.join(', ')}');
  }

  /// Filter out invalid language codes and return only valid ones with their indices
  /// Returns a map of valid language codes with their original column indices
  Map<String, int> filterValidLanguageCodes(List<String> languageCodes, String sheetName) {
    final validCodesWithIndices = <String, int>{};
    final invalidCodes = <String>[];

    for (int i = 0; i < languageCodes.length; i++) {
      final code = languageCodes[i];
      if (isValidLanguageCode(code)) {
        validCodesWithIndices[code] = i;
      } else {
        invalidCodes.add(code);
      }
    }

    if (invalidCodes.isNotEmpty) {
      print('⚠️  Sheet "$sheetName": Skipping invalid language code columns: ${invalidCodes.join(', ')}');
      print('   Valid language codes are ISO 639-1 codes like: en, id, es, fr, de, pt, etc.');
      print('   You can also use locale formats like: en_US, pt_BR, zh_CN (preferred) or en-US, pt-BR, zh-CN');
    }

    if (validCodesWithIndices.isNotEmpty) {
      print('✅ Sheet "$sheetName": Processing valid language codes: ${validCodesWithIndices.keys.join(', ')}');
    }

    return validCodesWithIndices;
  }

  /// Get language name from code
  String getLanguageName(String code) {
    return _languageRepository.getLanguageName(code);
  }

  /// Get all valid language codes
  Set<String> get validLanguageCodes =>
      _languageRepository.getValidLanguageCodes();

  /// Get language names mapping
  Map<String, String> get languageNames =>
      _languageRepository.getLanguageNames();
}