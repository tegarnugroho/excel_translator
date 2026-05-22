import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/utils.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Generator for main localization class
class MainClassGenerator {
  /// Generate just the class + delegate bodies — no file header, no imports.
  ///
  /// Used by the builder (inline mode) where the caller owns the header and
  /// writes sheet class bodies before calling this.
  String generateClassAndDelegate(
    List<LocalizationSheet> sheets,
    String className,
    bool includeFlutterDelegates,
  ) {
    final buffer = StringBuffer();

    final allLanguageCodes = <String>{};
    for (final sheet in sheets) {
      allLanguageCodes.addAll(sheet.languageCodes);
    }
    final sortedLanguages = allLanguageCodes.toList()..sort();

    buffer.writeln('class $className {');
    buffer.writeln('  final String languageCode;');
    buffer.writeln();

    buffer.writeln('  static const List<String> supportedLanguages = [');
    for (final lang in sortedLanguages) {
      buffer.writeln("    '$lang',");
    }
    buffer.writeln('  ];');
    buffer.writeln();

    for (final sheet in sheets) {
      final sheetClassName =
          '${StringUtils.sanitizeClassName(sheet.name)}Localizations';
      final propertyName = StringUtils.sanitizePropertyName(sheet.name);
      buffer.writeln('  late final $sheetClassName $propertyName;');
    }
    buffer.writeln();

    buffer.writeln('  $className(this.languageCode) {');
    for (final sheet in sheets) {
      final sheetClassName =
          '${StringUtils.sanitizeClassName(sheet.name)}Localizations';
      final propertyName = StringUtils.sanitizePropertyName(sheet.name);
      buffer.writeln('    $propertyName = $sheetClassName(languageCode);');
    }
    buffer.writeln('  }');
    buffer.writeln();

    if (includeFlutterDelegates) {
      final languageService = LanguageService();
      final addedGetters = <String>{};

      for (final lang in sortedLanguages.take(5)) {
        final capitalizedLang = languageService.getLanguageName(lang);
        final camelCaseLang = StringUtils.sanitizePropertyName(lang);
        buffer.writeln('  /// Get $capitalizedLang instance');
        buffer.writeln(
          "  static $className get $camelCaseLang => $className('$lang');",
        );
        addedGetters.add(camelCaseLang);
      }
      buffer.writeln();

      for (final lang in sortedLanguages.take(5)) {
        final fullName = languageService.getLanguageName(lang);
        final camelCaseFullName = StringUtils.sanitizePropertyName(fullName);
        final camelCaseLang = StringUtils.sanitizePropertyName(lang);
        if (!addedGetters.contains(camelCaseFullName) &&
            camelCaseFullName != camelCaseLang) {
          buffer.writeln(
            "  static $className get $camelCaseFullName => $className('$lang');",
          );
        }
      }
      buffer.writeln();

      buffer.writeln('  static $className of(BuildContext context) {');
      buffer.writeln('    final locale = Localizations.localeOf(context);');
      buffer.writeln('    return $className(locale.languageCode);');
      buffer.writeln('  }');
      buffer.writeln();

      buffer.writeln('  /// Get system language with fallback');
      buffer.writeln('  static String getSystemLanguage() {');
      buffer.writeln('    try {');
      buffer.writeln(
        '      // Try to get from Flutter${String.fromCharCode(39)}s PlatformDispatcher first',
      );
      buffer.writeln(
        '      final locales = PlatformDispatcher.instance.locales;',
      );
      buffer.writeln('      if (locales.isNotEmpty) {');
      buffer.writeln(
        '        final locale = locales.first.languageCode.toLowerCase();',
      );
      buffer.writeln('        if (supportedLanguages.contains(locale)) {');
      buffer.writeln('          return locale;');
      buffer.writeln('        }');
      buffer.writeln('      }');
      buffer.writeln('    } catch (e) {');
      buffer.writeln(
        '      // Fall back to other methods if PlatformDispatcher fails',
      );
      buffer.writeln('    }');
      buffer.writeln();
      buffer.writeln('    // Final fallback to English');
      buffer.writeln("    return 'en';");
      buffer.writeln('  }');
      buffer.writeln();

      buffer.writeln('  /// Get current localization based on system language');
      buffer.writeln(
        '  static $className get current => $className(getSystemLanguage());',
      );
      buffer.writeln();

      buffer.writeln('  /// Delegate for localizations');
      buffer.writeln(
        '  static const ${className}Delegate delegate = ${className}Delegate();',
      );
      buffer.writeln();
      buffer.writeln(
        '  /// All localization delegates including Flutter${String.fromCharCode(39)}s built-in delegates',
      );
      buffer.writeln(
        '  static const List<LocalizationsDelegate<dynamic>> delegates = [',
      );
      buffer.writeln('    delegate, // Custom localizations');
      buffer.writeln('    GlobalMaterialLocalizations.delegate,');
      buffer.writeln('    GlobalWidgetsLocalizations.delegate,');
      buffer.writeln('    GlobalCupertinoLocalizations.delegate,');
      buffer.writeln('  ];');
      buffer.writeln();
    }

    buffer.writeln('}');

    if (includeFlutterDelegates) {
      buffer.writeln();
      buffer.writeln(
        'class ${className}Delegate extends LocalizationsDelegate<$className> {',
      );
      buffer.writeln('  const ${className}Delegate();');
      buffer.writeln();
      buffer.writeln('  @override');
      buffer.writeln('  bool isSupported(Locale locale) {');
      buffer.writeln(
        '    return $className.supportedLanguages.contains(locale.languageCode);',
      );
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

    return buffer.toString();
  }

  /// Generate full main class file content as String (CLI mode).
  ///
  /// Includes file header, flutter imports, per-sheet imports, class, delegate.
  String generateContent(
    List<LocalizationSheet> sheets,
    String className,
    bool includeFlutterDelegates,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Generated by Excel Translator');
    buffer.writeln();

    if (includeFlutterDelegates) {
      buffer.writeln("import 'package:flutter/material.dart';");
      buffer.writeln("import 'package:flutter/cupertino.dart';");
      buffer.writeln(
        "import 'package:excel_translator/excel_translator.dart';",
      );
      buffer.writeln("import 'dart:ui' show PlatformDispatcher;");
    }

    for (final sheet in sheets) {
      final fileName = StringUtils.sanitizeFileName(sheet.name);
      buffer.writeln("import '${fileName}_localizations.dart';");
    }
    buffer.writeln();

    buffer.write(generateClassAndDelegate(sheets, className, includeFlutterDelegates));

    return buffer.toString();
  }

  /// Write main class file to disk (CLI mode).
  Future<void> generateMainClass(
    List<LocalizationSheet> sheets,
    String outputDir,
    String className,
    bool includeFlutterDelegates,
  ) async {
    final content = generateContent(sheets, className, includeFlutterDelegates);
    final file = File(path.join(outputDir, 'generated_localizations.dart'));
    await file.writeAsString(content);
  }
}
