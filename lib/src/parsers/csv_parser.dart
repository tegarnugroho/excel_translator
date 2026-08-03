import 'dart:convert';
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
    // Decode as UTF-8. Using String.fromCharCodes here would treat each byte as
    // a code unit (Latin-1), turning every non-ASCII character into mojibake.
    var csvContent = utf8.decode(bytes);

    // Strip the UTF-8 BOM that Excel/Google Sheets exports often prepend;
    // otherwise it sticks to the first header cell and breaks the 'key' check.
    if (csvContent.isNotEmpty && csvContent.codeUnitAt(0) == 0xFEFF) {
      csvContent = csvContent.substring(1);
    }

    return _parseCsv(csvContent, languageService);
  }

  List<LocalizationSheet> _parseCsv(
    String csvContent,
    LanguageService? languageService,
  ) {
    // Normalize line endings
    final normalizedContent = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    final decoder = TableParser.decodeCsv(
      normalizedContent,
      textDelimiter: '"',
    );
    final table = decoder.tables['Sheet1']!;
    final rows = table.rows;

    if (rows.isEmpty) {
      return [];
    }

    // First row should contain language headers (key, en, id, etc.)
    final headers = rows.first.map((e) => e.toString()).toList();
    if (headers.isEmpty || headers.first.toLowerCase() != 'key') {
      throw FormatException(
        'CSV must start with "key" column followed by language codes',
      );
    }

    // Extract language codes (skip first column which is 'key')
    final allLanguageCodes = headers.skip(1).toList();

    List<String> validLanguageCodes;
    Map<String, int> validCodesWithIndices;

    if (languageService != null) {
      // Filter out invalid language codes and get valid ones with their indices
      validCodesWithIndices = languageService.filterValidLanguageCodes(
        allLanguageCodes,
        'default',
      );

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
    final languages = validLanguageCodes.map(Language.fromCode).toList();

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
        final columnIndex =
            originalIndex +
            1; // +1 because originalIndex is header index, but we need data column index

        if (columnIndex < row.length) {
          final value = row[columnIndex]?.toString() ?? '';
          if (value.isNotEmpty) {
            values[Language.normalizeCode(validCode)] = value;
          }
        }
      }

      if (values.isNotEmpty) {
        translations.add(Translation(key: key, values: values));
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
      ),
    ];
  }
}
