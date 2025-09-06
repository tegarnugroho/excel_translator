// CSV (.csv) file data source
import 'dart:io';
import 'package:table_parser/table_parser.dart';
import '../../domain/entities/entities.dart';
import 'i_file_data_source.dart';

/// CSV (.csv) file data source
class CsvFileDataSource implements IFileDataSource {
  @override
  FileFormat get supportedFormat => FileFormat.csv;

  @override
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.csv');
  }

  @override
  Future<List<LocalizationSheet>> parseFile(String filePath) async {
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
      final languageCodes = headers.skip(1).toList();

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

      // Parse entries
      final translations = <Translation>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final key = row.first.toString();
        if (key.isEmpty) continue;

        final values = <String, String>{};
        for (int j = 0; j < languageCodes.length && j + 1 < row.length; j++) {
          final value = row[j + 1]?.toString() ?? '';
          if (value.isNotEmpty) {
            values[languageCodes[j]] = value;
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
