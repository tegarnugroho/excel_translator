import 'package:excel_translator/src/generators/sheet_class_generator.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('SheetClassGenerator escaping', () {
    final body = SheetClassGenerator().generateClassBody(buildTrickySheet());

    test('escapes dollar signs so they stay literal text', () {
      expect(body, contains(r"return 'Total: \$100';"));
      expect(body, isNot(contains(r"'Total: $100'")));
    });

    test('neutralizes interpolation-looking values', () {
      expect(body, contains(r"return '\${1 + 1} bad';"));
    });

    test('escapes single quotes', () {
      expect(body, contains(r"return 'He said \'\'\'hi\'\'\'';"));
    });

    test('escapes backslashes', () {
      expect(body, contains(r"return 'C:\\path';"));
    });

    test('escapes newlines instead of emitting a raw line break', () {
      expect(body, contains(r"return 'line1\nline2';"));
    });
  });

  group('SheetClassGenerator interpolation', () {
    final body = SheetClassGenerator().generateClassBody(buildTrickySheet());

    test('collects params from every language, not just the first', () {
      expect(body, contains('String greet({dynamic name}) {'));
      expect(body, contains(r"return 'Halo $name';"));
    });

    test('English value without the placeholder still compiles', () {
      expect(body, contains("return 'Hello';"));
    });

    test('maps positional printf params to named identifiers', () {
      expect(body, contains('String count({dynamic arg1}) {'));
      expect(body, contains(r"return '$arg1 items';"));
    });

    test('camelCases snake_case placeholders', () {
      expect(body, contains('String userLabel({dynamic userName}) {'));
      expect(body, contains(r"return 'Hai $userName';"));
    });

    test('keeps placeholders that are not valid identifiers as text', () {
      expect(body, contains('String get badParam {'));
      expect(body, contains("return '{1+1} x';"));
      expect(body, isNot(contains('dynamic 1+1')));
    });
  });
}
