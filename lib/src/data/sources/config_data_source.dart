// Data source for reading configuration from pubspec.yaml
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

/// Data source for loading configuration from pubspec.yaml files
class ConfigDataSource {
  /// Load configuration from pubspec.yaml file
  Map<String, dynamic>? loadConfigFromPubspec([String? pubspecPath]) {
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

      // Look for excel_translator configuration
      final configSection = yaml['excel_translator'] as Map<dynamic, dynamic>?;
      if (configSection == null) return null;

      // Convert to String keys
      return Map<String, dynamic>.from(configSection);
    } catch (e) {
      // Silently ignore errors and return null
      return null;
    }
  }

  /// Find pubspec.yaml file starting from given path or current directory
  File? _findPubspecFile([String? startPath]) {
    Directory current;
    if (startPath != null) {
      current = Directory(startPath);
      if (!current.existsSync()) {
        current = File(startPath).parent;
      }
    } else {
      current = Directory.current;
    }

    // Search upward for pubspec.yaml
    while (current.parent.path != current.path) {
      final pubspecFile = File(path.join(current.path, 'pubspec.yaml'));
      if (pubspecFile.existsSync()) {
        return pubspecFile;
      }
      current = current.parent;
    }

    return null;
  }
}
