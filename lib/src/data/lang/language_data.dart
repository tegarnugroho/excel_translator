// Language data management for Excel Translator
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Language data loaded from JSON file
class LanguageData {
  static Set<String>? _validLanguageCodes;
  static Map<String, String>? _languageNames;

  static Set<String> get validLanguageCodes {
    if (_validLanguageCodes == null) {
      _loadLanguageData();
    }
    return _validLanguageCodes!;
  }

  static Map<String, String> get languageNames {
    if (_languageNames == null) {
      _loadLanguageData();
    }
    return _languageNames!;
  }

  static void _loadLanguageData() {
    try {
      // Get the current file directory
      final currentFile =
          File(path.fromUri(Uri.parse(Platform.script.toString())));
      final packageRoot = _findPackageRoot(currentFile.parent);
      final jsonFile =
          File(path.join(packageRoot.path, 'lib', 'src', 'lang', 'lang.json'));

      if (!jsonFile.existsSync()) {
        print('Warning: lang.json not found, using fallback data');
        _useFallbackData();
        return;
      }

      final jsonString = jsonFile.readAsStringSync();
      final data = json.decode(jsonString);

      // Parse new JSON format - direct array of language objects
      List<dynamic> langArray;
      if (data is List) {
        // New format: direct array
        langArray = data;
      } else if (data is Map<String, dynamic> && data.containsKey('lang')) {
        // Old format compatibility: wrapped in 'lang' property
        langArray = data['lang'] as List;
      } else {
        throw Exception('Invalid language data format');
      }

      _validLanguageCodes = <String>{};
      _languageNames = <String, String>{};

      for (final langItem in langArray) {
        final langMap = langItem as Map<String, dynamic>;

        // Support both old and new formats
        String code;
        String name;

        if (langMap.containsKey('languageCode')) {
          // New format
          code = langMap['languageCode'] as String;
          name = langMap['language'] as String;
        } else {
          // Old format compatibility
          code = langMap['code'] as String;
          name = langMap['name'] as String;
        }

        _validLanguageCodes!.add(code);
        _languageNames![code] = name.toLowerCase();
      }
    } catch (e) {
      print('Warning: Error loading language data: $e, using fallback');
      _useFallbackData();
    }
  }

  static Directory _findPackageRoot(Directory dir) {
    Directory current = dir;
    while (current.parent.path != current.path) {
      if (File(path.join(current.path, 'pubspec.yaml')).existsSync()) {
        return current;
      }
      current = current.parent;
    }
    return dir; // fallback to current directory
  }

  static void _useFallbackData() {
    _validLanguageCodes = {
      'en',
      'id',
      'es',
      'fr',
      'de',
      'pt',
      'zh',
      'ja',
      'ko',
      'ar',
      'hi',
      'ru',
      'it',
      'nl',
      'pl',
      'tr',
      'sv',
      'da',
      'no',
      'fi',
      'he',
      'th',
      'vi',
      'uk'
    };
    _languageNames = {
      'en': 'english',
      'id': 'indonesian',
      'es': 'spanish',
      'fr': 'french',
      'de': 'german',
      'pt': 'portuguese',
      'zh': 'chinese',
      'ja': 'japanese',
      'ko': 'korean',
      'ar': 'arabic',
      'hi': 'hindi',
      'ru': 'russian'
    };
  }

  /// Get language name for a given code, fallback to the code itself
  static String getLanguageName(String code) {
    final lowercaseCode = code.toLowerCase();
    return languageNames[lowercaseCode] ?? lowercaseCode;
  }
}
