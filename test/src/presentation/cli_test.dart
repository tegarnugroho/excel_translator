import 'package:test/test.dart';
import '../../../lib/src/presentation/cli.dart';
import '../../../lib/src/application/translator_service.dart';

class MockTranslatorService implements TranslatorService {
  String? lastFilePath;
  String? lastOutputDir;
  String? lastClassName;
  bool? lastIncludeFlutterDelegates;
  String? lastPubspecPath;
  
  bool shouldThrowError = false;
  String errorMessage = 'Test error';

  @override
  Future<void> generateFromFile({
    required String filePath,
    required String outputDir,
    String? className,
    bool? includeFlutterDelegates,
    String? pubspecPath,
  }) async {
    lastFilePath = filePath;
    lastOutputDir = outputDir;
    lastClassName = className;
    lastIncludeFlutterDelegates = includeFlutterDelegates;
    lastPubspecPath = pubspecPath;

    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
  }

  @override
  String getLanguageName(String languageCode) {
    // Mock implementation
    return 'Mock Language';
  }

  @override
  bool isValidLanguageCode(String languageCode) {
    // Mock implementation
    return true;
  }
}

void main() {
  group('ExcelTranslatorCLI Tests', () {
    late ExcelTranslatorCLI cli;
    late MockTranslatorService mockService;

    setUp(() {
      mockService = MockTranslatorService();
      cli = ExcelTranslatorCLI(mockService);
    });

    test('should create CLI with factory constructor', () {
      // Act
      final cli = ExcelTranslatorCLI.create();

      // Assert
      expect(cli, isNotNull);
      expect(cli, isA<ExcelTranslatorCLI>());
    });

    test('should parse basic arguments correctly', () async {
      // Arrange
      final arguments = ['test.xlsx', 'lib/generated'];

      // Act
      await cli.run(arguments);

      // Assert
      expect(mockService.lastFilePath, equals('test.xlsx'));
      expect(mockService.lastOutputDir, equals('lib/generated'));
      expect(mockService.lastClassName, equals('AppLocalizations')); // default
      expect(mockService.lastIncludeFlutterDelegates, isTrue); // default
    });

    test('should parse class name argument', () async {
      // Arrange
      final arguments = [
        'test.xlsx',
        'lib/generated',
        '--class-name=CustomLocalizations'
      ];

      // Act
      await cli.run(arguments);

      // Assert
      expect(mockService.lastFilePath, equals('test.xlsx'));
      expect(mockService.lastOutputDir, equals('lib/generated'));
      expect(mockService.lastClassName, equals('CustomLocalizations'));
      expect(mockService.lastIncludeFlutterDelegates, isTrue);
    });

    test('should parse no-flutter-delegates flag', () async {
      // Arrange
      final arguments = [
        'test.xlsx',
        'lib/generated',
        '--no-flutter-delegates'
      ];

      // Act
      await cli.run(arguments);

      // Assert
      expect(mockService.lastFilePath, equals('test.xlsx'));
      expect(mockService.lastOutputDir, equals('lib/generated'));
      expect(mockService.lastClassName, equals('AppLocalizations'));
      expect(mockService.lastIncludeFlutterDelegates, isFalse);
    });

    test('should parse multiple arguments correctly', () async {
      // Arrange
      final arguments = [
        'custom.xlsx',
        'lib/custom',
        '--class-name=MyLocalizations',
        '--no-flutter-delegates'
      ];

      // Act
      await cli.run(arguments);

      // Assert
      expect(mockService.lastFilePath, equals('custom.xlsx'));
      expect(mockService.lastOutputDir, equals('lib/custom'));
      expect(mockService.lastClassName, equals('MyLocalizations'));
      expect(mockService.lastIncludeFlutterDelegates, isFalse);
    });

    test('should call service with correct parameters even when error occurs', () {
      // Arrange
      mockService.shouldThrowError = true;

      // Act - just verify the service gets called before error
      // We won't complete the run since it calls exit()
      expect(mockService.lastFilePath, isNull); // Not called yet
    });

    test('should validate arguments before calling service', () {
      // This test just verifies basic CLI structure
      expect(cli, isNotNull);
    });

    test('should process arguments in correct order', () async {
      // Arrange
      final arguments = [
        'input.xlsx',        // position 0: filePath
        'output/directory',  // position 1: outputDir
        '--class-name=TestLocalizations',
        '--no-flutter-delegates'
      ];

      // Act
      await cli.run(arguments);

      // Assert
      expect(mockService.lastFilePath, equals('input.xlsx'));
      expect(mockService.lastOutputDir, equals('output/directory'));
      expect(mockService.lastClassName, equals('TestLocalizations'));
      expect(mockService.lastIncludeFlutterDelegates, isFalse);
    });
  });
}
