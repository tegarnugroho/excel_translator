import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../models/models.dart';

/// Supported file formats
enum FileFormat { xlsx, csv, ods }

/// Factory for parsing different file formats
class FileParserFactory {
  static FileFormat detectFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'xlsx':
        return FileFormat.xlsx;
      case 'csv':
        return FileFormat.csv;
      case 'ods':
        return FileFormat.ods;
      default:
        throw UnsupportedError(
            'Unsupported file format: .$extension. Supported formats: .xlsx, .csv, .ods');
    }
  }

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
}

/// Base class for file parsers
abstract class FileParser {
  List<LocalizationSheet> parseFile(String filePath);
}

/// Excel (.xlsx) file parser
class ExcelFileParser implements FileParser {
  @override
  List<LocalizationSheet> parseFile(String filePath) {
    final file = File(filePath);
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    List<LocalizationSheet> sheets = [];

    for (final tableName in excel.tables.keys) {
      final table = excel.tables[tableName]!;
      final rows = table.rows;

      if (rows.isEmpty) continue;

      // Get header row (language codes)
      final headerRow = rows.first;
      final languageCodes = <String>[];

      for (int i = 1; i < headerRow.length; i++) {
        final cell = headerRow[i];
        if (cell?.value != null) {
          languageCodes.add(cell!.value.toString());
        }
      }

      if (languageCodes.isEmpty) continue;

      // Parse data rows
      final entries = <LocalizationEntry>[];
      for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
        final row = rows[rowIndex];
        if (row.isEmpty) continue;

        final keyCell = row[0];
        if (keyCell?.value == null) continue;

        final key = keyCell!.value.toString();
        final translations = <String, String>{};

        for (int i = 0; i < languageCodes.length && i + 1 < row.length; i++) {
          final cell = row[i + 1];
          if (cell?.value != null) {
            translations[languageCodes[i]] = cell!.value.toString();
          }
        }

        if (translations.isNotEmpty) {
          entries.add(LocalizationEntry(key: key, translations: translations));
        }
      }

      if (entries.isNotEmpty) {
        sheets.add(LocalizationSheet(
          name: tableName,
          entries: entries,
          languageCodes: languageCodes,
        ));
      }
    }

    return sheets;
  }
}

/// CSV file parser
class CsvFileParser implements FileParser {
  @override
  List<LocalizationSheet> parseFile(String filePath) {
    final file = File(filePath);
    var csvContent = file.readAsStringSync();
    
    // Normalize line endings
    csvContent = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    
    final rows = const CsvToListConverter().convert(csvContent, eol: '\n');

    if (rows.isEmpty) {
      throw Exception('CSV file is empty');
    }

    // Get header row (language codes)
    final headerRow = rows.first;
    final languageCodes = <String>[];

    for (int i = 1; i < headerRow.length; i++) {
      if (headerRow[i] != null && headerRow[i].toString().isNotEmpty) {
        languageCodes.add(headerRow[i].toString());
      }
    }

    if (languageCodes.isEmpty) {
      throw Exception('No language codes found in CSV header');
    }

    // Parse data rows
    final entries = <LocalizationEntry>[];
    for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      if (row.isEmpty) continue;

      final key = row[0]?.toString();
      if (key == null || key.isEmpty) continue;

      final translations = <String, String>{};

      for (int i = 0; i < languageCodes.length && i + 1 < row.length; i++) {
        final value = row[i + 1]?.toString();
        if (value != null && value.isNotEmpty) {
          translations[languageCodes[i]] = value;
        }
      }

      if (translations.isNotEmpty) {
        entries.add(LocalizationEntry(key: key, translations: translations));
      }
    }

    if (entries.isEmpty) {
      throw Exception('No valid entries found in CSV file');
    }

    // CSV files are treated as single sheet
    final sheetName = filePath.split('/').last.split('.').first;
    return [LocalizationSheet(
      name: sheetName,
      entries: entries,
      languageCodes: languageCodes,
    )];
  }
}

/// ODS file parser (basic implementation)
class OdsFileParser implements FileParser {
  @override
  List<LocalizationSheet> parseFile(String filePath) {
    // For now, throw an informative error
    // Full ODS support would require XML parsing
    throw UnsupportedError(
        'ODS format support is planned for future release. '
        'Please convert your ODS file to Excel (.xlsx) or CSV (.csv) format for now. '
        'You can do this in LibreOffice: File > Save As > Excel format or CSV format.');
  }
}
