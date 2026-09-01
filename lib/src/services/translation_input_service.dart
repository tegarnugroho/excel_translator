import 'dart:io';

import 'package:path/path.dart' as path;

import '../models/models.dart';
import '../parsers/parsers.dart';
import '../utils/utils.dart';
import 'language_service.dart';

typedef TranslationFileLoader = Future<List<int>> Function(String filePath);

/// Parses one or more translation sources into the shared sheet model.
class TranslationInputService {
  /// Parse files with a caller-provided loader.
  ///
  /// The builder uses an asset loader while the CLI uses the filesystem. Every
  /// source therefore follows the same validation and module naming rules.
  Future<List<LocalizationSheet>> parseFiles(
    List<String> filePaths, {
    required TranslationFileLoader loadBytes,
    LanguageService? languageService,
    bool deriveCsvModuleNames = true,
  }) async {
    if (filePaths.isEmpty) {
      throw const ConfigurationException(
        'files must contain at least one translation file',
      );
    }

    final normalizedPaths = <String, String>{};
    final sheets = <LocalizationSheet>[];
    final moduleSources = <String, ({String name, String filePath})>{};

    for (final rawFilePath in filePaths) {
      final filePath = rawFilePath.trim();
      if (filePath.isEmpty) {
        throw const ConfigurationException(
          'Translation file path cannot be empty',
        );
      }

      final normalizedPath = path.normalize(path.absolute(filePath));
      final previousPath = normalizedPaths[normalizedPath];
      if (previousPath != null) {
        throw ConfigurationException(
          'Duplicate translation file path:\n- $previousPath\n- $filePath',
        );
      }
      normalizedPaths[normalizedPath] = filePath;

      if (!FileParserFactory.isSupportedFormat(filePath)) {
        throw UnsupportedFileFormatException(
          filePath,
          FileParserFactory.supportedExtensions,
        );
      }

      final parser = FileParserFactory.createParser(filePath);
      final parsedSheets = await parser.parseFileFromBytes(
        await loadBytes(filePath),
        languageService: languageService,
      );
      final format = FileParserFactory.detectFormat(filePath);

      for (final parsedSheet in parsedSheets) {
        final sheet = format == FileFormat.csv && deriveCsvModuleNames
            ? parsedSheet.copyWith(
                name: path.basenameWithoutExtension(filePath),
              )
            : parsedSheet;
        _validateModule(sheet.name, filePath);

        final accessorName = StringUtils.sanitizePropertyName(sheet.name);
        final previousModule = moduleSources[accessorName];
        if (previousModule != null) {
          throw ConfigurationException(
            'Duplicate localization module "${sheet.name}":\n'
            '- ${previousModule.filePath}\n'
            '- $filePath',
          );
        }
        moduleSources[accessorName] = (name: sheet.name, filePath: filePath);
        sheets.add(sheet);
      }
    }

    return sheets;
  }

  /// Parse files directly from the local filesystem.
  Future<List<LocalizationSheet>> parseFileSystemFiles(
    List<String> filePaths, {
    LanguageService? languageService,
    bool deriveCsvModuleNames = true,
  }) {
    return parseFiles(
      filePaths,
      languageService: languageService,
      deriveCsvModuleNames: deriveCsvModuleNames,
      loadBytes: (filePath) async {
        final file = File(filePath);
        if (!file.existsSync()) throw FileNotFoundException(filePath);
        return file.readAsBytes();
      },
    );
  }

  void _validateModule(String moduleName, String filePath) {
    if (moduleName.trim().isEmpty ||
        StringUtils.sanitizeClassName(moduleName).isEmpty ||
        StringUtils.sanitizeFileName(moduleName).isEmpty) {
      throw ConfigurationException(
        'Invalid localization module "$moduleName" from $filePath',
      );
    }
  }
}
