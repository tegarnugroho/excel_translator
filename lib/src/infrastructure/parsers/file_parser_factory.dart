// Factory for creating appropriate file parsers
import 'base/file_parser_interface.dart';
import 'excel_parser.dart';
import 'csv_parser.dart';
import 'ods_parser.dart';

/// Factory for parsing different file formats
class FileParserFactory {
  /// Detect file format from file path
  static FileFormat detectFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return FileFormat.fromExtension(extension);
  }

  /// Create appropriate parser based on file path
  static FileParser createParser(String filePath) {
    final format = detectFormat(filePath);
    switch (format) {
      case FileFormat.xlsx:
        return ExcelFileParser();
      case FileFormat.csv:
        return CsvFileParser();
      case FileFormat.ods:
        return OdsFileParser();
    }
  }
  
  /// Get all available parsers
  static List<FileParser> getAllParsers() {
    return [
      ExcelFileParser(),
      CsvFileParser(),
      OdsFileParser(),
    ];
  }
  
  /// Check if file format is supported
  static bool isSupportedFormat(String filePath) {
    try {
      detectFormat(filePath);
      return true;
    } catch (e) {
      return false;
    }
  }
}
