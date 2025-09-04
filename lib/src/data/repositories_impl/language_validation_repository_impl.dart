// Implementation of language validation repository
import '../../domain/repositories/repositories.dart';
import '../lang/language_data.dart';

/// Implementation of language validation repository
class LanguageValidationRepositoryImpl implements ILanguageValidationRepository {
  @override
  bool isValidLanguageCode(String code) {
    final normalizedCode = code.toLowerCase().trim();

    // Check exact match with ISO 639-1 codes
    if (LanguageData.validLanguageCodes.contains(normalizedCode)) {
      return true;
    }

    // Check if it's a locale format like 'en_US', 'pt_BR' (underscore format)
    if (normalizedCode.contains('_')) {
      final parts = normalizedCode.split('_');
      if (parts.length == 2 &&
          LanguageData.validLanguageCodes.contains(parts[0])) {
        return true;
      }
    }

    // Check if it's a locale format like 'en-US', 'pt-BR' (dash format - backward compatibility)
    if (normalizedCode.contains('-')) {
      final parts = normalizedCode.split('-');
      if (parts.length == 2 &&
          LanguageData.validLanguageCodes.contains(parts[0])) {
        return true;
      }
    }

    return false;
  }

  @override
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

  @override
  String getLanguageName(String code) {
    return LanguageData.languageNames[code.toLowerCase()] ?? code.toLowerCase();
  }

  @override
  Set<String> get validLanguageCodes => LanguageData.validLanguageCodes;

  @override
  Map<String, String> get languageNames => LanguageData.languageNames;
}
