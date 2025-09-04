import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import '../models/models.dart';

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

/// Factory for parsing different file formats
class FileParserFactory {
  static FileFormat detectFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return FileFormat.fromExtension(extension);
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

/// ODS file parser using spreadsheet_decoder
class OdsFileParser implements FileParser {
  @override
  List<LocalizationSheet> parseFile(String filePath) {
    final file = File(filePath);
    final bytes = file.readAsBytesSync();
    
    try {
      final decoder = SpreadsheetDecoder.decodeBytes(bytes);
      List<LocalizationSheet> sheets = [];

      for (final tableName in decoder.tables.keys) {
        final table = decoder.tables[tableName]!;
        final rows = table.rows;

        if (rows.isEmpty) continue;

        // Get header row (language codes)
        final headerRow = rows.first;
        final languageCodes = <String>[];

        for (int i = 1; i < headerRow.length; i++) {
          final cell = headerRow[i];
          if (cell != null && cell.toString().isNotEmpty) {
            languageCodes.add(cell.toString());
          }
        }

        if (languageCodes.isEmpty) continue;

        // Parse data rows
        final entries = <LocalizationEntry>[];
        for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
          final row = rows[rowIndex];
          if (row.isEmpty) continue;

          final keyCell = row[0];
          if (keyCell == null || keyCell.toString().isEmpty) continue;

          final key = keyCell.toString();
          final translations = <String, String>{};

          for (int i = 0; i < languageCodes.length && i + 1 < row.length; i++) {
            final cell = row[i + 1];
            if (cell != null && cell.toString().isNotEmpty) {
              translations[languageCodes[i]] = cell.toString();
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

      if (sheets.isEmpty) {
        throw Exception('No valid sheets found in ODS file');
      }

      return sheets;
    } catch (e) {
      throw Exception('Failed to parse ODS file: $e');
    }
  }
}
