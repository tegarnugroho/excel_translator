import '../entities/entities.dart';

/// Repository contract for configuration management
abstract class IConfigRepository {
  /// Load configuration from pubspec.yaml
  ExcelTranslatorConfig? loadFromPubspec([String? pubspecPath]);

  /// Get default configuration
  ExcelTranslatorConfig getDefault();

  /// Merge configurations with priority: provided > pubspec > default
  ExcelTranslatorConfig mergeConfigurations({
    ExcelTranslatorConfig? provided,
    ExcelTranslatorConfig? pubspec,
  });
}
