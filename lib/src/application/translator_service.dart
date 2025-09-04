// Main translator service that orchestrates all use cases
import 'dart:io';
import '../domain/domain.dart';
import '../data/data.dart';

/// Main translator service that coordinates use cases and repositories
class TranslatorService {
  final ParseLocalizationFileUseCase _parseUseCase;
  final ValidateLanguageCodesUseCase _validateUseCase;
  final GenerateLocalizationClassesUseCase _generateUseCase;

  TranslatorService({
    required ParseLocalizationFileUseCase parseUseCase,
    required ValidateLanguageCodesUseCase validateUseCase,
    required GenerateLocalizationClassesUseCase generateUseCase,
  })  : _parseUseCase = parseUseCase,
        _validateUseCase = validateUseCase,
        _generateUseCase = generateUseCase;

  /// Factory constructor with default dependencies
  factory TranslatorService.create() {
    final fileParserRepository = FileParserRepositoryImpl();
    final languageValidationRepository = LanguageValidationRepositoryImpl();
    final codeGeneratorRepository = CodeGeneratorRepositoryImpl();

    return TranslatorService(
      parseUseCase: ParseLocalizationFileUseCase(fileParserRepository),
      validateUseCase: ValidateLanguageCodesUseCase(languageValidationRepository),
      generateUseCase: GenerateLocalizationClassesUseCase(codeGeneratorRepository),
    );
  }

  /// Generate localizations from a file
  Future<void> generateFromFile({
    required String filePath,
    required String outputDir,
    String className = 'AppLocalizations',
    bool includeFlutterDelegates = true,
  }) async {
    try {
      // Validate file exists
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File not found: $filePath');
      }

      print('📖 Parsing file: $filePath');
      
      // Parse the file
      final sheets = await _parseUseCase.execute(filePath);
      
      if (sheets.isEmpty) {
        throw Exception('No valid sheets found in file: $filePath');
      }

      print('✅ Found ${sheets.length} sheet(s)');

      // Validate language codes for all sheets
      for (final sheet in sheets) {
        _validateUseCase.executeForSheet(sheet.languageCodes, sheet.name);
      }

      print('🔧 Generating localization classes...');

      // Generate localization classes
      await _generateUseCase.execute(
        sheets: sheets,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates,
      );

      print('🎉 Successfully generated localization files in: $outputDir');
      
      // List generated files
      final outputDirectory = Directory(outputDir);
      if (outputDirectory.existsSync()) {
        final generatedFiles = outputDirectory
            .listSync()
            .where((file) => file.path.endsWith('.dart'))
            .map((file) => file.path.split('/').last)
            .toList();
        
        if (generatedFiles.isNotEmpty) {
          print('📄 Generated files:');
          for (final fileName in generatedFiles) {
            print('   - $fileName');
          }
        }
      }

    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Validate if a language code is valid
  bool isValidLanguageCode(String code) {
    return _validateUseCase.execute(code);
  }

  /// Get language name from code
  String getLanguageName(String code) {
    return _validateUseCase.getLanguageName(code);
  }
}
