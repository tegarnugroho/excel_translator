// Excel (.xlsx) file parser
import 'dart:io';
import 'package:excel/excel.dart';
import '../../data/models/models.dart';
import 'base/file_parser_interface.dart';

/// Excel (.xlsx) file parser
class ExcelFileParser implements FileParser {
  @override
  FileFormat get supportedFormat => FileFormat.xlsx;

  @override
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.xlsx');
  }

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
