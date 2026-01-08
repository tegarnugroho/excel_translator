import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../../../lib/src/services/config_service.dart';
import '../../../lib/src/models/models.dart';

void main() {
  group('ConfigService Tests', () {
    late Directory tempDir;
    late ConfigService configService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('config_test_');
      configService = ConfigService();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should load config from pubspec.yaml', () async {
      // Create test pubspec.yaml
      final pubspecContent = '''
name: test_package
version: 1.0.0

excel_translator:
  excel_file: translations.xlsx
  output_dir: lib/l10n
  class_name: AppLocalizations
  include_flutter_delegates: false
''';

      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      await pubspecFile.writeAsString(pubspecContent);

      final config = configService.loadFromPubspec(tempDir.path);

      expect(config, isNotNull);
      expect(config!.excelFilePath, equals('translations.xlsx'));
      expect(config.outputDir, equals('lib/l10n'));
      expect(config.className, equals('AppLocalizations'));
      expect(config.includeFlutterDelegates, isFalse);
    });

    test(
      'should return null when no excel_translator section exists',
      () async {
        final pubspecContent = '''
name: test_package
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
''';

        final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
        await pubspecFile.writeAsString(pubspecContent);

        final config = configService.loadFromPubspec(tempDir.path);

        expect(config, isNull);
      },
    );

    test('should return null when pubspec.yaml does not exist', () {
      final config = configService.loadFromPubspec('/non/existent/path');

      expect(config, isNull);
    });

    test('should return default config', () {
      final config = configService.getDefault();

      expect(config.className, equals('AppLocalizations'));
      expect(
        config.includeFlutterDelegates,
        isNull,
      ); // null means use default true
      expect(config.excelFilePath, isNull);
      expect(config.outputDir, isNull);
    });

    test('should merge configurations correctly', () {
      const provided = ExcelTranslatorConfig(
        excelFilePath: 'provided.xlsx',
        className: 'ProvidedLocalizations',
      );

      const pubspec = ExcelTranslatorConfig(
        outputDir: 'lib/pubspec',
        includeFlutterDelegates: false,
      );

      final merged = configService.mergeConfigurations(
        provided: provided,
        pubspec: pubspec,
      );

      // Priority: provided > pubspec > default
      expect(merged.excelFilePath, equals('provided.xlsx')); // from provided
      expect(
        merged.className,
        equals('ProvidedLocalizations'),
      ); // from provided
      expect(merged.outputDir, equals('lib/pubspec')); // from pubspec
      expect(merged.includeFlutterDelegates, isFalse); // from pubspec
    });

    test('should load complete configuration with proper merging', () {
      final config = configService.loadConfiguration(
        excelFilePath: 'test.xlsx',
        outputDir: 'lib/generated',
        className: 'TestLocalizations',
        includeFlutterDelegates: true,
      );

      expect(config.excelFilePath, equals('test.xlsx'));
      expect(config.outputDir, equals('lib/generated'));
      expect(config.className, equals('TestLocalizations'));
      expect(config.includeFlutterDelegates, isTrue);
    });
  });
}
