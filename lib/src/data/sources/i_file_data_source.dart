// Data source contract for file parsing
import '../../domain/entities/entities.dart';

/// Supported file formats
enum FileFormat {
  xlsx('xlsx'),
  csv('csv'),
  ods('ods');

  const FileFormat(this.extension);
  final String extension;

  /// Get FileFormat from file extension
  static FileFormat fromExtension(String extension) {
    final normalizedExt = extension.toLowerCase();
    for (final format in FileFormat.values) {
      if (format.extension == normalizedExt) {
        return format;
      }
    }
    throw UnsupportedError(
        'Unsupported file format: .$extension. Supported formats: ${FileFormat.values.map((f) => '.${f.extension}').join(', ')}');
  }
}

/// Base interface for file data sources
abstract class IFileDataSource {
  /// Parse a file and return list of localization sheets
  Future<List<LocalizationSheet>> parseFile(String filePath);

  /// Get supported file format
  FileFormat get supportedFormat;

  /// Validate file before parsing
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.${supportedFormat.extension}');
  }
}
