import 'dart:io';
import 'package:table_parser/table_parser.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'file_parser_interface.dart';

/// Excel (.xlsx) file parser
class ExcelParser implements IFileParser {
  @override
  FileFormat get supportedFormat => FileFormat.xlsx;

  @override
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.xlsx');
  }

  @override
  Future<List<LocalizationSheet>> parseFile(
    String filePath, {
    LanguageService? languageService,
  }) async {
    final file = File(filePath);
    final bytes = file.readAsBytesSync();
    return parseFileFromBytes(bytes, languageService: languageService);
  }

  @override
  Future<List<LocalizationSheet>> parseFileFromBytes(
    List<int> bytes, {
    LanguageService? languageService,
  }) async {
    final decoder = TableParser.decodeBytes(bytes);
    return _parseTables(decoder.tables, languageService);
  }

  List<LocalizationSheet> _parseTables(
    Map<String, dynamic> tables,
    LanguageService? languageService,
  ) {
    List<LocalizationSheet> sheets = [];

    for (final tableName in tables.keys) {
      final table = tables[tableName]!;
      final rows = table.rows;

      if (rows.isEmpty) continue;

      // Get header row (language codes)
      final headerRow = rows.first;
      final allLanguageCodes = <String>[];

      for (int i = 1; i < headerRow.length; i++) {
        final cell = headerRow[i];
        if (cell != null) {
          allLanguageCodes.add(cell.toString());
        }
      }

      if (allLanguageCodes.isEmpty) continue;

      List<String> validLanguageCodes;
      Map<String, int> validCodesWithIndices;

      if (languageService != null) {
        // Filter out invalid language codes and get valid ones with their indices
        validCodesWithIndices = languageService.filterValidLanguageCodes(
          allLanguageCodes,
          tableName,
        );

        if (validCodesWithIndices.isEmpty) {
          print(
            '⚠️  Sheet "$tableName": No valid language codes found. Skipping sheet...',
          );
          continue;
        }

        validLanguageCodes = validCodesWithIndices.keys.toList();
      } else {
        // No validation - use all language codes
        validLanguageCodes = allLanguageCodes;
        validCodesWithIndices = <String, int>{};
        for (int i = 0; i < allLanguageCodes.length; i++) {
          validCodesWithIndices[allLanguageCodes[i]] = i;
        }
      }

      // Create Language entities only for valid codes
      final languages = validLanguageCodes.map((code) {
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
        if (keyCell == null) continue;

        final key = keyCell.toString();
        final values = <String, String>{};

        // Only process columns with valid language codes
        for (final validCode in validLanguageCodes) {
          final originalIndex = validCodesWithIndices[validCode]!;
          final columnIndex =
              originalIndex +
              1; // +1 because originalIndex is 0-based header index, but we need 1-based for data

          if (columnIndex < row.length) {
            final cell = row[columnIndex];
            if (cell != null) {
              values[validCode] = cell.toString();
            }
          }
        }

        if (values.isNotEmpty) {
          translations.add(Translation(key: key, values: values));
        }
      }

      if (translations.isNotEmpty) {
        sheets.add(
          LocalizationSheet(
            name: tableName,
            translations: translations,
            supportedLanguages: languages,
          ),
        );
      }
    }

    return sheets;
  }
}
