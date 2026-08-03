import 'package:excel_translator/src/models/models.dart';

/// Sheet covering every value shape that used to break code generation:
/// dollar signs, interpolation-looking text, quotes, backslashes, newlines,
/// placeholders present in one language only, positional printf params and
/// placeholders that cannot be Dart identifiers.
LocalizationSheet buildTrickySheet() {
  return LocalizationSheet(
    name: 'login',
    supportedLanguages: [Language.fromCode('en_US'), Language.fromCode('id')],
    translations: const [
      Translation(
        key: 'price',
        values: {'en_us': r'Total: $100', 'id': r'Total: $100'},
      ),
      Translation(
        key: 'inject',
        values: {'en_us': r'${1 + 1} bad', 'id': r'${1 + 1} bad'},
      ),
      Translation(
        key: 'quote',
        values: {'en_us': "He said '''hi'''", 'id': 'x'},
      ),
      Translation(
        key: 'backslash',
        values: {'en_us': r'C:\path', 'id': r'C:\path'},
      ),
      Translation(
        key: 'multiline',
        values: {'en_us': 'line1\nline2', 'id': 'baris1\nbaris2'},
      ),
      // Placeholder only exists in Indonesian.
      Translation(
        key: 'greet',
        values: {'en_us': 'Hello', 'id': 'Halo {name}'},
      ),
      Translation(
        key: 'count',
        values: {'en_us': r'%1$s items', 'id': r'%1$s barang'},
      ),
      Translation(
        key: 'user_label',
        values: {'en_us': 'Hi {user_name}', 'id': 'Hai {user_name}'},
      ),
      // Not a valid Dart identifier: must stay literal text.
      Translation(
        key: 'bad_param',
        values: {'en_us': '{1+1} x', 'id': '{1+1} y'},
      ),
    ],
  );
}
