import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;
import '../models/models.dart';
import '../utils/errors.dart';

/// Service for loading and managing Excel Translator configuration
class ConfigService {
  /// Load configuration from pubspec.yaml file
  ExcelTranslatorConfig? loadFromPubspec([String? pubspecPath]) {
    final configData = _loadConfigDataFromPubspec(pubspecPath);
    if (configData == null) return null;

    return parseConfig(configData);
  }

  /// Parse and validate an excel_translator configuration map.
  ExcelTranslatorConfig parseConfig(Map<dynamic, dynamic> configData) {
    final excelFile = configData['excel_file'];
    final rawFiles = configData['files'];

    if (excelFile != null && excelFile is! String) {
      throw const ConfigurationException('excel_file must be a string');
    }
    if (rawFiles != null && rawFiles is! List) {
      throw const ConfigurationException('files must be a list of file paths');
    }
    if (excelFile != null && rawFiles != null) {
      throw const ConfigurationException(
        'Configure either excel_file or files, not both',
      );
    }

    List<String>? files;
    if (rawFiles case final List<dynamic> values) {
      files = [];
      for (var index = 0; index < values.length; index++) {
        final value = values[index];
        if (value is! String) {
          throw ConfigurationException('files[$index] must be a string');
        }
        files.add(value);
      }
    }

    return ExcelTranslatorConfig(
      excelFilePath: excelFile as String?,
      files: files,
      outputDir: configData['output_dir'] as String?,
      className: configData['class_name'] as String?,
      includeFlutterDelegates:
          configData['include_flutter_delegates'] as bool? ?? true,
      multiFile: configData['multi_file'] as bool?,
    );
  }

  /// Get default configuration
  ExcelTranslatorConfig getDefault() {
    return const ExcelTranslatorConfig(
      className: 'AppLocalizations',
      includeFlutterDelegates: null, // Will use default true when resolved
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
    List<String>? files,
    String? outputDir,
    String? className,
    bool? includeFlutterDelegates,
    bool? multiFile,
    String? pubspecPath,
  }) {
    final pubspecConfig = loadFromPubspec(pubspecPath);

    ExcelTranslatorConfig? providedConfig;
    if (excelFilePath != null ||
        files != null ||
        outputDir != null ||
        className != null ||
        includeFlutterDelegates != null ||
        multiFile != null) {
      providedConfig = ExcelTranslatorConfig(
        excelFilePath: excelFilePath,
        files: files,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates ?? true,
        multiFile: multiFile,
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
        final explicitFile = File(startPath).absolute;
        if (explicitFile.existsSync()) return explicitFile;
        current = explicitFile.parent;
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
