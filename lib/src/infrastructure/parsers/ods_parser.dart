// ODS file parser
import 'dart:io';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import '../../data/models/models.dart';
import 'base/file_parser_interface.dart';

/// ODS file parser using spreadsheet_decoder
class OdsFileParser implements FileParser {
  @override
  FileFormat get supportedFormat => FileFormat.ods;

  @override
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.ods');
  }

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
