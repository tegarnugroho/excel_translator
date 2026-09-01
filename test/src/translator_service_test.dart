import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../../lib/src/translator_service.dart';

void main() {
  group('TranslatorService Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('translator_service_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    test('should create service with factory constructor', () {
      // Act
      final service = TranslatorService.create();

      // Assert
      expect(service, isNotNull);
      expect(service, isA<TranslatorService>());
    });

    test('should have proper service architecture with all dependencies', () {
      // This test verifies that the service can be instantiated
      // with all its dependencies properly wired
      expect(() => TranslatorService.create(), returnsNormally);
    });

    test('generates feature modules from multiple CSV files', () async {
      final sourceFiles = <String>[];
      for (final module in ['common', 'auth', 'home_explore', 'events']) {
        final file = File(path.join(tempDir.path, '$module.csv'));
        await file.writeAsString(
          'key,en,id\n${module}_title,$module title,$module judul\n',
        );
        sourceFiles.add(_yamlPath(file.path));
      }

      final outputDir = path.join(tempDir.path, 'generated_multi');
      final pubspec = await _writePubspec(
        tempDir,
        sourceFiles: sourceFiles,
        outputDir: outputDir,
        multiFile: true,
      );

      await TranslatorService.create().generateFromPubspec(pubspec.path);

      for (final module in ['common', 'auth', 'home_explore', 'events']) {
        expect(
          File(
            path.join(outputDir, '${module}_localizations.dart'),
          ).existsSync(),
          isTrue,
        );
      }
      final generated = await File(
        path.join(outputDir, 'generated_localizations.dart'),
      ).readAsString();
      expect(generated, contains('CommonLocalizations common'));
      expect(generated, contains('AuthLocalizations auth'));
      expect(generated, contains('HomeExploreLocalizations homeExplore'));
      expect(generated, contains('EventsLocalizations events'));

      final authGenerated = await File(
        path.join(outputDir, 'auth_localizations.dart'),
      ).readAsString();
      expect(authGenerated, contains("return 'auth judul';"));
    });

    test('supports multiple inputs with single-file output', () async {
      final common = await _writeCsv(tempDir, 'common');
      final auth = await _writeCsv(tempDir, 'auth');
      final outputDir = path.join(tempDir.path, 'generated_single');
      final pubspec = await _writePubspec(
        tempDir,
        sourceFiles: [_yamlPath(common.path), _yamlPath(auth.path)],
        outputDir: outputDir,
        multiFile: false,
        pubspecName: 'single_pubspec.yaml',
      );

      await TranslatorService.create().generateFromPubspec(pubspec.path);

      final generatedFile = File(
        path.join(outputDir, 'generated_localizations.dart'),
      );
      expect(generatedFile.existsSync(), isTrue);
      expect(
        File(path.join(outputDir, 'common_localizations.dart')).existsSync(),
        isFalse,
      );
      final generated = await generatedFile.readAsString();
      expect(generated, contains('class CommonLocalizations'));
      expect(generated, contains('class AuthLocalizations'));
    });

    test('keeps legacy excel_file CSV behavior', () async {
      final legacy = await _writeCsv(tempDir, 'legacy');
      final outputDir = path.join(tempDir.path, 'generated_legacy');
      final pubspec = File(path.join(tempDir.path, 'legacy_pubspec.yaml'));
      await pubspec.writeAsString('''
name: test_package
excel_translator:
  excel_file: ${_yamlPath(legacy.path)}
  output_dir: ${_yamlPath(outputDir)}
  include_flutter_delegates: false
  multi_file: false
''');

      await TranslatorService.create().generateFromPubspec(pubspec.path);

      final generated = await File(
        path.join(outputDir, 'generated_localizations.dart'),
      ).readAsString();
      expect(generated, contains('class DefaultLocalizations'));
      expect(generated, contains('DefaultLocalizations defaultValue'));
    });
  });
}

Future<File> _writeCsv(Directory directory, String module) async {
  final file = File(path.join(directory.path, '$module.csv'));
  await file.writeAsString('key,en,id\ntitle,$module,$module-id\n');
  return file;
}

Future<File> _writePubspec(
  Directory directory, {
  required List<String> sourceFiles,
  required String outputDir,
  required bool multiFile,
  String pubspecName = 'pubspec.yaml',
}) async {
  final pubspec = File(path.join(directory.path, pubspecName));
  final filesYaml = sourceFiles.map((file) => '    - $file').join('\n');
  await pubspec.writeAsString('''
name: test_package
excel_translator:
  files:
$filesYaml
  output_dir: ${_yamlPath(outputDir)}
  include_flutter_delegates: false
  multi_file: $multiFile
''');
  return pubspec;
}

String _yamlPath(String value) => value.replaceAll('\\', '/');
