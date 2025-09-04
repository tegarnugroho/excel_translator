// Base interface for file parsers
import '../../../data/models/models.dart';

/// Supported file formats with their extensions
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

/// Base interface for file parsers
abstract class FileParser {
  /// Parse a file and return list of localization sheets
  List<LocalizationSheet> parseFile(String filePath);
  
  /// Get supported file format
  FileFormat get supportedFormat;
  
  /// Validate file before parsing (optional)
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.${supportedFormat.extension}');
  }
}
