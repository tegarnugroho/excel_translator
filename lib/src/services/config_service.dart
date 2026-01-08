import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import '../models/models.dart';

/// Service for loading and managing Excel Translator configuration
class ConfigService {
  /// Load configuration from pubspec.yaml file
  ExcelTranslatorConfig? loadFromPubspec([String? pubspecPath]) {
    final configData = _loadConfigDataFromPubspec(pubspecPath);
    if (configData == null) return null;

    return ExcelTranslatorConfig(
      excelFilePath: configData['excel_file'] as String?,
      outputDir: configData['output_dir'] as String?,
      className: configData['class_name'] as String?,
      includeFlutterDelegates:
          configData['include_flutter_delegates'] as bool? ?? true,
    );
  }

  /// Get default configuration
  ExcelTranslatorConfig getDefault() {
    return const ExcelTranslatorConfig(
      className: 'AppLocalizations',
      includeFlutterDelegates: true,
    );
  }

  /// Merge configurations with priority: provided > pubspec > default
  ExcelTranslatorConfig mergeConfigurations({
    ExcelTranslatorConfig? provided,
    ExcelTranslatorConfig? pubspec,
  }) {
    var result = getDefault();

    if (pubspec != null) {
      result = result.mergeWith(pubspec);
    }

    if (provided != null) {
      result = result.mergeWith(provided);
    }

    return result;
  }

  /// Load complete configuration with proper priority merging
  ExcelTranslatorConfig loadConfiguration({
    String? excelFilePath,
    String? outputDir,
    String? className,
    bool? includeFlutterDelegates,
    String? pubspecPath,
  }) {
    final pubspecConfig = loadFromPubspec(pubspecPath);

    ExcelTranslatorConfig? providedConfig;
    if (excelFilePath != null ||
        outputDir != null ||
        className != null ||
        includeFlutterDelegates != null) {
      providedConfig = ExcelTranslatorConfig(
        excelFilePath: excelFilePath,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates ?? true,
      );
    }

    return mergeConfigurations(
      provided: providedConfig,
      pubspec: pubspecConfig,
    );
  }

  // Private helper methods

  Map<String, dynamic>? _loadConfigDataFromPubspec([String? pubspecPath]) {
    try {
      final pubspecFile = _findPubspecFile(pubspecPath);

      if (pubspecFile == null || !pubspecFile.existsSync()) {
        return null;
      }

      final content = pubspecFile.readAsStringSync();
      final yaml = loadYaml(content) as Map<dynamic, dynamic>?;

      if (yaml == null) return null;

      final configSection = yaml['excel_translator'] as Map<dynamic, dynamic>?;

      if (configSection == null) return null;

      return Map<String, dynamic>.from(configSection);
    } catch (e) {
      return null;
    }
  }

  File? _findPubspecFile([String? startPath]) {
    Directory current;
    if (startPath != null) {
      if (startPath.endsWith('.yaml') || startPath.endsWith('.yml')) {
        current = File(startPath).parent.absolute;
      } else {
        current = Directory(startPath).absolute;
        if (!current.existsSync()) {
          current = File(startPath).parent.absolute;
        }
      }
    } else {
      current = Directory.current.absolute;
    }

    int searchCount = 0;
    while (current.parent.path != current.path && searchCount < 10) {
      final pubspecFile = File(path.join(current.path, 'pubspec.yaml'));

      if (pubspecFile.existsSync()) {
        return pubspecFile;
      }
      current = current.parent;
      searchCount++;
    }

    return null;
  }
}
