import 'dart:io';
import 'models/models.dart';
import 'services/services.dart';
import 'parsers/parsers.dart';
import 'generators/generators.dart';
import 'utils/utils.dart';

/// Main translator service that orchestrates the translation generation process
class TranslatorService {
  final ConfigService _configService;
  final LanguageService _languageService;
  final MainClassGenerator _mainGenerator;
  final SheetClassGenerator _sheetGenerator;
  final ExtensionGenerator _extensionGenerator;

  TranslatorService({
    ConfigService? configService,
    LanguageService? languageService,
    MainClassGenerator? mainGenerator,
    SheetClassGenerator? sheetGenerator,
    ExtensionGenerator? extensionGenerator,
  }) : _configService = configService ?? ConfigService(),
       _languageService = languageService ?? LanguageService(),
       _mainGenerator = mainGenerator ?? MainClassGenerator(),
       _sheetGenerator = sheetGenerator ?? SheetClassGenerator(),
       _extensionGenerator = extensionGenerator ?? ExtensionGenerator();

  /// Factory constructor with default dependencies
  factory TranslatorService.create() {
    return TranslatorService();
  }

  /// Generate localizations from a file
  Future<void> generateFromFile({
    required String filePath,
    required String outputDir,
    String? className,
    bool? includeFlutterDelegates,
    bool? multiFile,
    String? pubspecPath,
  }) async {
    try {
      // Load configuration with proper merging
      final config = _configService.loadConfiguration(
        excelFilePath: filePath,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates,
        multiFile: multiFile,
        pubspecPath: pubspecPath,
      );

      // Validate required parameters
      final finalFilePath = config.excelFilePath ?? filePath;
      final finalOutputDir = config.outputDir ?? outputDir;
      final finalClassName = config.className ?? 'AppLocalizations';
      final finalIncludeDelegates = config.includeFlutterDelegates ?? true;
      final finalMultiFile = config.multiFile ?? true;

      if (finalFilePath.isEmpty) {
        throw Exception('Excel file path is required');
      }

      if (finalOutputDir.isEmpty) {
        throw Exception('Output directory is required');
      }

      Logger.info('Starting localization generation...');
      Logger.info('File: $finalFilePath');
      Logger.info('Output: $finalOutputDir');
      Logger.info('Class: $finalClassName');

      // Check if file exists
      if (!File(finalFilePath).existsSync()) {
        throw Exception('File not found: $finalFilePath');
      }

      // Check if file format is supported
      if (!FileParserFactory.isSupportedFormat(finalFilePath)) {
        throw UnsupportedFileFormatException(
          finalFilePath,
          FileParserFactory.supportedExtensions,
        );
      }

      // Parse file
      Logger.progress('Parsing file...');
      final parser = FileParserFactory.createParser(finalFilePath);
      final sheets = await parser.parseFile(
        finalFilePath,
        languageService: _languageService,
      );

      if (sheets.isEmpty) {
        throw Exception('No sheets found in file or all sheets are empty');
      }

      Logger.success('Parsed ${sheets.length} sheet(s)');

      // Generate code
      Logger.progress('Generating localization classes...');
      await _generateClasses(
        sheets: sheets,
        outputDir: finalOutputDir,
        className: finalClassName,
        includeFlutterDelegates: finalIncludeDelegates,
        multiFile: finalMultiFile,
      );

      Logger.success(
        'Generated localization classes in $finalOutputDir successfully!',
      );
    } catch (e, stackTrace) {
      Logger.error('Generation failed', e, stackTrace);
      rethrow;
    }
  }

  /// Generate from pubspec configuration only
  Future<void> generateFromPubspec([String? pubspecPath]) async {
    final config = _configService.loadFromPubspec(pubspecPath);

    if (config == null ||
        config.excelFilePath == null ||
        config.outputDir == null) {
      throw Exception(
        'Configuration not found in pubspec.yaml. Please add excel_translator section with excel_file and output_dir',
      );
    }

    await generateFromFile(
      filePath: config.excelFilePath!,
      outputDir: config.outputDir!,
      className: config.className,
      includeFlutterDelegates: config.includeFlutterDelegates ?? true,
      pubspecPath: pubspecPath,
    );
  }

  // Private helper methods

  Future<void> _generateClasses({
    required List<LocalizationSheet> sheets,
    required String outputDir,
    required String className,
    required bool includeFlutterDelegates,
    required bool multiFile,
  }) async {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    if (multiFile) {
      for (final sheet in sheets) {
        await _sheetGenerator.generateSheetClass(sheet, outputDir);
      }
      await _mainGenerator.generateMainClass(
        sheets,
        outputDir,
        className,
        includeFlutterDelegates,
      );
    } else {
      // Single-file mode: everything inline in generated_localizations.dart
      final buffer = StringBuffer();
      buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
      buffer.writeln('// Generated by Excel Translator');
      buffer.writeln();
      if (includeFlutterDelegates) {
        buffer.writeln("import 'package:flutter/material.dart';");
        buffer.writeln("import 'package:flutter/cupertino.dart';");
        buffer.writeln(
          "import 'package:excel_translator/excel_translator.dart';",
        );
        buffer.writeln("import 'dart:ui' show PlatformDispatcher;");
        buffer.writeln();
      }
      for (final sheet in sheets) {
        buffer.write(_sheetGenerator.generateClassBody(sheet));
        buffer.writeln();
      }
      buffer.write(
        _mainGenerator.generateClassAndDelegate(
          sheets,
          className,
          includeFlutterDelegates,
        ),
      );
      final file = File('$outputDir/generated_localizations.dart');
      await file.writeAsString(buffer.toString());
    }

    await _extensionGenerator.generateBuildContextExtension(
      outputDir,
      className,
    );
  }
}
