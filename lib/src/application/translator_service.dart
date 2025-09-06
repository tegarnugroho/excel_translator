// Main translator service that orchestrates all use cases
import 'dart:io';
import '../domain/domain.dart';
import '../data/data.dart';

/// Main translator service that coordinates use cases and repositories
class TranslatorService {
  final ParseLocalizationFileUseCase _parseUseCase;
  final ValidateLanguageCodesUseCase _validateUseCase;
  final GenerateLocalizationClassesUseCase _generateUseCase;
  final LoadConfigurationUseCase _loadConfigUseCase;

  TranslatorService({
    required ParseLocalizationFileUseCase parseUseCase,
    required ValidateLanguageCodesUseCase validateUseCase,
    required GenerateLocalizationClassesUseCase generateUseCase,
    required LoadConfigurationUseCase loadConfigUseCase,
  })  : _parseUseCase = parseUseCase,
        _validateUseCase = validateUseCase,
        _generateUseCase = generateUseCase,
        _loadConfigUseCase = loadConfigUseCase;

  /// Factory constructor with default dependencies
  factory TranslatorService.create() {
    final fileParserRepository = FileParserRepositoryImpl();
    final languageValidationRepository = LanguageValidationRepositoryImpl();
    final codeGeneratorRepository = CodeGeneratorRepositoryImpl();
    final configRepository = ConfigRepositoryImpl();

    return TranslatorService(
      parseUseCase: ParseLocalizationFileUseCase(fileParserRepository),
      validateUseCase:
          ValidateLanguageCodesUseCase(languageValidationRepository),
      generateUseCase:
          GenerateLocalizationClassesUseCase(codeGeneratorRepository),
      loadConfigUseCase: LoadConfigurationUseCase(configRepository),
    );
  }

  /// Generate localizations from a file
  Future<void> generateFromFile({
    required String filePath,
    required String outputDir,
    String? className,
    bool? includeFlutterDelegates,
    String? pubspecPath,
  }) async {
    try {
      // Load configuration with proper merging
      final config = _loadConfigUseCase.execute(
        excelFilePath: filePath,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates,
        pubspecPath: pubspecPath,
      );

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

      // Generate localization classes using merged configuration
      await _generateUseCase.execute(
        sheets: sheets,
        outputDir: config.outputDir ?? outputDir,
        className: config.className ?? 'AppLocalizations',
        includeFlutterDelegates: config.includeFlutterDelegates,
      );

      final finalOutputDir = config.outputDir ?? outputDir;
      print('🎉 Successfully generated localization files in: $finalOutputDir');

      // List generated files
      final outputDirectory = Directory(finalOutputDir);
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
