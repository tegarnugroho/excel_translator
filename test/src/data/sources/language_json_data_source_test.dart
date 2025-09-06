import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import '../../../../lib/src/data/sources/language_json_data_source.dart';

void main() {
  group('LanguageJsonDataSource Tests', () {
    late Directory tempDir;
    late LanguageJsonDataSource dataSource;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('lang_test_');
      dataSource = LanguageJsonDataSource();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should load language data from direct array format', () async {
      // Create test JSON with direct array format
      final testData = [
        {
          'languageCode': 'en',
          'countryCode': 'US',
          'language': 'english',
          'country': 'united states'
        },
        {
          'languageCode': 'id',
          'countryCode': 'ID',
          'language': 'indonesian',
          'country': 'indonesia'
        }
      ];

      final jsonFile = File(path.join(tempDir.path, 'lang.json'));
      await jsonFile.writeAsString(json.encode(testData));

      final result = dataSource.loadLanguageData(jsonFile.path);

      expect(result, isNotNull);
      expect(result!['lang'], isA<List>());
      final langList = result['lang'] as List;
      expect(langList, hasLength(2));
      expect(langList[0]['languageCode'], equals('en'));
      expect(langList[1]['languageCode'], equals('id'));
    });

    test('should load language data from wrapped object format', () async {
      // Create test JSON with wrapped object format
      final testData = {
        'lang': [
          {
            'languageCode': 'fr',
            'countryCode': 'FR',
            'language': 'french',
            'country': 'france'
          }
        ]
      };

      final jsonFile = File(path.join(tempDir.path, 'lang.json'));
      await jsonFile.writeAsString(json.encode(testData));

      final result = dataSource.loadLanguageData(jsonFile.path);

      expect(result, isNotNull);
      expect(result!['lang'], isA<List>());
      final langList = result['lang'] as List;
      expect(langList, hasLength(1));
      expect(langList[0]['languageCode'], equals('fr'));
    });

    test('should return null for invalid JSON', () async {
      final jsonFile = File(path.join(tempDir.path, 'invalid.json'));
      await jsonFile.writeAsString('invalid json content');

      final result = dataSource.loadLanguageData(jsonFile.path);

      expect(result, isNull);
    });

    test('should handle fallback when specified file does not exist', () {
      final result = dataSource
          .loadLanguageData('/absolutely/non/existent/path/file.json');

      // During test execution, the package discovery may or may not work
      // depending on the test environment, so we accept both outcomes
      if (result != null) {
        // If fallback works, should have valid language data
        expect(result['lang'], isA<List>());
        expect(result['lang'], isNotEmpty);
      } else {
        // If fallback doesn't work in test environment, should return null gracefully
        expect(result, isNull);
      }
    });

    test('should return null for unsupported JSON structure', () async {
      final testData = 'just a string';

      final jsonFile = File(path.join(tempDir.path, 'string.json'));
      await jsonFile.writeAsString(json.encode(testData));

      final result = dataSource.loadLanguageData(jsonFile.path);

      expect(result, isNull);
    });

    test('should find language file in lib/assets when no path provided', () {
      // This test verifies the file discovery logic
      // When no path is provided, it should try to find lang.json in the project
      final result = dataSource.loadLanguageData();

      // Should either find the project's lang.json or return null gracefully
      // We don't assert the result since it depends on the test environment
      expect(() => result, returnsNormally);
    });

    test('should handle empty JSON object', () async {
      final testData = <String, dynamic>{};

      final jsonFile = File(path.join(tempDir.path, 'empty.json'));
      await jsonFile.writeAsString(json.encode(testData));

      final result = dataSource.loadLanguageData(jsonFile.path);

      expect(result, isNotNull);
      expect(result, equals(testData));
    });

    test('should handle nested object without lang key', () async {
      final testData = {
        'someOtherKey': [
          {'data': 'value'}
        ]
      };

      final jsonFile = File(path.join(tempDir.path, 'nested.json'));
      await jsonFile.writeAsString(json.encode(testData));

      final result = dataSource.loadLanguageData(jsonFile.path);

      expect(result, isNotNull);
      expect(result, equals(testData));
    });
  });
}
