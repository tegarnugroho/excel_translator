// Factory for creating appropriate file data sources
import 'sources.dart';

/// Factory for creating appropriate file data sources
class FileDataSourceFactory {
  static final Map<FileFormat, IFileDataSource> _dataSources = {
    FileFormat.xlsx: ExcelFileDataSource(),
    FileFormat.csv: CsvFileDataSource(),
    FileFormat.ods: OdsFileDataSource(),
  };

  /// Detect file format from file path
  static FileFormat detectFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return FileFormat.fromExtension(extension);
  }

  /// Create appropriate data source based on file path
  static IFileDataSource createDataSource(String filePath) {
    final format = detectFormat(filePath);
    final dataSource = _dataSources[format];
    if (dataSource == null) {
      throw UnsupportedError('No data source available for format: $format');
    }
    return dataSource;
  }
  
  /// Get all available data sources
  static List<IFileDataSource> getAllDataSources() {
    return _dataSources.values.toList();
  }
  
  /// Check if file format is supported
  static bool isSupportedFormat(String filePath) {
    try {
      final format = detectFormat(filePath);
      return _dataSources.containsKey(format);
    } catch (e) {
      return false;
    }
  }

  /// Get supported extensions
  static List<String> get supportedExtensions {
    return FileFormat.values.map((f) => f.extension).toList();
  }
}
