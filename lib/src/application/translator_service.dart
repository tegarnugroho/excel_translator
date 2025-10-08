// Main translator service that orchestrates all use cases
import 'dart:io';
import '../core/core.dart';
import '../domain/domain.dart';
import '../data/data.dart' hide LocalizationSheet;

/// Main translator service that coordinates use cases and repositories
class TranslatorService {
  final ParseLocalizationFileUseCase _parseUseCase;
  final GenerateLocalizationClassesUseCase _generateUseCase;
  final LoadConfigurationUseCase _loadConfigUseCase;

  TranslatorService({
    required ParseLocalizationFileUseCase parseUseCase,
    required GenerateLocalizationClassesUseCase generateUseCase,
    required LoadConfigurationUseCase loadConfigUseCase,
  })  : _parseUseCase = parseUseCase,
        _generateUseCase = generateUseCase,
        _loadConfigUseCase = loadConfigUseCase;

  /// Factory constructor with default dependencies
  factory TranslatorService.create() {
    final languageValidationService = LanguageValidationService();
    final fileParserRepository = FileParserRepositoryImpl(
      languageValidationService: languageValidationService,
    );
    final codeGeneratorRepository = CodeGeneratorRepositoryImpl();
    final configRepository = ConfigRepositoryImpl();

    return TranslatorService(
      parseUseCase: ParseLocalizationFileUseCase(fileParserRepository),
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

      // All sheets should now have valid language codes since filtering is done during parsing
      if (sheets.isEmpty) {
        throw Exception('No valid sheets with proper language codes found in file: $filePath');
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
}
