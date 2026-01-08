import 'package:test/test.dart';
import '../../../lib/src/models/config.dart';

void main() {
  group('ExcelTranslatorConfig Entity Tests', () {
    test('should create config with all parameters', () {
      const config = ExcelTranslatorConfig(
        excelFilePath: 'test.xlsx',
        outputDir: 'lib/generated',
        className: 'TestLocalizations',
        includeFlutterDelegates: false,
      );

      expect(config.excelFilePath, equals('test.xlsx'));
      expect(config.outputDir, equals('lib/generated'));
      expect(config.className, equals('TestLocalizations'));
      expect(config.includeFlutterDelegates, isFalse);
    });

    test('should create config with default values', () {
      const config = ExcelTranslatorConfig();

      expect(config.excelFilePath, isNull);
      expect(config.outputDir, isNull);
      expect(config.className, isNull);
      expect(config.includeFlutterDelegates, isNull); // null means use default true
    });

    test('should create copy with modified fields using copyWith', () {
      const original = ExcelTranslatorConfig(
        excelFilePath: 'original.xlsx',
        outputDir: 'lib/original',
        className: 'OriginalLocalizations',
        includeFlutterDelegates: true,
      );

      final modified = original.copyWith(
        excelFilePath: 'modified.xlsx',
        className: 'ModifiedLocalizations',
      );

      expect(modified.excelFilePath, equals('modified.xlsx'));
      expect(modified.outputDir, equals('lib/original')); // unchanged
      expect(modified.className, equals('ModifiedLocalizations'));
      expect(modified.includeFlutterDelegates, isTrue); // unchanged
    });

    test('should merge configs with priority to other config', () {
      const baseConfig = ExcelTranslatorConfig(
        excelFilePath: 'base.xlsx',
        outputDir: 'lib/base',
        className: 'BaseLocalizations',
        includeFlutterDelegates: true,
      );

      const otherConfig = ExcelTranslatorConfig(
        excelFilePath: 'other.xlsx',
        className: 'OtherLocalizations',
        includeFlutterDelegates: false,
      );

      final merged = baseConfig.mergeWith(otherConfig);

      expect(merged.excelFilePath, equals('other.xlsx')); // from other
      expect(merged.outputDir, equals('lib/base')); // from base (other is null)
      expect(merged.className, equals('OtherLocalizations')); // from other
      expect(merged.includeFlutterDelegates, isFalse); // from other
    });

    test('should merge with null other config returning same config', () {
      const baseConfig = ExcelTranslatorConfig(
        excelFilePath: 'base.xlsx',
        outputDir: 'lib/base',
      );

      final merged = baseConfig.mergeWith(null);

      expect(merged, equals(baseConfig));
    });

    test('should implement equality correctly', () {
      const config1 = ExcelTranslatorConfig(
        excelFilePath: 'test.xlsx',
        outputDir: 'lib/generated',
        className: 'TestLocalizations',
        includeFlutterDelegates: true,
      );

      const config2 = ExcelTranslatorConfig(
        excelFilePath: 'test.xlsx',
        outputDir: 'lib/generated',
        className: 'TestLocalizations',
        includeFlutterDelegates: true,
      );

      const config3 = ExcelTranslatorConfig(
        excelFilePath: 'different.xlsx',
        outputDir: 'lib/generated',
        className: 'TestLocalizations',
        includeFlutterDelegates: true,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should implement hashCode correctly', () {
      const config1 = ExcelTranslatorConfig(
        excelFilePath: 'test.xlsx',
        outputDir: 'lib/generated',
        className: 'TestLocalizations',
        includeFlutterDelegates: true,
      );

      const config2 = ExcelTranslatorConfig(
        excelFilePath: 'test.xlsx',
        outputDir: 'lib/generated',
        className: 'TestLocalizations',
        includeFlutterDelegates: true,
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('should provide meaningful toString representation', () {
      const config = ExcelTranslatorConfig(
        excelFilePath: 'test.xlsx',
        outputDir: 'lib/generated',
        className: 'TestLocalizations',
        includeFlutterDelegates: false,
      );

      final stringRepresentation = config.toString();

      expect(stringRepresentation, contains('ExcelTranslatorConfig'));
      expect(stringRepresentation, contains('test.xlsx'));
      expect(stringRepresentation, contains('lib/generated'));
      expect(stringRepresentation, contains('TestLocalizations'));
      expect(stringRepresentation, contains('false'));
    });
  });
}
