// Data source for loading language data from JSON files
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Data source for loading language data from lang.json files
class LanguageJsonDataSource {
  /// Load language data from lang.json file
  Map<String, dynamic>? loadLanguageData([String? jsonPath]) {
    try {
      final jsonFile = _findLanguageJsonFile(jsonPath);
      if (jsonFile == null || !jsonFile.existsSync()) {
        return null;
      }

      final jsonString = jsonFile.readAsStringSync();
      final data = json.decode(jsonString);

      // Handle both formats: direct array or wrapped in object
      if (data is List) {
        // Direct array format like: [{"languageCode": "en", ...}, ...]
        return {'lang': data};
      } else if (data is Map<String, dynamic>) {
        // Object format like: {"lang": [...]}
        return data;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Find lang.json file
  File? _findLanguageJsonFile([String? jsonPath]) {
    if (jsonPath != null) {
      final file = File(jsonPath);
      if (file.existsSync()) {
        return file;
      }
    }

    // Try to find relative to current package
    final currentFile = File(path.fromUri(Uri.parse(Platform.script.toString())));
    final packageRoot = _findPackageRoot(currentFile.parent);
    
    // Look in lib/assets folder (new location)
    final libAssetsJsonFile = File(path.join(packageRoot.path, 'lib', 'assets', 'lang.json'));
    if (libAssetsJsonFile.existsSync()) {
      return libAssetsJsonFile;
    }
    
    // Look in assets folder (alternative location)
    final assetsJsonFile = File(path.join(packageRoot.path, 'assets', 'lang.json'));
    if (assetsJsonFile.existsSync()) {
      return assetsJsonFile;
    }
    
    // Fallback to old location for backward compatibility
    final legacyJsonFile = File(path.join(packageRoot.path, 'lib', 'src', 'data', 'lang', 'lang.json'));
    if (legacyJsonFile.existsSync()) {
      return legacyJsonFile;
    }

    return null;
  }

  /// Find package root directory by looking for pubspec.yaml
  Directory _findPackageRoot(Directory dir) {
    Directory current = dir;
    while (current.parent.path != current.path) {
      if (File(path.join(current.path, 'pubspec.yaml')).existsSync()) {
        return current;
      }
      current = current.parent;
    }
    return dir; // fallback to current directory
  }
}
