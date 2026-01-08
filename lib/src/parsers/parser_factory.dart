import 'file_parser_interface.dart';
import 'excel_parser.dart';
import 'csv_parser.dart';
import 'ods_parser.dart';

/// Factory for creating appropriate file parsers
class FileParserFactory {
  static final Map<FileFormat, IFileParser> _parsers = {
    FileFormat.xlsx: ExcelParser(),
    FileFormat.csv: CsvParser(),
    FileFormat.ods: OdsParser(),
  };

  /// Detect file format from file path
  static FileFormat detectFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return FileFormat.fromExtension(extension);
  }

  /// Create appropriate parser based on file path
  static IFileParser createParser(String filePath) {
    final format = detectFormat(filePath);
    final parser = _parsers[format];
    if (parser == null) {
      throw UnsupportedError('No parser available for format: $format');
    }
    return parser;
  }

  /// Get all available parsers
  static List<IFileParser> getAllParsers() {
    return _parsers.values.toList();
  }

  /// Check if file format is supported
  static bool isSupportedFormat(String filePath) {
    try {
      final format = detectFormat(filePath);
      return _parsers.containsKey(format);
    } catch (e) {
      return false;
    }
  }

  /// Get supported extensions
  static List<String> get supportedExtensions {
    return FileFormat.values.map((f) => f.extension).toList();
  }
}
