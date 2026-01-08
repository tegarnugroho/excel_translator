import 'dart:io';
import 'package:table_parser/table_parser.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'file_parser_interface.dart';

/// CSV (.csv) file parser
class CsvParser implements IFileParser {
  @override
  FileFormat get supportedFormat => FileFormat.csv;

  @override
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.csv');
  }

  @override
  Future<List<LocalizationSheet>> parseFile(String filePath, {LanguageService? languageService}) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('File not found', filePath);
    }

    try {
      var csvContent = file.readAsStringSync();

      // Normalize line endings
      csvContent = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      final decoder = TableParser.decodeCsv(csvContent);
      final table = decoder.tables['Sheet1']!;
      final rows = table.rows;

      if (rows.isEmpty) {
        return [];
      }

      // First row should contain language headers (key, en, id, etc.)
      final headers = rows.first.map((e) => e.toString()).toList();
      if (headers.isEmpty || headers.first.toLowerCase() != 'key') {
        throw FormatException(
            'CSV must start with "key" column followed by language codes');
      }

      // Extract language codes (skip first column which is 'key')
      final allLanguageCodes = headers.skip(1).toList();

      List<String> validLanguageCodes;
      Map<String, int> validCodesWithIndices;

      if (languageService != null) {
        // Filter out invalid language codes and get valid ones with their indices
        validCodesWithIndices = languageService.filterValidLanguageCodes(allLanguageCodes, 'default');
        
        if (validCodesWithIndices.isEmpty) {
          print('⚠️  CSV file: No valid language codes found. Skipping...');
          return [];
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

      // Parse entries
      final translations = <Translation>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final key = row.first.toString();
        if (key.isEmpty) continue;

        final values = <String, String>{};
        
        // Only process columns with valid language codes
        for (final validCode in validLanguageCodes) {
          final originalIndex = validCodesWithIndices[validCode]!;
          final columnIndex = originalIndex + 1; // +1 because originalIndex is header index, but we need data column index
          
          if (columnIndex < row.length) {
            final value = row[columnIndex]?.toString() ?? '';
            if (value.isNotEmpty) {
              values[validCode] = value;
            }
          }
        }

        if (values.isNotEmpty) {
          translations.add(Translation(
            key: key,
            values: values,
          ));
        }
      }

      if (translations.isEmpty) {
        return [];
      }

      return [
        LocalizationSheet(
          name: 'default',
          translations: translations,
          supportedLanguages: languages,
        )
      ];
    } catch (e) {
      throw FormatException('Failed to parse CSV file: $e');
    }
  }
}

