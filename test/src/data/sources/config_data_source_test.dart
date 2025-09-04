import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../../../../lib/src/data/sources/config_data_source.dart';

void main() {
  group('ConfigDataSource Tests', () {
    late Directory tempDir;
    late ConfigDataSource dataSource;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('config_test_');
      dataSource = ConfigDataSource();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should load excel_translator config from pubspec.yaml', () async {
      // Create test pubspec.yaml with excel_translator configuration
      final pubspecContent = '''
name: test_package
version: 1.0.0

excel_translator:
  excel_file_path: translations.xlsx
  output_dir: lib/l10n
  class_name: AppLocalizations
  include_flutter_delegates: false
''';

      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      await pubspecFile.writeAsString(pubspecContent);

      final result = dataSource.loadConfigFromPubspec(tempDir.path);

      expect(result, isNotNull);
      expect(result!['excel_file_path'], equals('translations.xlsx'));
      expect(result['output_dir'], equals('lib/l10n'));
      expect(result['class_name'], equals('AppLocalizations'));
      expect(result['include_flutter_delegates'], isFalse);
    });

    test('should return null when no excel_translator section exists', () async {
      // Create test pubspec.yaml without excel_translator configuration
      final pubspecContent = '''
name: test_package
version: 1.0.0

dependencies:
  flutter:
    sdk: flutter
''';

      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      await pubspecFile.writeAsString(pubspecContent);

      final result = dataSource.loadConfigFromPubspec(tempDir.path);

      expect(result, isNull);
    });

    test('should return null when pubspec.yaml does not exist', () {
      final result = dataSource.loadConfigFromPubspec('/non/existent/path');

      expect(result, isNull);
    });

    test('should return null for invalid YAML', () async {
      // Create invalid YAML file
      final invalidYaml = '''
name: test_package
version: 1.0.0
invalid: yaml: content: [
''';

      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      await pubspecFile.writeAsString(invalidYaml);

      final result = dataSource.loadConfigFromPubspec(tempDir.path);

      expect(result, isNull);
    });

    test('should return null for empty excel_translator section', () async {
      // Create test pubspec.yaml with empty excel_translator section
      final pubspecContent = '''
name: test_package
version: 1.0.0

excel_translator:
''';

      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      await pubspecFile.writeAsString(pubspecContent);

      final result = dataSource.loadConfigFromPubspec(tempDir.path);

      expect(result, isNull); // Empty section is treated as null
    });

    test('should handle partial configuration', () async {
      // Create test pubspec.yaml with partial configuration
      final pubspecContent = '''
name: test_package
version: 1.0.0

excel_translator:
  excel_file_path: translations.xlsx
  class_name: MyLocalizations
''';

      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      await pubspecFile.writeAsString(pubspecContent);

      final result = dataSource.loadConfigFromPubspec(tempDir.path);

      expect(result, isNotNull);
      expect(result!['excel_file_path'], equals('translations.xlsx'));
      expect(result['class_name'], equals('MyLocalizations'));
      expect(result.containsKey('output_dir'), isFalse);
      expect(result.containsKey('include_flutter_delegates'), isFalse);
    });

    test('should find pubspec.yaml when given direct file path', () async {
      // Create test pubspec.yaml
      final pubspecContent = '''
name: test_package
version: 1.0.0

excel_translator:
  excel_file_path: test.xlsx
''';

      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      await pubspecFile.writeAsString(pubspecContent);

      final result = dataSource.loadConfigFromPubspec(pubspecFile.path);

      expect(result, isNotNull);
      expect(result!['excel_file_path'], equals('test.xlsx'));
    });

    test('should handle nested directories', () async {
      // Create nested directory structure
      final subDir = Directory(path.join(tempDir.path, 'sub', 'nested'));
      await subDir.create(recursive: true);

      // Create pubspec.yaml in root
      final pubspecContent = '''
name: test_package
version: 1.0.0

excel_translator:
  excel_file_path: nested.xlsx
''';

      final pubspecFile = File(path.join(tempDir.path, 'pubspec.yaml'));
      await pubspecFile.writeAsString(pubspecContent);

      // Try to load from nested directory
      final result = dataSource.loadConfigFromPubspec(subDir.path);

      expect(result, isNotNull);
      expect(result!['excel_file_path'], equals('nested.xlsx'));
    });

    test('should load without explicit path', () {
      // Test loading from current directory (should handle gracefully)
      final result = dataSource.loadConfigFromPubspec();

      // Should not throw and handle gracefully
      expect(() => result, returnsNormally);
    });
  });
}
