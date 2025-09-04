import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

class ExcelTranslatorConfig {
  final String? excelFilePath;
  final String? outputDir;
  final String? className;
  final bool includeFlutterDelegates;

  const ExcelTranslatorConfig({
    this.excelFilePath,
    this.outputDir,
    this.className,
    this.includeFlutterDelegates = true,
  });

  /// Load configuration from pubspec.yaml
  static ExcelTranslatorConfig? fromPubspec([String? pubspecPath]) {
    try {
      // Find pubspec.yaml file
      final pubspecFile = _findPubspecFile(pubspecPath);
      if (pubspecFile == null || !pubspecFile.existsSync()) {
        return null;
      }

      // Parse YAML
      final content = pubspecFile.readAsStringSync();
      final yaml = loadYaml(content) as Map<dynamic, dynamic>?;

      if (yaml == null) return null;

      // Check for excel_translator configuration
      final config = yaml['excel_translator'] as Map<dynamic, dynamic>?;
      if (config == null) return null;

      return ExcelTranslatorConfig(
        excelFilePath: config['excel_file'] as String?,
        outputDir: config['output_dir'] as String?,
        className: config['class_name'] as String?,
        includeFlutterDelegates:
            config['include_flutter_delegates'] as bool? ?? true,
      );
    } catch (e) {
      print('⚠️  Warning: Could not read configuration from pubspec.yaml: $e');
      return null;
    }
  }

  /// Find pubspec.yaml file starting from current directory and going up
  static File? _findPubspecFile([String? startPath]) {
    Directory current =
        startPath != null ? Directory(startPath) : Directory.current;

    while (current.parent.path != current.path) {
      final pubspecFile = File(path.join(current.path, 'pubspec.yaml'));
      if (pubspecFile.existsSync()) {
        return pubspecFile;
      }
      current = current.parent;
    }
    return null;
  }

  /// Merge this config with CLI arguments (CLI takes precedence)
  ExcelTranslatorConfig mergeWith({
    String? excelFilePath,
    String? outputDir,
    String? className,
    bool? includeFlutterDelegates,
  }) {
    return ExcelTranslatorConfig(
      excelFilePath: excelFilePath ?? this.excelFilePath,
      outputDir: outputDir ?? this.outputDir,
      className: className ?? this.className,
      includeFlutterDelegates:
          includeFlutterDelegates ?? this.includeFlutterDelegates,
    );
  }

  /// Get final configuration with defaults
  Map<String, dynamic> getFinalConfig() {
    return {
      'excelFilePath': excelFilePath ?? 'assets/localizations.xlsx',
      'outputDir': outputDir ?? 'lib/generated',
      'className': className ?? 'AppLocalizations',
      'includeFlutterDelegates': includeFlutterDelegates,
    };
  }

  @override
  String toString() {
    return 'ExcelTranslatorConfig(excelFilePath: $excelFilePath, outputDir: $outputDir, className: $className, includeFlutterDelegates: $includeFlutterDelegates)';
  }
}
