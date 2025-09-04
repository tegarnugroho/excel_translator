import 'package:test/test.dart';
import '../../../../lib/src/domain/entities/entities.dart';
import '../../../../lib/src/domain/repositories/repositories.dart';
import '../../../../lib/src/domain/usecases/load_configuration_use_case.dart';

class MockConfigRepository implements IConfigRepository {
  ExcelTranslatorConfig? _mockPubspecConfig;
  String? _lastPubspecPath;
  
  void setMockPubspecConfig(ExcelTranslatorConfig? config) {
    _mockPubspecConfig = config;
  }

  String? get lastPubspecPath => _lastPubspecPath;

  @override
  ExcelTranslatorConfig? loadFromPubspec([String? pubspecPath]) {
    _lastPubspecPath = pubspecPath;
    return _mockPubspecConfig;
  }

  @override
  ExcelTranslatorConfig getDefault() {
    return const ExcelTranslatorConfig(
      className: 'AppLocalizations',
      includeFlutterDelegates: true,
    );
  }

  @override
  ExcelTranslatorConfig mergeConfigurations({
    ExcelTranslatorConfig? provided,
    ExcelTranslatorConfig? pubspec,
  }) {
    final defaultConfig = getDefault();
    
    // Priority: provided > pubspec > default
    var result = defaultConfig;
    
    if (pubspec != null) {
      result = result.mergeWith(pubspec);
    }
    
    if (provided != null) {
      result = result.mergeWith(provided);
    }
    
    return result;
  }
}

void main() {
  group('LoadConfigurationUseCase Tests', () {
    late LoadConfigurationUseCase useCase;
    late MockConfigRepository mockRepository;

    setUp(() {
      mockRepository = MockConfigRepository();
      useCase = LoadConfigurationUseCase(mockRepository);
    });

    test('should load configuration with all parameters provided', () {
      // Arrange
      const pubspecConfig = ExcelTranslatorConfig(
        outputDir: 'lib/pubspec_generated',
        includeFlutterDelegates: false,
      );
      mockRepository.setMockPubspecConfig(pubspecConfig);

      // Act
      final result = useCase.execute(
        excelFilePath: 'test.xlsx',
        outputDir: 'lib/custom',
        className: 'CustomLocalizations',
        includeFlutterDelegates: true,
        pubspecPath: '/custom/pubspec.yaml',
      );

      // Assert
      expect(result.excelFilePath, equals('test.xlsx')); // from provided
      expect(result.outputDir, equals('lib/custom')); // from provided
      expect(result.className, equals('CustomLocalizations')); // from provided
      expect(result.includeFlutterDelegates, isTrue); // from provided
      expect(mockRepository.lastPubspecPath, equals('/custom/pubspec.yaml'));
    });

    test('should merge with pubspec config when some parameters not provided', () {
      // Arrange
      const pubspecConfig = ExcelTranslatorConfig(
        excelFilePath: 'pubspec.xlsx',
        outputDir: 'lib/pubspec_generated',
        includeFlutterDelegates: false,
      );
      mockRepository.setMockPubspecConfig(pubspecConfig);

      // Act
      final result = useCase.execute(
        className: 'CustomLocalizations',
        // Not providing excelFilePath, outputDir, includeFlutterDelegates
      );

      // Assert
      expect(result.excelFilePath, equals('pubspec.xlsx')); // from pubspec
      expect(result.outputDir, equals('lib/pubspec_generated')); // from pubspec
      expect(result.className, equals('CustomLocalizations')); // from provided
      expect(result.includeFlutterDelegates, isTrue); // from provided (default true when creating provided config)
    });

    test('should use default config when no parameters provided and no pubspec', () {
      // Arrange
      mockRepository.setMockPubspecConfig(null);

      // Act
      final result = useCase.execute();

      // Assert
      expect(result.excelFilePath, isNull); // from default
      expect(result.outputDir, isNull); // from default
      expect(result.className, equals('AppLocalizations')); // from default
      expect(result.includeFlutterDelegates, isTrue); // from default
    });

    test('should handle partial provided configuration', () {
      // Arrange
      const pubspecConfig = ExcelTranslatorConfig(
        excelFilePath: 'pubspec.xlsx',
        outputDir: 'lib/pubspec_generated',
        className: 'PubspecLocalizations',
        includeFlutterDelegates: false,
      );
      mockRepository.setMockPubspecConfig(pubspecConfig);

      // Act
      final result = useCase.execute(
        excelFilePath: 'override.xlsx',
        // Not providing outputDir, className, includeFlutterDelegates
      );

      // Assert
      expect(result.excelFilePath, equals('override.xlsx')); // from provided
      expect(result.outputDir, equals('lib/pubspec_generated')); // from pubspec
      expect(result.className, equals('PubspecLocalizations')); // from pubspec
      expect(result.includeFlutterDelegates, isTrue); // from provided (default true when creating provided config)
    });

    test('should pass pubspec path to repository', () {
      // Arrange
      mockRepository.setMockPubspecConfig(null);

      // Act
      useCase.execute(pubspecPath: '/specific/path/pubspec.yaml');

      // Assert
      expect(mockRepository.lastPubspecPath, equals('/specific/path/pubspec.yaml'));
    });

    test('should handle null pubspec path', () {
      // Arrange
      mockRepository.setMockPubspecConfig(null);

      // Act
      useCase.execute();

      // Assert
      expect(mockRepository.lastPubspecPath, isNull);
    });

    test('should handle false includeFlutterDelegates parameter', () {
      // Arrange
      mockRepository.setMockPubspecConfig(null);

      // Act
      final result = useCase.execute(
        includeFlutterDelegates: false,
      );

      // Assert
      expect(result.includeFlutterDelegates, isFalse); // from provided
    });

    test('should use true as default for includeFlutterDelegates when creating provided config', () {
      // Arrange
      mockRepository.setMockPubspecConfig(null);

      // Act
      final result = useCase.execute(
        excelFilePath: 'test.xlsx',
        // Not explicitly setting includeFlutterDelegates
      );

      // Assert
      expect(result.includeFlutterDelegates, isTrue); // default value when creating provided config
    });

    test('should not create provided config when no parameters are given', () {
      // Arrange
      const pubspecConfig = ExcelTranslatorConfig(
        excelFilePath: 'pubspec.xlsx',
        includeFlutterDelegates: false,
      );
      mockRepository.setMockPubspecConfig(pubspecConfig);

      // Act
      final result = useCase.execute(); // No parameters provided

      // Assert
      // Should use pubspec + default merge, not provided config
      expect(result.excelFilePath, equals('pubspec.xlsx')); // from pubspec
      expect(result.className, equals('AppLocalizations')); // from default
      expect(result.includeFlutterDelegates, isFalse); // from pubspec
    });
  });
}
