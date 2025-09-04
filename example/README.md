# 📋 Example Project - Excel Translator

Project ini mendemonstrasikan penggunaan **Excel Translator** dengan assets lokal dan testing lengkap.

## 📁 Struktur Folder

```text
example/
├── assets/
│   └── example_localizations.xlsx    # File Excel dengan data lokalisasi
├── lib/
│   ├── main.dart                     # Aplikasi Flutter (opsional)
│   └── generated/                    # Generated localization classes
│       ├── generated_localizations.dart
│       ├── localizations_localizations.dart
│       ├── buttons_localizations.dart
│       └── build_context_extension.dart
├── test/
│   └── localizations_validation_test.dart  # Comprehensive validation test
├── demo.dart                         # Demo standalone
├── test_simple.dart                  # Test sederhana tanpa framework
└── pubspec.yaml                      # Dependencies
```

## 🚀 Cara Generate Localizations

### 1. Menggunakan Command Pendek (Global Install)

```bash
# Install global sekali saja (dari parent folder)
cd ..
dart pub global activate --source path .

# Generate dari example folder
cd example
excel_translator assets/example_localizations.xlsx lib/generated
```

### 2. Menggunakan Package Dependency

```bash
dart run excel_translator assets/example_localizations.xlsx lib/generated
```

### 3. Menggunakan Script Langsung

```bash
dart ../bin/excel_translator.dart assets/example_localizations.xlsx lib/generated
```

## 🎯 Cara Menjalankan Demo

### Demo Standalone

```bash
dart demo.dart
```

### Test Sederhana

```bash
dart test_simple.dart
```

### Validation Test (Comprehensive)

```bash
dart test/localizations_validation_test.dart
```

### Unit Test (Flutter - jika diperlukan)

```bash
flutter test
```

## 📊 Data Excel (example_localizations.xlsx)

File Excel berisi 2 sheets:

### Sheet: localizations

| key | en | id | es |
|-----|----|----|-----|
| hello | Hello | Halo | Hola |
| goodbye | Goodbye | Selamat tinggal | Adiós |
| welcome_message | Welcome {name}! | Selamat datang {name}! | ¡Bienvenido {name}! |
| user_count | You have {count} users | Anda memiliki {count} pengguna | Tienes {count} usuarios |
| app_title | My Amazing App | Aplikasi Menakjubkan Saya | Mi Aplicación Increíble |

### Sheet: buttons

| key | en | id | es |
|-----|----|----|-----|
| submit | Submit | Kirim | Enviar |
| delete | Delete | Hapus | Eliminar |
| edit | Edit | Edit | Editar |
| cancel | Cancel | Batal | Cancelar |

## 💻 Cara Menggunakan Generated Classes

### 1. Import

```dart
import 'lib/generated/generated_localizations.dart';
```

### 2. Basic Usage

```dart
final english = AppLocalizations.english;
final indonesian = AppLocalizations.indonesian;
final spanish = AppLocalizations.spanish;

print(english.localizations.hello);    // "Hello"
print(indonesian.localizations.hello); // "Halo"
print(spanish.localizations.hello);    // "Hola"
```

### 3. Button Translations

```dart
print(english.buttons.submit);      // "Submit"
print(indonesian.buttons.submit);   // "Kirim"
print(spanish.buttons.submit);      // "Enviar"
```

### 4. String Interpolation

```dart
print(english.localizations.welcome_message(name: "John"));
// Output: "Welcome John!"

print(indonesian.localizations.user_count(count: 42));
// Output: "Anda memiliki 42 pengguna"
```

### 5. Dynamic Language

```dart
var loc = AppLocalizations('en');
print(loc.localizations.hello); // "Hello"

loc = AppLocalizations('id');
print(loc.localizations.hello); // "Halo"
```

## 🧪 Testing

Project ini dilengkapi dengan comprehensive testing:

### Test Coverage

- ✅ Language creation dan static helpers
- ✅ Basic translations (hello, goodbye)
- ✅ Button translations (submit, delete, edit)
- ✅ String interpolation (name, count)
- ✅ App titles
- ✅ Fallback untuk bahasa tidak supported
- ✅ Dynamic language switching
- ✅ Sheet class availability
- ✅ Edge cases dengan parameters

### Menjalankan Test

```bash
# Test sederhana (pure Dart)
dart test_simple.dart

# Comprehensive validation test
dart test/localizations_validation_test.dart

# Demo lengkap
dart demo.dart
```

## 🔧 Kustomisasi

### Menambah Bahasa Baru

1. Tambah kolom baru di Excel (misal: `fr` untuk French)
2. Isi translations untuk semua keys
3. Regenerate: `genxl assets/example_localizations.xlsx lib/generated`
4. Gunakan: `AppLocalizations('fr').localizations.hello`

### Menambah Sheet Baru

1. Buat sheet baru di Excel (misal: `messages`)
2. Isi dengan format yang sama
3. Regenerate
4. Gunakan: `AppLocalizations.english.messages.newKey`

### Menambah Key Baru

1. Tambah row baru di Excel dengan key dan translations
2. Regenerate
3. Gunakan method baru yang ter-generate

## 📝 Output Generated Classes

### generated_localizations.dart

Main class dengan static helpers dan property untuk semua sheets.

### [sheet_name]_localizations.dart

Class untuk setiap sheet dengan method untuk setiap key.

### build_context_extension.dart

Extension untuk Flutter (optional, di-comment secara default).

## 🎉 Result Demo

Ketika menjalankan `dart demo.dart`, Anda akan melihat:

- Semua translations dalam 3 bahasa (EN, ID, ES)
- String interpolation examples
- Dynamic language switching
- Semua fitur package bekerja dengan baik

## 💡 Tips

1. **Penamaan Keys**: Gunakan snake_case untuk key di Excel
2. **String Interpolation**: Gunakan `{parameter}` format di Excel
3. **Fallback**: Bahasa tidak supported akan fallback ke bahasa pertama (EN)
4. **Performance**: Generated classes sangat ringan dan cepat
5. **Type Safety**: Semua translations adalah type-safe dengan autocomplete

Selamat menggunakan Excel Translator! 🌟
