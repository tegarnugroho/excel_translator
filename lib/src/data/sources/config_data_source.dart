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
      final result = Map<String, dynamic>.from(configSection);
      return result;
    } catch (e) {
      // Silently ignore errors and return null
      return null;
    }
  }

  /// Find pubspec.yaml file starting from given path or current directory
  File? _findPubspecFile([String? startPath]) {
    Directory current;
    if (startPath != null) {
      // If it's a file path, get its directory
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

    // Search upward for pubspec.yaml
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
