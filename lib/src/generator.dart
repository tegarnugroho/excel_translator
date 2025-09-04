// Main generator for Excel Translator
import 'dart:io';
import 'models/models.dart';
import 'parsers/file_parser.dart';
import 'validators/language_validator.dart';
import 'code_generators/main_class_generator.dart';
import 'code_generators/sheet_class_generator.dart';
import 'code_generators/extension_generator.dart';

/// Main class for generating localizations from various file formats
class LocalizationsGenerator {
  /// Generate localizations from a file (Excel .xlsx, CSV .csv, or ODS .ods)
  static Future<void> generateFromFile({
    required String filePath,
    required String outputDir,
    String className = 'AppLocalizations',
    bool includeFlutterDelegates = true,
  }) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found: $filePath');
      }

      // Use the file parser factory to handle different formats
      final parser = FileParserFactory.createParser(filePath);
      final sheets = parser.parseFile(filePath);

      // Validate language codes for all sheets
      for (final sheet in sheets) {
        LanguageValidator.validateLanguageCodes(sheet.languageCodes, sheet.name);
      }

      await _generateDartFiles(
          sheets, outputDir, className, includeFlutterDelegates);

      print('✅ Localizations generated successfully!');
      print('📁 Output directory: $outputDir');
      print('📊 Generated ${sheets.length} sheet(s)');
      for (final sheet in sheets) {
        print('  - ${sheet.name}: ${sheet.entries.length} keys');
      }
    } catch (e) {
      print('❌ Error generating localizations: $e');
      print('❌ Generation failed: $e');
      rethrow;
    }
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

  // Private helper method
  static Future<void> _generateDartFiles(
    List<LocalizationSheet> sheets,
    String outputDir,
    String className,
    bool includeFlutterDelegates,
  ) async {
    final outputDirectory = Directory(outputDir);
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    // Generate main localizations class
    await MainClassGenerator.generate(
        sheets, outputDir, className, includeFlutterDelegates);

    // Generate individual sheet classes
    for (final sheet in sheets) {
      await SheetClassGenerator.generate(sheet, outputDir);
    }

    // Generate BuildContext extension
    await ExtensionGenerator.generate(sheets, outputDir, className);
  }

  // Public methods for testing and backward compatibility
  static bool isValidLanguageCode(String code) {
    return LanguageValidator.isValidLanguageCode(code);
  }

  static void validateLanguageCodes(
      List<String> languageCodes, String sheetName) {
    LanguageValidator.validateLanguageCodes(languageCodes, sheetName);
  }
}
