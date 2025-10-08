# Excel Translator - Multi-Format Localizations

Generate type-safe Flutter/Dart localizations from multiple file formats (Excel, CSV, ODS) with automatic language validation and modern Dart conventions.

## Features

- 📊 **Multi-format support** - Excel (.xlsx), CSV (.csv), and ODS (.ods) files
- 📋 **Multi-sheet support** - Organize translations by feature/category (Excel & ODS)
- 🎯 **Type-safe generated code** - Compile-time safety with auto-completion
- 🔤 **String interpolation** - Dynamic values using `{variable}` or `%variable$s` syntax
- 🌍 **184+ language codes** - Full ISO 639-1 support with country variants
- 🐪 **CamelCase methods** - Modern naming (app_title → appTitle)
- ✅ **Automatic validation** - Validates language codes with helpful error messages
- 🚀 **Zero-config CLI** - Works with pubspec.yaml configuration

## Supported Formats

| Format | Extension | Multi-sheet | Best for |
|--------|-----------|-------------|----------|
| **Excel** | `.xlsx` | ✅ | Complex projects with multiple categories |
| **CSV** | `.csv` | ❌ | Simple projects, version control friendly |
| **ODS** | `.ods` | ✅ | Open-source projects, LibreOffice users |

All formats support the same feature set including string interpolation, language validation, and type-safe code generation.

## Installation

```yaml
dependencies:
  excel_translator: ^1.0.6
```

## Quick Start

### 1. Create Your Localization File

Choose your preferred format and create a file with language codes in the header row:

#### Excel (.xlsx) - Best for complex projects

| key | en | id | es |
|-----|----|----|-----|
| hello | Hello | Halo | Hola |
| app_title | My App | Aplikasi Saya | Mi App |
| welcome_message | Welcome {name}! | Selamat datang {name}! | ¡Bienvenido {name}! |

#### CSV (.csv) - Best for simple projects

```csv
key,en,id,es
hello,Hello,Halo,Hola
app_title,My App,Aplikasi Saya,Mi App
welcome_message,Welcome {name}!,Selamat datang {name}!,¡Bienvenido {name}!
```

#### ODS (.ods) - Best for open-source projects

OpenDocument Spreadsheet format (LibreOffice Calc) with the same structure as Excel.

### 2. Configure (Optional)

Add to `pubspec.yaml`:

```yaml
excel_translator:
  excel_file: assets/localizations.xlsx  # or .csv, .ods
  output_directory: lib/generated
  class_name: AppLocalizations
```

### 3. Generate

#### Option A: Project-level (recommended)

```bash
# Simple - uses pubspec.yaml config
dart run excel_translator

# Or specify parameters for any format
dart run excel_translator assets/localizations.xlsx lib/generated  # Excel
dart run excel_translator assets/localizations.csv lib/generated   # CSV
dart run excel_translator assets/localizations.ods lib/generated   # ODS
```

#### Option B: Global installation (run anywhere)

```bash
# Install globally from pub.dev
dart pub global activate excel_translator

# Now you can run directly without "dart run" - supports all formats
excel_translator assets/localizations.xlsx
excel_translator assets/localizations.csv  
excel_translator assets/localizations.ods

# Use with parameters
excel_translator assets/localizations.xlsx lib/generated

# To uninstall globally
dart pub global deactivate excel_translator
```

### 4. Use Generated Code

#### Traditional Usage (with BuildContext)

```dart
import 'lib/generated/generated_localizations.dart';

// In Flutter widgets
Widget build(BuildContext context) {
  return Text(AppLocalizations.of(context).sheet.hello);
}

// Access specific language
final loc = AppLocalizations.english;
print(loc.sheet.hello);           // "Hello"
print(loc.sheet.appTitle);        // "My App" (camelCase from app_title)

// String interpolation
print(loc.sheet.welcomeMessage(name: "John")); // "Welcome John!"
```

#### Global Instance Usage (without BuildContext)

For repositories, services, or any non-UI code that needs translations:

```dart
import 'lib/generated/generated_localizations.dart';

// Simple current language detection (no initialization needed)
class UserRepository {
  void validateUser() {
    final errorMsg = AppLocalizations.current.sheet.invalidUser;
    throw Exception(errorMsg);
  }
}

// Or with explicit initialization in main.dart
void main() {
  // Option 1: Auto-detect system language
  AppLocalizations.initializeGlobal();
  
  // Option 2: Set specific language
  AppLocalizations.initializeGlobalWithLanguage('en');
  
  // Option 3: Initialize from context (in widget)
  AppLocalizations.initializeGlobalFromContext(context);
  
  runApp(MyApp());
}

// Use global instance anywhere without context
class OrderService {
  void processOrder() {
    final successMsg = AppLocalizations.instance.sheet.orderSuccess;
    print(successMsg);
  }
}

// Runtime language switching
AppLocalizations.updateGlobalLanguage('id'); // Switch to Indonesian
```

#### Flutter App Setup

```dart
MaterialApp(
  localizationsDelegates: const [
    ...AppLocalizations.delegates,
  ],
  supportedLocales: AppLocalizations.supportedLanguages
      .map((language) => Locale(language))
      .toList(),
  // ...
)
```

## Excel File Format

### Single Sheet Example

| key | en | id | es |
|-----|----|----|-----|
| title | Home | Beranda | Inicio |
| save_button | Save | Simpan | Guardar |

### Multi-Sheet Example

**Sheet "login":**

| key | en | id |
|-----|----|----|
| title | Login | Masuk |
| forgot_password | Forgot Password? | Lupa Kata Sandi? |

**Sheet "buttons":**

| key | en | id |
|-----|----|----|
| submit | Submit | Kirim |
| cancel | Cancel | Batal |

Generates:

```dart
final loc = AppLocalizations.english;
print(loc.login.title);           // "Login"
print(loc.login.forgotPassword);  // "Forgot Password?" (camelCase)
print(loc.buttons.submit);        // "Submit"
```

## Global Instance Benefits

The global instance feature allows you to access translations anywhere in your app without requiring a `BuildContext`. This is particularly useful for:

### Use Cases

- **Repository Layer**: Access error messages in data repositories
- **Service Classes**: Localize API error responses or validation messages
- **Business Logic**: Add localized messages in use cases or domain services
- **Background Tasks**: Use translations in isolates or background processes
- **Utility Functions**: Helper functions that need localized strings

### Key Features

- **Two Access Patterns**:
  - `AppLocalizations.current` - Simple, no initialization required
  - `AppLocalizations.instance` - Global singleton with initialization control
- **System Language Detection**: Automatically detects device language
- **Runtime Language Switching**: Change language without rebuilding widgets
- **Fallback Support**: Falls back to default language if requested language not available
- **Thread Safe**: Safe to use in isolates and background tasks
- **No Context Required**: Access translations in any Dart class

### Example: Repository with Localized Errors

```dart
class AuthRepository {
  Future<User> login(String email, String password) async {
    try {
      // API call
      return await api.login(email, password);
    } catch (e) {
      // Option 1: Simple current language detection (no setup required)
      throw Exception(AppLocalizations.current.errors.loginFailed);
      
      // Option 2: Using global instance (requires initialization)
      // throw Exception(AppLocalizations.instance.errors.loginFailed);
    }
  }
}
```

## Language Support

Supports 184+ ISO 639-1 language codes including:

- Basic codes: `en`, `id`, `es`, `fr`, `de`, `ja`, `ko`, `zh`
- Locale formats: `en_US`, `pt_BR`, `zh_CN`, `en-US`
- Comprehensive validation with helpful error messages

## CLI Options

### Project-level usage

```bash
# Zero-config (uses pubspec.yaml)
dart run excel_translator

# Full command
dart run excel_translator [excel_file] [output_dir] [options]
```

### Global installation

```bash
# Install globally
dart pub global activate excel_translator

# Use anywhere without "dart run"
excel_translator

# With parameters
excel_translator [excel_file] [output_dir] [options]

# Uninstall
dart pub global deactivate excel_translator
```

### Options

```bash
Options:
  -c, --class-name=<name>     Generated class name (default: AppLocalizations)
  -d, --delegates             Include Flutter delegates (default: true)
  -h, --help                  Show help
```

## Generated Code Structure

```text
lib/generated/
├── generated_localizations.dart     # Main class with delegates
├── build_context_extension.dart     # context.loc extension
├── sheet1_localizations.dart        # Sheet-specific classes
└── sheet2_localizations.dart        # ...
```

## Requirements

- Dart SDK 2.17+
- Flutter 3.0+ (for Flutter projects)
- Excel files in .xlsx format

## License

MIT License
