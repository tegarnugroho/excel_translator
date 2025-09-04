// Main generator for Excel Translator
import '../application/translator_service.dart';

/// Main class for generating localizations from various file formats
/// This is a legacy wrapper that delegates to the new TranslatorService
class LocalizationsGenerator {
  static final _service = TranslatorService.create();

  /// Generate localizations from a file (Excel .xlsx, CSV .csv, or ODS .ods)
  static Future<void> generateFromFile({
    required String filePath,
    required String outputDir,
    String className = 'AppLocalizations',
    bool includeFlutterDelegates = true,
  }) async {
    await _service.generateFromFile(
      filePath: filePath,
      outputDir: outputDir,
      className: className,
      includeFlutterDelegates: includeFlutterDelegates,
    );
  }

  /// Legacy method for backward compatibility
  /// Use [generateFromFile] instead
  @Deprecated('Use generateFromFile instead')
  static Future<void> generateFromExcel({
    required String excelFilePath,
    required String outputDir,
    String className = 'AppLocalizations',
    bool includeFlutterDelegates = true,
  }) async {
    return generateFromFile(
      filePath: excelFilePath,
      outputDir: outputDir,
      className: className,
      includeFlutterDelegates: includeFlutterDelegates,
    );
  }

  /// Validate if a language code is valid
  static bool isValidLanguageCode(String code) {
    return _service.isValidLanguageCode(code);
  }

  /// Validate language codes and throw exception if invalid
  static void validateLanguageCodes(List<String> languageCodes, String sheetName) {
    // This will be handled by the use case internally
    for (final code in languageCodes) {
      if (!_service.isValidLanguageCode(code)) {
        throw Exception('Invalid language code: $code in sheet: $sheetName');
      }
    }
  }
}
