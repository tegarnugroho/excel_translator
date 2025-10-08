import 'package:test/test.dart';
import '../../../../lib/src/domain/entities/entities.dart';
import '../../../../lib/src/data/repositories_impl/config_repository_impl.dart';
import '../../../../lib/src/data/sources/config_data_source.dart';

class MockConfigDataSource implements ConfigDataSource {
  Map<String, dynamic>? _mockData;
  String? _lastPath;

  void setMockData(Map<String, dynamic>? data) {
    _mockData = data;
  }

  String? get lastCalledPath => _lastPath;

  @override
  Map<String, dynamic>? loadConfigFromPubspec([String? pubspecPath]) {
    _lastPath = pubspecPath;
    return _mockData;
  }
}

void main() {
  group('ConfigRepositoryImpl Tests', () {
    late ConfigRepositoryImpl repository;
    late MockConfigDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockConfigDataSource();
      repository = ConfigRepositoryImpl(configDataSource: mockDataSource);
    });

    group('loadFromPubspec', () {
      test('should return ExcelTranslatorConfig when data source provides data',
          () {
        // Arrange
        final mockData = {
          'excel_file': 'test.xlsx',
          'output_dir': 'lib/generated',
          'class_name': 'TestLocalizations',
          'include_flutter_delegates': false,
        };
        mockDataSource.setMockData(mockData);

        // Act
        final result = repository.loadFromPubspec('/test/path');

        // Assert
        expect(result, isNotNull);
        expect(result!.excelFilePath, equals('test.xlsx'));
        expect(result.outputDir, equals('lib/generated'));
        expect(result.className, equals('TestLocalizations'));
        expect(result.includeFlutterDelegates, isFalse);
        expect(mockDataSource.lastCalledPath, equals('/test/path'));
      });

      test('should return null when data source returns null', () {
        // Arrange
        mockDataSource.setMockData(null);

        // Act
        final result = repository.loadFromPubspec('/test/path');

        // Assert
        expect(result, isNull);
        expect(mockDataSource.lastCalledPath, equals('/test/path'));
      });

      test('should handle partial configuration data', () {
        // Arrange
        final mockData = {
          'excel_file': 'partial.xlsx',
          'class_name': 'PartialLocalizations',
          // Missing output_dir and include_flutter_delegates
        };
        mockDataSource.setMockData(mockData);

        // Act
        final result = repository.loadFromPubspec();

        // Assert
        expect(result, isNotNull);
        expect(result!.excelFilePath, equals('partial.xlsx'));
        expect(result.outputDir, isNull);
        expect(result.className, equals('PartialLocalizations'));
        expect(result.includeFlutterDelegates, isTrue); // default value
      });

      test('should handle empty configuration data', () {
        // Arrange
        mockDataSource.setMockData(<String, dynamic>{});

        // Act
        final result = repository.loadFromPubspec();

        // Assert
        expect(result, isNotNull);
        expect(result!.excelFilePath, isNull);
        expect(result.outputDir, isNull);
        expect(result.className, isNull);
        expect(result.includeFlutterDelegates, isTrue); // default value
      });
    });

    group('getDefault', () {
      test('should return default configuration', () {
        // Act
        final result = repository.getDefault();

        // Assert
        expect(result.excelFilePath, isNull);
        expect(result.outputDir, isNull);
        expect(result.className, equals('AppLocalizations'));
        expect(result.includeFlutterDelegates, isTrue);
      });
    });

    group('mergeConfigurations', () {
      test('should merge with proper priority: provided > pubspec > default',
          () {
        // Arrange
        const providedConfig = ExcelTranslatorConfig(
          excelFilePath: 'provided.xlsx',
          className: 'ProvidedLocalizations',
        );

        const pubspecConfig = ExcelTranslatorConfig(
          excelFilePath: 'pubspec.xlsx',
          outputDir: 'lib/pubspec',
          className: 'PubspecLocalizations',
          includeFlutterDelegates: false,
        );

        // Act
        final result = repository.mergeConfigurations(
          provided: providedConfig,
          pubspec: pubspecConfig,
        );

        // Assert
        expect(result.excelFilePath, equals('provided.xlsx')); // from provided
        expect(result.outputDir, equals('lib/pubspec')); // from pubspec
        expect(
            result.className, equals('ProvidedLocalizations')); // from provided
        expect(result.includeFlutterDelegates,
            isTrue); // from provided (overrides pubspec)
      });

      test('should use pubspec when provided is null', () {
        // Arrange
        const pubspecConfig = ExcelTranslatorConfig(
          excelFilePath: 'pubspec.xlsx',
          outputDir: 'lib/pubspec',
        );

        // Act
        final result = repository.mergeConfigurations(
          provided: null,
          pubspec: pubspecConfig,
        );

        // Assert
        expect(result.excelFilePath, equals('pubspec.xlsx')); // from pubspec
        expect(result.outputDir, equals('lib/pubspec')); // from pubspec
        expect(result.className, equals('AppLocalizations')); // from default
        expect(result.includeFlutterDelegates, isTrue); // from default
      });

      test('should use default when both provided and pubspec are null', () {
        // Act
        final result = repository.mergeConfigurations(
          provided: null,
          pubspec: null,
        );

        // Assert
        expect(result.excelFilePath, isNull);
        expect(result.outputDir, isNull);
        expect(result.className, equals('AppLocalizations')); // from default
        expect(result.includeFlutterDelegates, isTrue); // from default
      });

      test('should handle provided config only', () {
        // Arrange
        const providedConfig = ExcelTranslatorConfig(
          excelFilePath: 'only_provided.xlsx',
          includeFlutterDelegates: false,
        );

        // Act
        final result = repository.mergeConfigurations(
          provided: providedConfig,
          pubspec: null,
        );

        // Assert
        expect(result.excelFilePath,
            equals('only_provided.xlsx')); // from provided
        expect(result.outputDir, isNull); // from default
        expect(result.className, equals('AppLocalizations')); // from default
        expect(result.includeFlutterDelegates, isFalse); // from provided
      });
    });
  });
}
