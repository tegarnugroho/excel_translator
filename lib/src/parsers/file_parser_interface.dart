import '../models/models.dart';
import '../services/services.dart';

/// Supported file formats
enum FileFormat {
  xlsx('xlsx', 'Excel'),
  csv('csv', 'CSV'),
  ods('ods', 'ODS');

  final String extension;
  final String displayName;

  const FileFormat(this.extension, this.displayName);

  /// Create from file extension
  static FileFormat fromExtension(String ext) {
    final normalized = ext.toLowerCase().replaceAll('.', '');
    return FileFormat.values.firstWhere(
      (format) => format.extension == normalized,
      orElse: () => throw UnsupportedError('Unsupported file format: $ext'),
    );
  }
}

/// Interface for file parsers
abstract class IFileParser {
  /// Get supported file format
  FileFormat get supportedFormat;

  /// Check if file is valid for this parser
  bool isValidFile(String filePath);

  /// Parse file and return localization sheets
  Future<List<LocalizationSheet>> parseFile(
    String filePath, {
    LanguageService? languageService,
  });

  /// Parse file from bytes and return localization sheets
  Future<List<LocalizationSheet>> parseFileFromBytes(
    List<int> bytes, {
    LanguageService? languageService,
  });
}
