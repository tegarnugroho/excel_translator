// Main generator for Excel Translator
import 'dart:io';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'models/models.dart';

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
}

/// Main class for generating localizations from Excel files
class ExcelLocalizationsGenerator {
  /// Generate localizations from an Excel file
  static Future<void> generateFromExcel({
    required String excelFilePath,
    required String outputDir,
    String className = 'AppLocalizations',
    bool includeFlutterDelegates = true,
  }) async {
    try {
      final file = File(excelFilePath);
      if (!file.existsSync()) {
        throw Exception('Excel file not found: $excelFilePath');
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final sheets = <LocalizationSheet>[];

      // Process each sheet
      for (final sheetName in excel.tables.keys) {
        final sheet = excel.tables[sheetName];
        if (sheet == null) continue;

        final entries = <LocalizationEntry>[];
        final rows = sheet.rows;

        if (rows.isEmpty) continue;

        // First row should contain language codes
        final languageCodes = <String>[];
        final headerRow = rows[0];

        for (int i = 1; i < headerRow.length; i++) {
          final cell = headerRow[i];
          if (cell?.value != null) {
            languageCodes.add(cell!.value.toString());
          }
        }

        // Validate that header contains valid language codes
        _validateLanguageCodes(languageCodes, sheetName);

        // Process data rows
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.isEmpty) continue;

          final keyCell = row[0];
          if (keyCell?.value == null) continue;

          final key = keyCell!.value.toString();
          final translations = <String, String>{};

          for (int j = 1; j < row.length && j - 1 < languageCodes.length; j++) {
            final cell = row[j];
            final languageCode = languageCodes[j - 1];
            translations[languageCode] = cell?.value?.toString() ?? '';
          }

          entries.add(LocalizationEntry(
            key: key,
            translations: translations,
          ));
        }

        sheets.add(LocalizationSheet(
          name: _sanitizeSheetName(sheetName),
          entries: entries,
          languageCodes: languageCodes,
        ));
      }

      await _generateDartFiles(
          sheets, outputDir, className, includeFlutterDelegates);

      print('✅ Localizations generated successfully!');
      print('📁 Output directory: $outputDir');
      print('📊 Generated ${sheets.length} sheet(s)');
      for (final sheet in sheets) {
        print('  - ${sheet.name}: ${sheet.entries.length} keys');
      }
    } catch (e) {
      print('❌ Error generating localizations: $e');
      rethrow;
    }
  }

  /// Validates if a string is a valid language code (exposed for testing)
  static bool isValidLanguageCode(String code) {
    return _isValidLanguageCode(code);
  }

  /// Validates if a string is a valid language code
  static bool _isValidLanguageCode(String code) {
    final normalizedCode = code.toLowerCase().trim();

    // Check exact match with ISO 639-1 codes
    if (LanguageData.validLanguageCodes.contains(normalizedCode)) {
      return true;
    }

    // Check if it's a locale format like 'en_US', 'pt_BR' (underscore format)
    if (normalizedCode.contains('_')) {
      final parts = normalizedCode.split('_');
      if (parts.length == 2 &&
          LanguageData.validLanguageCodes.contains(parts[0])) {
        return true;
      }
    }

    // Check if it's a locale format like 'en-US', 'pt-BR' (dash format - backward compatibility)
    if (normalizedCode.contains('-')) {
      final parts = normalizedCode.split('-');
      if (parts.length == 2 &&
          LanguageData.validLanguageCodes.contains(parts[0])) {
        return true;
      }
    }

    return false;
  }

  /// Validates language codes in header and throws exception if invalid codes found (exposed for testing)
  static void validateLanguageCodes(
      List<String> languageCodes, String sheetName) {
    _validateLanguageCodes(languageCodes, sheetName);
  }

  /// Validates language codes in header and throws exception if invalid codes found
  static void _validateLanguageCodes(
      List<String> languageCodes, String sheetName) {
    if (languageCodes.isEmpty) {
      throw Exception(
          'Sheet "$sheetName": No language codes found in header row.\n'
          'Please ensure the first row contains valid language codes (e.g., en, id, es).');
    }

    final invalidCodes = <String>[];
    for (final code in languageCodes) {
      if (!_isValidLanguageCode(code)) {
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

  // Helper methods (some exposed for testing)
  static String sanitizeSheetName(String sheetName) {
    return _sanitizeSheetName(sheetName);
  }

  static String _sanitizeSheetName(String sheetName) {
    return sheetName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .replaceAll(RegExp(r'^[0-9]'), 'sheet\$0');
  }

  static Future<void> _generateDartFiles(
    List<LocalizationSheet> sheets,
    String outputDir,
    String className,
    bool includeFlutterDelegates,
  ) async {
    final outputDirectory = Directory(outputDir);
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }

    // Generate main localizations class
    await _generateMainLocalizationsClass(
        sheets, outputDir, className, includeFlutterDelegates);

    // Generate individual sheet classes
    for (final sheet in sheets) {
      await _generateSheetClass(sheet, outputDir);
    }

    // Generate BuildContext extension
    await _generateBuildContextExtension(sheets, outputDir, className);
  }

  static Future<void> _generateMainLocalizationsClass(
    List<LocalizationSheet> sheets,
    String outputDir,
    String className,
    bool includeFlutterDelegates,
  ) async {
    final buffer = StringBuffer();

    // Add generation comment
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by Excel Translator');
    buffer.writeln('// ${DateTime.now()}');
    buffer.writeln();

    // Add imports based on requirements
    if (includeFlutterDelegates) {
      buffer.writeln("import 'package:flutter/material.dart';");
      buffer.writeln("import 'package:flutter/cupertino.dart';");
      buffer
          .writeln("import 'package:excel_translator/excel_translator.dart';");
      buffer.writeln("import 'dart:ui' show PlatformDispatcher;");
    }

    // Add sheet imports
    for (final sheet in sheets) {
      buffer.writeln("import '${sheet.name}_localizations.dart';");
    }
    buffer.writeln();

    // Generate main class
    buffer.writeln('class $className {');
    buffer.writeln('  final String languageCode;');
    buffer.writeln();

    // Add supported languages list
    final allLanguageCodes = <String>{};
    for (final sheet in sheets) {
      allLanguageCodes.addAll(sheet.languageCodes);
    }
    final sortedLanguages = allLanguageCodes.toList()..sort();

    buffer.writeln('  static const List<String> supportedLanguages = [');
    for (final lang in sortedLanguages) {
      buffer.writeln("    '$lang',");
    }
    buffer.writeln('  ];');
    buffer.writeln();

    // Add sheet properties
    for (final sheet in sheets) {
      final sheetClassName = '${_capitalize(sheet.name)}Localizations';
      buffer.writeln('  late final $sheetClassName ${sheet.name};');
    }
    buffer.writeln();

    // Constructor
    buffer.writeln('  $className(this.languageCode) {');
    for (final sheet in sheets) {
      final sheetClassName = '${_capitalize(sheet.name)}Localizations';
      buffer.writeln('    ${sheet.name} = $sheetClassName(languageCode);');
    }
    buffer.writeln('  }');
    buffer.writeln();

    if (includeFlutterDelegates) {
      // Add static helper methods for common languages
      for (final lang in sortedLanguages.take(5)) {
        final capitalizedLang = _getLanguageName(lang);
        buffer.writeln('  /// Get $capitalizedLang instance');
        buffer.writeln("  static $className get $lang => $className('$lang');");
      }
      buffer.writeln();

      // Add convenience static getters with full names
      for (final lang in sortedLanguages.take(5)) {
        final fullName = _getLanguageName(lang);
        buffer.writeln(
            "  static $className get $fullName => $className('$lang');");
      }
      buffer.writeln();

      // Static method for getting instance from context
      buffer.writeln('  static $className of(BuildContext context) {');
      buffer.writeln('    final locale = Localizations.localeOf(context);');
      buffer.writeln('    return $className(locale.languageCode);');
      buffer.writeln('  }');
      buffer.writeln();

      // Add getSystemLanguage method
      buffer.writeln('  /// Get system language with fallback');
      buffer.writeln('  static String getSystemLanguage() {');
      buffer.writeln('    try {');
      buffer.writeln(
          '      // Try to get from Flutter${String.fromCharCode(39)}s PlatformDispatcher first');
      buffer.writeln(
          '      final locales = PlatformDispatcher.instance.locales;');
      buffer.writeln('      if (locales.isNotEmpty) {');
      buffer.writeln('        final primaryLocale = locales.first;');
      buffer
          .writeln('        final languageCode = primaryLocale.languageCode;');
      buffer
          .writeln('        if (supportedLanguages.contains(languageCode)) {');
      buffer.writeln('          return languageCode;');
      buffer.writeln('        }');
      buffer.writeln('      }');
      buffer.writeln('    } catch (e) {');
      buffer.writeln(
          '      // PlatformDispatcher might not be available in some environments');
      buffer.writeln('    }');
      buffer.writeln();
      buffer.writeln('    // Final fallback to English');
      buffer.writeln("    return 'en';");
      buffer.writeln('  }');
      buffer.writeln();

      // Add current getter
      buffer.writeln('  /// Get current localization based on system language');
      buffer.writeln(
          '  static $className get current => $className(getSystemLanguage());');
      buffer.writeln();

      // Add Flutter delegates
      buffer.writeln('  /// Delegate for localizations');
      buffer.writeln(
          '  static const ${className}Delegate delegate = ${className}Delegate();');
      buffer.writeln();
      buffer.writeln(
          '  /// All localization delegates including Flutter${String.fromCharCode(39)}s built-in delegates');
      buffer.writeln(
          '  static const List<LocalizationsDelegate<dynamic>> delegates = [');
      buffer.writeln('    delegate, // Custom localizations');
      buffer.writeln('    GlobalMaterialLocalizations.delegate,');
      buffer.writeln('    GlobalWidgetsLocalizations.delegate,');
      buffer.writeln('    GlobalCupertinoLocalizations.delegate,');
      buffer.writeln('  ];');
      buffer.writeln();
    }

    buffer.writeln('}');

    // Add delegate class if Flutter delegates are enabled
    if (includeFlutterDelegates) {
      buffer.writeln();
      buffer.writeln(
          'class ${className}Delegate extends LocalizationsDelegate<$className> {');
      buffer.writeln('  const ${className}Delegate();');
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  bool isSupported(Locale locale) {');
      buffer.writeln(
          '    return $className.supportedLanguages.contains(locale.languageCode);');
      buffer.writeln('  }');
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  Future<$className> load(Locale locale) async {');
      buffer.writeln('    return $className(locale.languageCode);');
      buffer.writeln('  }');
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  bool shouldReload(${className}Delegate old) => false;');
      buffer.writeln('}');
    }

    final file = File(path.join(outputDir, 'generated_localizations.dart'));
    await file.writeAsString(buffer.toString());
  }

  static Future<void> _generateSheetClass(
    LocalizationSheet sheet,
    String outputDir,
  ) async {
    final buffer = StringBuffer();
    final className = '${_capitalize(sheet.name)}Localizations';

    // Add generation comment
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by Excel Translator');
    buffer.writeln('// ${DateTime.now()}');
    buffer.writeln();

    buffer.writeln('class $className {');
    buffer.writeln('  final String _languageCode;');
    buffer.writeln();
    buffer.writeln('  const $className(this._languageCode);');
    buffer.writeln();

    // Generate methods for each key
    for (final entry in sheet.entries) {
      final methodName = _sanitizeMethodName(entry.key);

      // Add comment for the translation key
      buffer.writeln('  /// Translation for key: ${entry.key}');

      // Check if the entry has interpolation
      final hasInterpolation = entry.translations.values.any(
        (value) => value.contains(RegExp(r'\{[^}]+\}')),
      );

      if (hasInterpolation) {
        // Generate method with parameters
        final params =
            _extractInterpolationParams(entry.translations.values.first);
        final paramList = params.map((p) => 'dynamic $p').join(', ');

        buffer.writeln('  String $methodName({$paramList}) {');
        buffer.writeln('    switch (_languageCode) {');

        for (final languageCode in sheet.languageCodes) {
          final translation = entry.translations[languageCode] ?? '';
          buffer.writeln("      case '$languageCode':");
          buffer.writeln("        return '''$translation'''");

          // Add interpolation replacements
          for (final param in params) {
            buffer.writeln(
                "            .replaceAll('{$param}', $param.toString())");
          }
          buffer.writeln("            ;");
        }

        buffer.writeln("      default:");
        final defaultTranslation = entry.translations.values.first;
        buffer.writeln("        return '''$defaultTranslation'''");
        for (final param in params) {
          buffer.writeln(
              "            .replaceAll('{$param}', $param.toString())");
        }
        buffer.writeln("            ;");
        buffer.writeln('    }');
        buffer.writeln('  }');
      } else {
        // Generate simple getter
        buffer.writeln('  String get $methodName {');
        buffer.writeln('    switch (_languageCode) {');

        for (final languageCode in sheet.languageCodes) {
          final translation = entry.translations[languageCode] ?? '';
          buffer.writeln("      case '$languageCode':");
          buffer.writeln("        return '''$translation''';");
        }

        buffer.writeln("      default:");
        final defaultTranslation = entry.translations.values.first;
        buffer.writeln("        return '''$defaultTranslation''';");
        buffer.writeln('    }');
        buffer.writeln('  }');
      }
      buffer.writeln();
    }

    buffer.writeln('}');

    final file = File(path.join(outputDir, '${sheet.name}_localizations.dart'));
    await file.writeAsString(buffer.toString());
  }

  static Future<void> _generateBuildContextExtension(
    List<LocalizationSheet> sheets,
    String outputDir,
    String className,
  ) async {
    final buffer = StringBuffer();

    // Add generation comment
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by Excel Translator');
    buffer.writeln('// ${DateTime.now()}');
    buffer.writeln();
    buffer.writeln(
        '// Uncomment the lines below to enable BuildContext extension');
    buffer.writeln(
        '// This provides easy access like: context.loc.localizations.hello');
    buffer.writeln('//');
    buffer.writeln("// import 'package:flutter/material.dart';");
    buffer.writeln("// import 'generated_localizations.dart';");
    buffer.writeln('//');
    buffer.writeln('// extension LocalizationsExtension on BuildContext {');
    buffer.writeln('//   $className get loc => $className.of(this);');
    buffer.writeln('// }');

    final file = File(path.join(outputDir, 'build_context_extension.dart'));
    await file.writeAsString(buffer.toString());
  }

  static String capitalize(String text) {
    return _capitalize(text);
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String sanitizeMethodName(String key) {
    return _sanitizeMethodName(key);
  }

  static String _sanitizeMethodName(String key) {
    // Convert to camelCase: app_title -> appTitle, welcome_message -> welcomeMessage
    final parts = key.toLowerCase().split('_');
    if (parts.length <= 1) {
      return key.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    }

    final camelCase = parts.first +
        parts
            .skip(1)
            .map((part) =>
                part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1))
            .join('');

    return camelCase
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .replaceAll(RegExp(r'^[0-9]'), 'key\$0');
  }

  static List<String> extractInterpolationParams(String text) {
    return _extractInterpolationParams(text);
  }

  static List<String> _extractInterpolationParams(String text) {
    final regex = RegExp(r'\{([^}]+)\}');
    final matches = regex.allMatches(text);
    return matches.map((match) => match.group(1)!).toSet().toList();
  }

  static String getLanguageName(String code) {
    return _getLanguageName(code);
  }

  static String _getLanguageName(String code) {
    return LanguageData.languageNames[code.toLowerCase()] ?? code.toLowerCase();
  }
}
