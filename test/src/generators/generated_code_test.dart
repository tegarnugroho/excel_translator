import 'dart:convert';
import 'dart:io';

import 'package:excel_translator/src/generators/main_class_generator.dart';
import 'package:excel_translator/src/generators/sheet_class_generator.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

/// Printed by the generated program; keeps every assertion on one line so a
/// multi-line translation cannot shift the output.
const _harness = '''
void main() {
  final en = AppLocalizations('en_us');
  final id = AppLocalizations('id');

  print('price=' + en.login.price);
  print('inject=' + id.login.inject);
  print('quote=' + en.login.quote);
  print('backslash=' + id.login.backslash);
  print('multiline=' + id.login.multiline.replaceAll('\\n', '|'));
  print('greetId=' + id.login.greet(name: 'Budi'));
  print('greetEn=' + en.login.greet(name: 'Budi'));
  print('count=' + id.login.count(arg1: 3));
  print('userLabel=' + id.login.userLabel(userName: 'Tegar'));
  print('badParam=' + id.login.badParam);
  print('resolveExact=' + AppLocalizations.resolveLanguage('en-US').toString());
  print('resolveBase=' + AppLocalizations.resolveLanguage('en').toString());
  print('resolveVariant=' + AppLocalizations.resolveLanguage('id_ID').toString());
  print('resolveUnknown=' + AppLocalizations.resolveLanguage('fr').toString());
}
''';

void main() {
  late Directory tempDir;
  late File generatedFile;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('excel_translator_codegen');
    final sheet = buildTrickySheet();

    final buffer = StringBuffer()
      ..write(SheetClassGenerator().generateClassBody(sheet))
      ..writeln()
      ..write(
        MainClassGenerator().generateClassAndDelegate(
          [sheet],
          'AppLocalizations',
          false,
        ),
      )
      ..writeln()
      ..writeln(_harness);

    generatedFile = File('${tempDir.path}/generated.dart')
      ..writeAsStringSync(buffer.toString());
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
    'generated code passes dart analyze',
    () {
      final result = Process.runSync(
        'dart',
        ['analyze', tempDir.path],
        runInShell: true,
      );

      expect(
        result.exitCode,
        0,
        reason: '${result.stdout}\n${result.stderr}\n\n'
            '${generatedFile.readAsStringSync()}',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'generated code returns the original values at runtime',
    () {
      final result = Process.runSync(
        'dart',
        ['run', generatedFile.path],
        runInShell: true,
      );

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

      final lines = const LineSplitter()
          .convert(result.stdout as String)
          .where((line) => line.contains('='))
          .toList();
      final output = {
        for (final line in lines)
          line.substring(0, line.indexOf('=')): line.substring(
            line.indexOf('=') + 1,
          ),
      };

      expect(output['price'], r'Total: $100');
      expect(output['inject'], r'${1 + 1} bad');
      expect(output['quote'], "He said '''hi'''");
      expect(output['backslash'], r'C:\path');
      expect(output['multiline'], 'baris1|baris2');
      expect(output['greetId'], 'Halo Budi');
      // No placeholder in the English value: the param is simply unused.
      expect(output['greetEn'], 'Hello');
      expect(output['count'], '3 barang');
      expect(output['userLabel'], 'Hai Tegar');
      expect(output['badParam'], '{1+1} y');

      // Country variants resolve instead of silently falling through.
      expect(output['resolveExact'], 'en_us');
      expect(output['resolveBase'], 'en_us');
      expect(output['resolveVariant'], 'id');
      expect(output['resolveUnknown'], 'null');
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
