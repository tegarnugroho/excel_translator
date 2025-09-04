import '../entities/entities.dart';

/// Repository contract for parsing localization files
abstract class IFileParserRepository {
  /// Parse a file and return localization sheets
  Future<List<LocalizationSheet>> parseFile(String filePath);

  /// Check if file format is supported
  bool isFormatSupported(String filePath);

  /// Get supported file extensions
  List<String> get supportedExtensions;
}
