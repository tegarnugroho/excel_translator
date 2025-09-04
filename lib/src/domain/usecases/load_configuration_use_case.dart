// Use case for loading and managing configuration
import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Use case for loading and managing Excel Translator configuration
class LoadConfigurationUseCase {
  final IConfigRepository _configRepository;

  LoadConfigurationUseCase(this._configRepository);

  /// Load complete configuration with proper priority merging
  ExcelTranslatorConfig execute({
    String? excelFilePath,
    String? outputDir,
    String? className,
    bool? includeFlutterDelegates,
    String? pubspecPath,
  }) {
    // Load configuration from pubspec.yaml
    final pubspecConfig = _configRepository.loadFromPubspec(pubspecPath);
    
    // Create provided configuration from parameters
    ExcelTranslatorConfig? providedConfig;
    if (excelFilePath != null || outputDir != null || className != null || includeFlutterDelegates != null) {
      providedConfig = ExcelTranslatorConfig(
        excelFilePath: excelFilePath,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates ?? true,
      );
    }
    
    // Merge configurations with proper priority
    return _configRepository.mergeConfigurations(
      provided: providedConfig,
      pubspec: pubspecConfig,
    );
  }
}
