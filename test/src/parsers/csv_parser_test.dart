import 'dart:convert';

import 'package:excel_translator/src/parsers/csv_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvParser encoding', () {
    const csv = 'key,en,es\n'
        'greeting,Hey! ✨,¡Hola! ✨\n'
        'music,Music,Música\n'
        'mixed,Probe ✨ ú é ñ ç 中,Sonda ✨ ú é ñ ç 中\n';

    late CsvParser parser;

    setUp(() => parser = CsvParser());

    test('decodes UTF-8 bytes without mojibake', () async {
      final sheets = await parser.parseFileFromBytes(utf8.encode(csv));

      final translations = {
        for (final t in sheets.single.translations) t.key: t.values,
      };

      expect(translations['greeting']!['en'], 'Hey! ✨');
      expect(translations['music']!['es'], 'Música');
      expect(translations['mixed']!['en'], 'Probe ✨ ú é ñ ç 中');
    });

    test('emits no Latin-1 mojibake markers', () async {
      final sheets = await parser.parseFileFromBytes(utf8.encode(csv));

      final all = sheets.single.translations
          .expand((t) => t.values.values)
          .join('\n');

      for (final marker in const ['Ã', 'Â', 'â€']) {
        expect(all.contains(marker), isFalse, reason: 'mojibake: $marker');
      }
    });

    test('strips the UTF-8 BOM from the first header cell', () async {
      final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode(csv)];

      final sheets = await parser.parseFileFromBytes(bytes);

      expect(sheets.single.translations.first.key, 'greeting');
    });
  });
}
