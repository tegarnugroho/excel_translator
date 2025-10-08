// Implementation of configuration repository
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../sources/config_data_source.dart';

/// Implementation of configuration repository using data sources
class ConfigRepositoryImpl implements IConfigRepository {
  final ConfigDataSource _configDataSource;

  ConfigRepositoryImpl({
    ConfigDataSource? configDataSource,
  }) : _configDataSource = configDataSource ?? ConfigDataSource();

  @override
  ExcelTranslatorConfig? loadFromPubspec([String? pubspecPath]) {
    final configData = _configDataSource.loadConfigFromPubspec(pubspecPath);
    if (configData == null) return null;

    return ExcelTranslatorConfig(
      excelFilePath: configData['excel_file'] as String?,
      outputDir: configData['output_dir'] as String?,
      className: configData['class_name'] as String?,
      includeFlutterDelegates:
          configData['include_flutter_delegates'] as bool? ?? true,
    );
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
