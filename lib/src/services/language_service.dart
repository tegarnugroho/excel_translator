import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Service for language validation and management
class LanguageService {
  Set<String>? _validLanguageCodes;
  Map<String, String>? _languageNames;

  /// Check if language code is valid
  bool isValidLanguageCode(String code) {
    _ensureDataLoaded();
    final normalizedCode = code.toLowerCase().trim();

    if (_validLanguageCodes!.contains(normalizedCode)) {
      return true;
    }

    // Check locale formats (en_US, pt_BR)
    if (normalizedCode.contains('_')) {
      final parts = normalizedCode.split('_');
      if (parts.length == 2 && _validLanguageCodes!.contains(parts[0])) {
        return true;
      }
    }

    // Check dash format (en-US, pt-BR) for backward compatibility
    if (normalizedCode.contains('-')) {
      final parts = normalizedCode.split('-');
      if (parts.length == 2 && _validLanguageCodes!.contains(parts[0])) {
        return true;
      }
    }

    return false;
  }

  /// Validate list of language codes (throws exception if invalid)
  void validateLanguageCodes(List<String> languageCodes, String sheetName) {
    if (languageCodes.isEmpty) {
      throw Exception(
          'Sheet "$sheetName": No language codes found in header row.\n'
          'Please ensure the first row contains valid language codes (e.g., en, id, es).');
    }

    final invalidCodes = <String>[];
    for (final code in languageCodes) {
      if (!isValidLanguageCode(code)) {
        invalidCodes.add(code);
      }
    }

    if (invalidCodes.isNotEmpty) {
      throw Exception(
          'Sheet "$sheetName": Invalid language codes found in header: ${invalidCodes.join(', ')}\n'
          'Valid language codes are ISO 639-1 codes like: en, id, es, fr, de, pt, etc.\n'
          'You can also use locale formats like: en_US, pt_BR, zh_CN (preferred) or en-US, pt-BR, zh-CN');
    }

    print(
        '✅ Sheet "$sheetName": Valid language codes found: ${languageCodes.join(', ')}');
  }

  /// Filter out invalid language codes and return only valid ones with their indices
  Map<String, int> filterValidLanguageCodes(
      List<String> languageCodes, String sheetName) {
    final validCodesWithIndices = <String, int>{};
    final invalidCodes = <String>[];

    for (int i = 0; i < languageCodes.length; i++) {
      final code = languageCodes[i];
      if (isValidLanguageCode(code)) {
        validCodesWithIndices[code] = i;
      } else {
        invalidCodes.add(code);
      }
    }

    if (invalidCodes.isNotEmpty) {
      print(
          '⚠️  Sheet "$sheetName": Skipping invalid language code columns: ${invalidCodes.join(', ')}');
      print(
          '   Valid language codes are ISO 639-1 codes like: en, id, es, fr, de, pt, etc.');
      print(
          '   You can also use locale formats like: en_US, pt_BR, zh_CN (preferred) or en-US, pt-BR, zh-CN');
    }

    if (validCodesWithIndices.isNotEmpty) {
      print(
          '✅ Sheet "$sheetName": Processing valid language codes: ${validCodesWithIndices.keys.join(', ')}');
    }

    return validCodesWithIndices;
  }

  /// Get language name from code
  String getLanguageName(String code) {
    _ensureDataLoaded();
    final lowercaseCode = code.toLowerCase();
    return _languageNames![lowercaseCode] ?? lowercaseCode;
  }

  /// Get all valid language codes
  Set<String> get validLanguageCodes {
    _ensureDataLoaded();
    return _validLanguageCodes!;
  }

  /// Get language names mapping
  Map<String, String> get languageNames {
    _ensureDataLoaded();
    return _languageNames!;
  }

  /// Reload language data
  void reload() {
    _validLanguageCodes = null;
    _languageNames = null;
    _loadLanguageData();
  }

  // Private methods

  void _ensureDataLoaded() {
    if (_validLanguageCodes == null || _languageNames == null) {
      _loadLanguageData();
    }
  }

  void _loadLanguageData() {
    try {
      final jsonData = _loadLanguageJson();

      if (jsonData != null) {
        _parseJsonData(jsonData);
      } else {
        _useFallbackData();
      }
    } catch (e) {
      _useFallbackData();
    }
  }

  Map<String, dynamic>? _loadLanguageJson() {
    try {
      final jsonFile = _findLanguageJsonFile();
      if (jsonFile == null || !jsonFile.existsSync()) {
        return null;
      }

      final jsonString = jsonFile.readAsStringSync();
      final data = json.decode(jsonString);

      if (data is List) {
        return {'lang': data};
      } else if (data is Map<String, dynamic>) {
        return data;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  File? _findLanguageJsonFile() {
    final currentFile =
        File(path.fromUri(Uri.parse(Platform.script.toString())));
    final packageRoot = _findPackageRoot(currentFile.parent);

    final libAssetsJsonFile =
        File(path.join(packageRoot.path, 'lib', 'assets', 'lang.json'));
    if (libAssetsJsonFile.existsSync()) {
      return libAssetsJsonFile;
    }

    return null;
  }

  Directory _findPackageRoot(Directory dir) {
    Directory current = dir;
    while (current.parent.path != current.path) {
      if (File(path.join(current.path, 'pubspec.yaml')).existsSync()) {
        return current;
      }
      current = current.parent;
    }
    return dir;
  }

  void _parseJsonData(Map<String, dynamic> data) {
    List<dynamic> langArray;

    if (data.containsKey('lang')) {
      langArray = data['lang'] as List;
    } else {
      throw Exception(
          'Invalid language data format - expected "lang" property with array');
    }

    _validLanguageCodes = <String>{};
    _languageNames = <String, String>{};

    for (final langItem in langArray) {
      final langMap = langItem as Map<String, dynamic>;

      String code;
      String name;

      if (langMap.containsKey('languageCode')) {
        code = langMap['languageCode'] as String;
        name = langMap['language'] as String;
      } else {
        code = langMap['code'] as String;
        name = langMap['name'] as String;
      }

      _validLanguageCodes!.add(code.toLowerCase());
      _languageNames![code.toLowerCase()] = name.toLowerCase();
    }
  }

  void _useFallbackData() {
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
      'ru': 'russian',
      'it': 'italian',
      'nl': 'dutch',
      'pl': 'polish',
      'tr': 'turkish',
      'sv': 'swedish',
      'da': 'danish',
      'no': 'norwegian',
      'fi': 'finnish',
      'he': 'hebrew',
      'th': 'thai',
      'vi': 'vietnamese',
      'uk': 'ukrainian'
    };
  }
}
