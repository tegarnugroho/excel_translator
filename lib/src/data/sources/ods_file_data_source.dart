// ODS file data source
import 'dart:io';
import 'package:table_parser/table_parser.dart';
import '../../domain/entities/entities.dart';
import 'i_file_data_source.dart';

/// ODS file data source using table_parser
class OdsFileDataSource implements IFileDataSource {
  @override
  FileFormat get supportedFormat => FileFormat.ods;

  @override
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.ods');
  }

  @override
  Future<List<LocalizationSheet>> parseFile(String filePath) async {
    final file = File(filePath);
    final bytes = file.readAsBytesSync();

    try {
      final decoder = TableParser.decodeBytes(bytes);
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

        // Create Language entities
        final languages = languageCodes.map((code) {
          final normalizedCode = code.toLowerCase().trim();
          String languageCode;
          String? region;

          if (normalizedCode.contains('_')) {
            final parts = normalizedCode.split('_');
            languageCode = parts[0];
            region = parts.length > 1 ? parts[1] : null;
          } else if (normalizedCode.contains('-')) {
            final parts = normalizedCode.split('-');
            languageCode = parts[0];
            region = parts.length > 1 ? parts[1] : null;
          } else {
            languageCode = normalizedCode;
            region = null;
          }

          return Language(
            code: languageCode,
            name: languageCode, // Will be resolved by validation repository
            region: region,
          );
        }).toList();

        // Parse data rows
        final translations = <Translation>[];
        for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
          final row = rows[rowIndex];
          if (row.isEmpty) continue;

          final keyCell = row[0];
          if (keyCell == null || keyCell.toString().isEmpty) continue;

          final key = keyCell.toString();
          final values = <String, String>{};

          for (int i = 0; i < languageCodes.length && i + 1 < row.length; i++) {
            final cell = row[i + 1];
            if (cell != null && cell.toString().isNotEmpty) {
              values[languageCodes[i]] = cell.toString();
            }
          }

          if (values.isNotEmpty) {
            translations.add(Translation(key: key, values: values));
          }
        }

        if (translations.isNotEmpty) {
          sheets.add(LocalizationSheet(
            name: tableName,
            translations: translations,
            supportedLanguages: languages,
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
