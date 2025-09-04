// CSV (.csv) file parser
import 'dart:io';
import 'package:csv/csv.dart';
import '../../data/models/models.dart';
import 'base/file_parser_interface.dart';

/// CSV (.csv) file parser
class CsvFileParser implements FileParser {
  @override
  FileFormat get supportedFormat => FileFormat.csv;

  @override
  bool isValidFile(String filePath) {
    return filePath.toLowerCase().endsWith('.csv');
  }

  @override
  List<LocalizationSheet> parseFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('File not found', filePath);
    }

    try {
      final csvContent = file.readAsStringSync();
      final rows = const CsvToListConverter().convert(csvContent, eol: '\n');

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

      // Parse entries
      final entries = <LocalizationEntry>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        final key = row.first.toString();
        if (key.isEmpty) continue;

        final translations = <String, String>{};
        for (int j = 0; j < languageCodes.length && j + 1 < row.length; j++) {
          final value = row[j + 1]?.toString() ?? '';
          if (value.isNotEmpty) {
            translations[languageCodes[j]] = value;
          }
        }

        if (translations.isNotEmpty) {
          entries.add(LocalizationEntry(
            key: key,
            translations: translations,
          ));
        }
      }

      if (entries.isEmpty) {
        return [];
      }

      return [
        LocalizationSheet(
          name: 'default',
          entries: entries,
          languageCodes: languageCodes,
        )
      ];
    } catch (e) {
      throw FormatException('Failed to parse CSV file: $e');
    }
  }
}
