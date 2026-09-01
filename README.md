# excel_translator

*Type-safe Flutter & Dart localizations, generated from a spreadsheet.*

[![pub package](https://img.shields.io/pub/v/excel_translator.svg)](https://pub.dev/packages/excel_translator)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Dart SDK](https://img.shields.io/badge/dart-%3E%3D3.8.0-blue)](https://dart.dev)

---

Use one workbook or separate translation files per feature. Each sheet or CSV filename becomes a module (`login`, `home`, `buttons`). Get compile-time safe Dart classes with IDE auto-completion. No `.arb` files, no boilerplate.

```dart
loc.login.title                          // "Login"
loc.login.welcomeMessage(name: 'Alice')  // "Welcome Alice!"
loc.buttons.submit                       // "Submit"
```

## Highlights

| Feature | Details |
| --- | --- |
| **Formats** | `.xlsx`, `.csv`, `.ods` |
| **Multi-sheet** | One class per sheet (Excel & ODS) |
| **Type safety** | Compile-time checks, auto-completion, camelCase accessors (`app_title` -> `.appTitle`) |
| **Interpolation** | `{variable}` and `%variable$s` |
| **Languages** | 184+ ISO 639-1 codes with country variants (`en_US`, `pt_BR`, `zh_CN`), validated at generation time |
| **Access** | `of(context)`, `AppLocalizations('id')`, or `AppLocalizations.current` (no `BuildContext` needed) |
| **Config** | Zero-config, reads `pubspec.yaml` |
| **Watch mode** | Auto-regenerate via `build_runner` |

## Install

```yaml
dependencies:
  excel_translator: ^2.2.0

dev_dependencies:
  build_runner: ^2.4.0   # only for watch mode
```

```bash
dart pub get
```

## Quick Start

**1. Build the spreadsheet.** First column must be `key`; the rest are language codes.

Sheet `login`:

| key | en | id | es |
| --- | --- | --- | --- |
| `title` | Login | Masuk | Iniciar sesion |
| `forgot_password` | Forgot Password? | Lupa Kata Sandi? | Olvido su contrasena? |
| `welcome_message` | Welcome {name}! | Selamat datang {name}! | Bienvenido {name}! |

Sheet `buttons`:

| key | en | id | es |
| --- | --- | --- | --- |
| `submit` | Submit | Kirim | Enviar |
| `cancel` | Cancel | Batal | Cancelar |

Each CSV contains one module:

```csv
key,en,id,es
title,Login,Masuk,"Iniciar sesion"
```

**2. Configure `pubspec.yaml`.**

Single workbook (its XLSX/ODS sheets become modules):

```yaml
excel_translator:
  excel_file: assets/localizations.xlsx   # .xlsx, .csv, or .ods
  output_dir: lib/generated
  class_name: AppLocalizations            # optional
  include_flutter_delegates: true         # optional
```

Or multiple feature files. CSV module names come from filenames:

```yaml
excel_translator:
  files:
    - assets/translations/common.csv
    - assets/translations/auth.csv
    - assets/translations/home_explore.csv
    - assets/translations/events.csv
  output_dir: lib/generated
  class_name: AppLocalizations
  multi_file: true
```

`common.csv` becomes `loc.common`, `auth.csv` becomes `loc.auth`, and
`home_explore.csv` becomes `loc.homeExplore`. Mixed formats are supported:
CSV filenames supply module names, while XLSX and ODS retain their sheet names.
Configure either `excel_file` or `files`, never both. `files` controls inputs;
`multi_file` independently controls generated Dart output organization.

**3. Generate.**

```bash
dart run excel_translator          # CLI, recommended
dart run build_runner watch        # or watch mode
```

**4. Use it.**

```dart
import 'generated/generated_localizations.dart';

final loc = AppLocalizations.of(context);   // from a widget
final id  = AppLocalizations('id');         // by language code
AppLocalizations.current.login.title;       // system language, no context
AppLocalizations.english.login.title;       // named getters, first 5 languages
```

**5. Wire up Flutter.**

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.delegates,
  supportedLocales: AppLocalizations.supportedLanguages
      .map(Locale.new)
      .toList(),
);
```

## Spreadsheet Rules

- First column must be `key`; remaining columns are ISO 639-1 language codes, validated at generation time.
- Sheet names become class and property names, sanitized to camelCase: `My Sheet` -> `.mySheet`.
- Empty rows are skipped. A missing translation falls back to the first available language for that key; no exception is thrown.
- Use `snake_case`, self-documenting keys (`login_title`, not `lt`). Avoid Dart reserved words.
- Put your fallback language (usually `en`) in the first language column.

## CLI

```bash
dart run excel_translator                                            # zero-config
dart run excel_translator assets/localizations.xlsx lib/generated    # explicit paths
dart run excel_translator log                                        # print current config
```

| Flag | Short | Default | Description |
| --- | --- | --- | --- |
| `--class-name=NAME` | `-c` | `AppLocalizations` | Root class name |
| `--delegates=BOOL` | `-d` | `true` | Toggle Flutter delegates |
| `--no-delegates` | `-nd` | - | Pure-Dart output, no Flutter dependency |
| `--help` | `-h` | - | Show help |
| `--version` | `-v` | - | Show version |

Install globally to run from anywhere:

```bash
dart pub global activate excel_translator
excel_translator assets/l10n.csv lib/generated --class-name=L10n
dart pub global deactivate excel_translator
```

## Two Modes, Two Layouts

Both modes read the same spreadsheet and produce equivalent, fully functional code. They differ in **how many files they emit**.

```text
CLI                                  build_runner
--------------------------------     --------------------------------
generated_localizations.dart         generated_localizations.dart
build_context_extension.dart         build_context_extension.dart
login_localizations.dart      \
buttons_localizations.dart     |-- per sheet   (all sheet classes inlined
errors_localizations.dart     /                 into the main file)
```

| Aspect | CLI | build_runner |
| --- | --- | --- |
| Output | 1 file per sheet + 2 | Always exactly 2 |
| Output dir | Anywhere | Fixed at `lib/generated` |
| CLI flags | All supported | None, use `pubspec.yaml` |
| Watch mode | No | **Yes** |
| Best for | CI, code review, production | Local development |

**Recommendation:** `build_runner watch` while translating, `dart run excel_translator` before you commit. Commit the generated files: the app then builds without the generator, and per-sheet diffs stay reviewable.

```bash
dart run build_runner build --delete-conflicting-outputs   # force rebuild
```

> **Note:** Both modes write to `lib/generated/`. Running one after the other leaves stale files behind. Pick one as canonical and delete the other's output.

## Why build_runner Cannot Emit Per-Sheet Files

A fundamental constraint of the `build` package, not a bug here.

Every builder must declare its outputs **before the build runs**, as a compile-time constant:

```dart
@override
final buildExtensions = const {
  'pubspec.yaml': [
    'lib/generated/generated_localizations.dart',
    'lib/generated/build_context_extension.dart',
  ],
};
```

`build_runner` uses that declaration to construct its asset graph and decide what to invalidate. But sheet names live inside the spreadsheet: the string `"login"` is only discovered during parsing, inside `build()`:

```text
build graph construction -> buildExtensions evaluated    <- sheet names unknown
build execution          -> build() runs, file parsed    <- sheet names known
```

Writing to an undeclared asset path is rejected by the build system, and there is no way to compute the output list at runtime. The builder resolves this by inlining every sheet class into one pre-declared filename: dynamic content, static name.

The same reason fixes `output_dir` at `lib/generated` for this mode: those paths are `const` in `builder.dart`. Setting a different `output_dir` in `pubspec.yaml` changes the generated file's content, not its location on disk.

The CLI is a plain Dart script with full filesystem access, so it parses first and writes second. **Per-sheet output requires the CLI. There is no workaround.**

## Limitations

- **build_runner cannot produce per-sheet files**, and its `output_dir` is fixed at `lib/generated`. See the section above.
- **Prefer the CLI in CI.** `build_runner` is a development tool: extra dev dependency, cache-invalidation overhead on cold builds, and merged output that makes translation diffs harder to review.
- **Input module names must be unique.** CSV filenames and XLSX/ODS sheet names cannot normalize to the same Dart accessor.
- **Sheet names are public API.** Renaming a sheet is a breaking change for every call site (`loc.login.title`). Settle your naming convention early.
- **Named language getters cap at 5.** `AppLocalizations.english` / `.en` are generated for the first 5 languages only, to bound code growth. Everything else stays reachable via `AppLocalizations('fr')` or `.current`.
- **Each CSV is one module.** Use `files` to organize localization per feature.

## FAQ

**Can I use this without Flutter?**
Yes. Pass `--no-delegates`, or set `include_flutter_delegates: false`. The generated classes have no Flutter dependency.

**How do I add a language?**
Add a column with the ISO 639-1 code as its header, then re-run the generator. It appears in `supportedLanguages` immediately.

**What if a translation is missing?**
The generated `switch` has a `default:` case falling back to the first language value for that key. No exception.

**Can I rename the root class?**
Yes. Use `--class-name=MyL10n`, or `class_name: MyL10n` in `pubspec.yaml`.

**Should I commit the generated files?**
Yes. The project then builds without the generator, and the diffs are reviewable in pull requests. Each file is marked `// GENERATED CODE - DO NOT MODIFY BY HAND`.

**How fast is it?**
Parse time scales with total key count, not sheet count: a 50-sheet workbook with 20 keys each beats a 1-sheet workbook with 10,000. Generation itself is negligible. Generated code uses `switch` rather than maps: jump tables, no heap allocation, better tree-shaking.

## Migration Notes

### 2.0.x to 2.1.x

- Dart SDK minimum is now `>=3.8.0`.
- `build_runner` inlines all sheet classes into `generated_localizations.dart`. Update imports that pointed at per-sheet files from an older `build_runner` run.
- `initializeGlobal()` and friends are removed. Use `AppLocalizations.current` or `AppLocalizations(languageCode)`.
- CSV parsing is now RFC 4180 compliant: commas inside quoted fields work.

### 1.x to 2.x

- Configuration moved from CLI flags to the `excel_translator` section of `pubspec.yaml`.
- Sheet-name sanitization changed: hyphens and spaces become underscores before camelCasing, so `My Sheet` is `.mySheet`, not `.mysheet`. Audit your call sites.
- The global executable is now `excel_translator`. Update scripts.

## Architecture

```text
excel_file or files[]
       |
       v  TranslationInputService               parses and merges sources
  FileParserFactory / FileParser                 -> List<LocalizationSheet>
       |
       v  SheetClassGenerator, MainClassGenerator, ExtensionGenerator
       |
       +-- CLI     -> N + 2 files (one per sheet, main, extension)
       +-- Builder -> 2 files (inline merged, extension)
```

```text
lib/
+-- builder.dart                 # build_runner Builder
+-- cli.dart                     # public CLI API
+-- excel_translator.dart        # library exports
+-- src/
    +-- cli.dart                 # argument parsing
    +-- translator_service.dart  # orchestration
    +-- parsers/                 # excel, csv, ods + factory
    +-- generators/              # sheet, main, extension
    +-- services/                # config (pubspec.yaml), language (ISO 639-1)
    +-- models/                  # sheet, translation, language, config
    +-- utils/                   # string_utils, validators, logger, errors
```

## License

[MIT](LICENSE)
