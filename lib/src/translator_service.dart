import 'dart:io';
import 'models/models.dart';
import 'services/services.dart';
import 'generators/generators.dart';
import 'utils/utils.dart';

/// Main translator service that orchestrates the translation generation process
class TranslatorService {
  final ConfigService _configService;
  final LanguageService _languageService;
  final TranslationInputService _inputService;
  final MainClassGenerator _mainGenerator;
  final SheetClassGenerator _sheetGenerator;
  final ExtensionGenerator _extensionGenerator;

  TranslatorService({
    ConfigService? configService,
    LanguageService? languageService,
    TranslationInputService? inputService,
    MainClassGenerator? mainGenerator,
    SheetClassGenerator? sheetGenerator,
    ExtensionGenerator? extensionGenerator,
  }) : _configService = configService ?? ConfigService(),
       _languageService = languageService ?? LanguageService(),
       _inputService = inputService ?? TranslationInputService(),
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
      final config = _configService.loadConfiguration(
        excelFilePath: filePath,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates,
        multiFile: multiFile,
        pubspecPath: pubspecPath,
      );

      final finalFilePath = config.excelFilePath ?? filePath;
      if (finalFilePath.isEmpty) {
        throw const ConfigurationException('Translation file path is required');
      }

      await _generateFromInputPaths(
        filePaths: [finalFilePath],
        outputDir: config.outputDir ?? outputDir,
        className: config.className ?? 'AppLocalizations',
        includeFlutterDelegates: config.includeFlutterDelegates ?? true,
        multiFile: config.multiFile ?? true,
        deriveCsvModuleNames: false,
      );
    } catch (e, stackTrace) {
      Logger.error('Generation failed', e, stackTrace);
      rethrow;
    }
  }

  /// Generate from pubspec configuration only
  Future<void> generateFromPubspec([String? pubspecPath]) async {
    final config = _configService.loadFromPubspec(pubspecPath);

    if (config == null || config.outputDir == null) {
      throw const ConfigurationException(
        'Configuration not found in pubspec.yaml. Add excel_translator with excel_file or files and output_dir',
      );
    }

    final filePaths =
        config.files ??
        (config.excelFilePath == null ? null : [config.excelFilePath!]);
    if (filePaths == null) {
      throw const ConfigurationException(
        'Configure either excel_translator.excel_file or excel_translator.files',
      );
    }

    await _generateFromInputPaths(
      filePaths: filePaths,
      outputDir: config.outputDir!,
      className: config.className ?? 'AppLocalizations',
      includeFlutterDelegates: config.includeFlutterDelegates ?? true,
      multiFile: config.multiFile ?? true,
      deriveCsvModuleNames: config.files != null,
    );
  }

  // Private helper methods

  Future<void> _generateFromInputPaths({
    required List<String> filePaths,
    required String outputDir,
    required String className,
    required bool includeFlutterDelegates,
    required bool multiFile,
    required bool deriveCsvModuleNames,
  }) async {
    if (outputDir.isEmpty) {
      throw const ConfigurationException('Output directory is required');
    }

    Logger.info('Starting localization generation...');
    Logger.info('Files: ${filePaths.join(', ')}');
    Logger.info('Output: $outputDir');
    Logger.info('Class: $className');
    Logger.progress('Parsing files...');

    final sheets = await _inputService.parseFileSystemFiles(
      filePaths,
      languageService: _languageService,
      deriveCsvModuleNames: deriveCsvModuleNames,
    );
    if (sheets.isEmpty) {
      throw const FileParsingException(
        'No sheets found in files or all sheets are empty',
      );
    }

    Logger.success('Parsed ${sheets.length} sheet(s)');
    Logger.progress('Generating localization classes...');
    await _generateClasses(
      sheets: sheets,
      outputDir: outputDir,
      className: className,
      includeFlutterDelegates: includeFlutterDelegates,
      multiFile: multiFile,
    );
    Logger.success(
      'Generated localization classes in $outputDir successfully!',
    );
  }

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
      buffer.writeln('// ignore_for_file: type=lint');
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
