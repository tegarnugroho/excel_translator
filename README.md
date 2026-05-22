# excel_translator

[![pub package](https://img.shields.io/pub/v/excel_translator.svg)](https://pub.dev/packages/excel_translator)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Dart SDK](https://img.shields.io/badge/dart-%3E%3D3.8.0-blue)](https://dart.dev)

Generate type-safe Flutter/Dart localizations from Excel, CSV, or ODS files. Organize translations by feature using sheets, get compile-time safety and auto-completion, and choose between a flexible CLI or a convenient `build_runner` integration.

---

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Excel Structure](#excel-structure)
- [CLI Mode](#cli-mode)
- [build\_runner Mode](#build_runner-mode)
- [Why build\_runner Output Differs from CLI Output](#why-build_runner-output-differs-from-cli-output)
- [Recommended Workflow](#recommended-workflow)
- [Best Practices](#best-practices)
- [Performance Notes](#performance-notes)
- [Architecture Overview](#architecture-overview)
- [Migration Notes](#migration-notes)
- [FAQ](#faq)
- [Deal Breakers / Important Limitations](#deal-breakers--important-limitations)

---

## Introduction

`excel_translator` generates Dart localization classes directly from spreadsheet files. Instead of managing `.arb` files or hand-rolling localization boilerplate, you maintain a single Excel workbook where each sheet represents a localization module (e.g., `login`, `home`, `buttons`).

The package supports two generation modes:

| Mode | Primary use case |
|------|-----------------|
| **CLI** | Advanced projects, per-sheet file output, CI pipelines, full control |
| **build\_runner** | Convenience, watch mode, simple projects that can accept a single merged output |

Both modes produce type-safe Dart code from the same Excel source. They differ in how many files they emit and whether dynamic per-sheet filenames are possible — this distinction is explained in detail below.

---

## Features

- **Multi-format support** — Excel (`.xlsx`), CSV (`.csv`), and ODS (`.ods`)
- **Multi-sheet support** — Organize translations by feature (Excel & ODS)
- **Type-safe generated code** — Compile-time safety with IDE auto-completion
- **String interpolation** — Dynamic values via `{variable}` or `%variable$s` syntax
- **184+ language codes** — Full ISO 639-1 with country variants (`en_US`, `pt_BR`, `zh_CN`)
- **CamelCase accessors** — `app_title` → `.appTitle`
- **Language validation** — Validates codes at generation time with clear error messages
- **Zero-config CLI** — Reads configuration from `pubspec.yaml`
- **Global instance** — Access translations outside `BuildContext` (services, repositories)
- **Watch mode** — Re-generates automatically on file change via `build_runner`

### Format Comparison

| Format | Extension | Multi-sheet | Best for |
|--------|-----------|-------------|----------|
| Excel | `.xlsx` | Yes | Complex projects with many modules |
| CSV | `.csv` | No | Simple projects, single-language modules |
| ODS | `.ods` | Yes | Teams using LibreOffice Calc |

---

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  excel_translator: ^2.1.7
```

For `build_runner` integration, also add to `dev_dependencies`:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
```

Then run:

```bash
dart pub get
```

---

## Quick Start

### 1. Create Your Spreadsheet

**Excel (`.xlsx`) with multiple sheets:**

Sheet `login`:

| key | en | id | es |
|-----|----|----|-----|
| title | Login | Masuk | Iniciar sesión |
| forgot_password | Forgot Password? | Lupa Kata Sandi? | ¿Olvidó su contraseña? |
| welcome_message | Welcome {name}! | Selamat datang {name}! | ¡Bienvenido {name}! |

Sheet `buttons`:

| key | en | id | es |
|-----|----|----|-----|
| submit | Submit | Kirim | Enviar |
| cancel | Cancel | Batal | Cancelar |

**CSV (`.csv`) — single sheet only:**

```csv
key,en,id,es
title,Login,Masuk,"Iniciar sesión"
forgot_password,Forgot Password?,Lupa Kata Sandi?,¿Olvidó su contraseña?
```

### 2. Configure `pubspec.yaml`

```yaml
excel_translator:
  excel_file: assets/localizations.xlsx   # .xlsx, .csv, or .ods
  output_dir: lib/generated
  class_name: AppLocalizations            # optional, default: AppLocalizations
  include_flutter_delegates: true         # optional, default: true
```

### 3. Generate

```bash
# CLI mode (recommended)
dart run excel_translator

# build_runner mode
dart run build_runner build
```

### 4. Use in Your App

```dart
import 'lib/generated/generated_localizations.dart';

// In a widget
final loc = AppLocalizations.of(context);
print(loc.login.title);                           // "Login"
print(loc.login.forgotPassword);                  // "Forgot Password?"
print(loc.login.welcomeMessage(name: 'Alice'));   // "Welcome Alice!"
print(loc.buttons.submit);                        // "Submit"

// By language code
final id = AppLocalizations('id');
print(id.login.title);   // "Masuk"

// Named getters (first 5 languages in your workbook)
AppLocalizations.english.login.title;
AppLocalizations.en.login.title;

// System language auto-detection (no BuildContext needed)
AppLocalizations.current.login.title;
```

### 5. Flutter App Setup

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.delegates,
  supportedLocales: AppLocalizations.supportedLanguages
      .map((code) => Locale(code))
      .toList(),
  home: const MyHomePage(),
);
```

---

## Excel Structure

### Single-sheet workbook

One sheet with any name. All translations live in one class.

| key | en | id |
|-----|----|----|
| app_title | My App | Aplikasi Saya |
| save_button | Save | Simpan |

### Multi-sheet workbook

Each sheet becomes its own class, accessible as a named property on `AppLocalizations`.

**Sheet `home`:**

| key | en | id |
|-----|----|----|
| greeting | Good morning! | Selamat pagi! |
| subtitle | What would you like to do? | Apa yang ingin Anda lakukan? |

**Sheet `errors`:**

| key | en | id |
|-----|----|----|
| network_error | No internet connection | Tidak ada koneksi internet |
| not_found | Resource not found | Sumber daya tidak ditemukan |

Accessed as:

```dart
loc.home.greeting
loc.errors.networkError
```

### Rules

- First column must be `key`
- Remaining columns are language codes (`en`, `id`, `es`, `pt_BR`, …)
- Language codes are validated against ISO 639-1 at generation time
- Empty rows are skipped
- Sheet names become class names and property names (sanitized to camelCase)

---

## CLI Mode

### How it Works

The CLI reads your spreadsheet, parses every sheet, and writes **one `.dart` file per sheet** plus a main entry-point file. The main file imports each sheet file and composes them into a single `AppLocalizations` class.

```
┌─────────────────────────────┐
│  localizations.xlsx         │
│  ├── sheet: login           │
│  ├── sheet: buttons         │
│  └── sheet: errors          │
└──────────────┬──────────────┘
               │  dart run excel_translator
               ▼
┌─────────────────────────────────────────┐
│  lib/generated/                         │
│  ├── generated_localizations.dart       │  ← main class + imports
│  ├── build_context_extension.dart       │  ← context.loc extension
│  ├── login_localizations.dart           │  ← LoginLocalizations class
│  ├── buttons_localizations.dart         │  ← ButtonsLocalizations class
│  └── errors_localizations.dart          │  ← ErrorsLocalizations class
└─────────────────────────────────────────┘
```

### Commands

```bash
# Zero-config — reads pubspec.yaml
dart run excel_translator

# Explicit file and output dir
dart run excel_translator assets/localizations.xlsx lib/generated

# Custom class name
dart run excel_translator assets/localizations.xlsx lib/generated --class-name=L10n

# Disable Flutter delegates (pure Dart projects)
dart run excel_translator assets/localizations.xlsx lib/generated --no-delegates

# Show current configuration
dart run excel_translator log

# Show help
dart run excel_translator --help

# Show version
dart run excel_translator --version
```

**Global installation (run from any directory):**

```bash
dart pub global activate excel_translator

excel_translator                                          # pubspec.yaml config
excel_translator assets/localizations.xlsx lib/generated
excel_translator assets/l10n.csv lib/generated --class-name=L10n

dart pub global deactivate excel_translator              # uninstall
```

### Options

| Flag | Short | Default | Description |
|------|-------|---------|-------------|
| `--class-name=NAME` | `-c=NAME` | `AppLocalizations` | Generated root class name |
| `--no-delegates` | `-nd` | — | Omit Flutter delegates |
| `--delegates=BOOL` | `-d=BOOL` | `true` | Toggle delegates |
| `--help` | `-h` | — | Show help |
| `--version` | `-v` | — | Show version |

### Generated Output Structure (CLI)

```
lib/generated/
├── generated_localizations.dart     # Root class — imports all sheet files
├── build_context_extension.dart     # Optional BuildContext extension
├── login_localizations.dart         # One file per sheet
├── buttons_localizations.dart
└── errors_localizations.dart
```

`generated_localizations.dart` imports the sheet files:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:excel_translator/excel_translator.dart';
import 'dart:ui' show PlatformDispatcher;

import 'login_localizations.dart';
import 'buttons_localizations.dart';
import 'errors_localizations.dart';

class AppLocalizations { ... }
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> { ... }
```

### CLI Advantages

- Per-sheet files keep diffs small and readable in code review
- Sheet files can be individually inspected or linted
- Full control over when generation runs
- Works in CI pipelines without `build_runner` overhead
- Supports all CLI flags not available in `build_runner`
- No constraints on output file naming

---

## build_runner Mode

### When to Use It

Use `build_runner` when you want automatic regeneration on file save during development — the watch mode integration is its main value. It is not a replacement for CLI mode in production pipelines.

### Setup

1. Add `build_runner` to `dev_dependencies` (already shown in Installation).
2. Ensure `pubspec.yaml` has an `excel_translator` section with at least `excel_file` and `output_dir`.

The package ships a `build.yaml` that registers the builder automatically for the root package — no manual `build.yaml` changes are required in your project.

**Your `pubspec.yaml`:**

```yaml
excel_translator:
  excel_file: assets/localizations.xlsx
  output_dir: lib/generated
  class_name: AppLocalizations           # optional
  include_flutter_delegates: true        # optional
```

### Commands

```bash
# One-time build
dart run build_runner build

# Watch mode — regenerates on Excel file change
dart run build_runner watch

# Force rebuild (clears cache)
dart run build_runner build --delete-conflicting-outputs
```

### Generated Output Structure (build_runner)

```
lib/generated/
├── generated_localizations.dart     # All sheet classes inlined here
└── build_context_extension.dart     # Optional BuildContext extension
```

All sheet classes are inlined into `generated_localizations.dart`. There are **no separate per-sheet files**.

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
...

class LoginLocalizations { ... }    // inlined
class ButtonsLocalizations { ... }  // inlined
class ErrorsLocalizations { ... }   // inlined

class AppLocalizations { ... }
class AppLocalizationsDelegate { ... }
```

### build_runner Limitations

- Always produces exactly 2 output files regardless of sheet count
- Per-sheet file output is not possible (see [Why build_runner Output Differs](#why-build_runner-output-differs-from-cli-output))
- `output_dir` must match the hardcoded `lib/generated` path (the build extensions are declared statically)
- No support for `--class-name` or `--no-delegates` flags at build time; configure via `pubspec.yaml` instead
- All build_runner constraints apply: outputs must be under `lib/`, cannot write outside the package

---

## Why build_runner Output Differs from CLI Output

This is the most important architectural difference to understand.

### The Core Constraint

`build_runner` requires every builder to declare its output files **before the build runs**. This declaration is called `buildExtensions` and it must be a static, compile-time constant:

```dart
@override
final buildExtensions = const {
  'pubspec.yaml': [
    'lib/generated/generated_localizations.dart',
    'lib/generated/build_context_extension.dart',
  ],
};
```

This is how `build_runner` constructs its asset graph, tracks dependencies, and decides which builders to invalidate on change. The output file list cannot be computed dynamically.

### Why Per-Sheet Files Are Not Possible

To generate per-sheet files, the builder would need to declare output names like:

```dart
// This is NOT possible in build_runner
'lib/generated/login_localizations.dart',
'lib/generated/buttons_localizations.dart',
'lib/generated/errors_localizations.dart',
```

But sheet names (`login`, `buttons`, `errors`) are only known **after parsing the Excel file** — which happens inside the `build()` method at runtime, long after `buildExtensions` has been evaluated.

```
Timeline:
  build graph construction → buildExtensions evaluated   ← sheet names unknown here
  build execution          → build() called, Excel parsed ← sheet names known here
```

There is no mechanism in the `build` package to emit files with names determined at runtime. Any attempt to write to an undeclared asset path would be rejected by the build system.

### The Solution: Inline Mode

The builder resolves this by inlining all sheet classes into a single file with a deterministic, pre-declared name (`generated_localizations.dart`). The content is dynamic; the filename is not. This satisfies `build_runner`'s requirements while still producing fully functional generated code.

### CLI Has No Such Constraint

The CLI runs as a plain Dart script with full filesystem access. It parses the Excel file first, discovers sheet names, then writes one file per sheet. The output list is determined at runtime — exactly what `build_runner` disallows.

---

## Recommended Workflow

### For Most Projects

Use **CLI mode** as the primary workflow.

```bash
# Add to pubspec.yaml, then run:
dart run excel_translator
```

Re-run whenever you update your Excel file. This fits naturally into existing workflows: run before committing, add to CI, or wire to a `Makefile` / `justfile` target.

### For Active Development (watch mode)

Use **build_runner watch** during development for automatic regeneration:

```bash
dart run build_runner watch
```

Accept the trade-off: output will be a single merged file instead of per-sheet files. Switch back to CLI mode before committing if per-sheet output is required.

### Mixed Workflow

A practical pattern for teams:

1. Use `build_runner watch` locally during active translation work
2. Run `dart run excel_translator` in CI to produce the canonical per-sheet output
3. Commit the CLI-generated files

This avoids friction locally while keeping clean, reviewable per-sheet diffs in version control.

---

## Best Practices

**Spreadsheet organization**

- Group related keys into the same sheet (e.g., one sheet per feature screen)
- Use consistent key naming: `snake_case` throughout
- Keep keys short and self-documenting: `login_title` not `lt`
- Add a fallback language column (usually `en`) as the first language column

**Key naming**

- Keys become method or getter names after camelCase conversion
- Avoid Dart reserved words as key names (`class`, `void`, `return`, etc.)
- String interpolation keys: `welcome_message` with value `Welcome {name}!` → `welcomeMessage(name: ...)`

**Version control**

- Commit the generated files; do not `.gitignore` them
- This ensures the app builds without running the generator and makes diffs reviewable
- Generated files are clearly marked `// GENERATED CODE - DO NOT MODIFY BY HAND`

**CI integration**

```yaml
# Example CI step (GitHub Actions)
- name: Generate localizations
  run: dart run excel_translator

- name: Check for uncommitted changes
  run: git diff --exit-code lib/generated/
```

**Multiple environments**

- Keep one authoritative Excel file in the repository under `assets/`
- Avoid maintaining parallel CSV exports — they will drift from the source

---

## Performance Notes

- **Parse time** scales with workbook size, not sheet count. A 50-sheet workbook with 20 keys each parses faster than a 1-sheet workbook with 10,000 keys.
- **Generation time** is negligible; the bottleneck is always parsing.
- **build_runner** adds overhead per build due to asset graph evaluation. For large projects, `dart run excel_translator` is faster for one-off generation.
- **Watch mode** only re-parses when the Excel file changes (the asset is registered as a build dependency), so incremental rebuilds are fast.
- Generated code uses `switch` statements per key, not maps. This is intentional: `switch` compiles to jump tables, avoids heap allocation, and performs better under tree-shaking.

---

## Architecture Overview

```
excel_translator/
├── bin/
│   └── excel_translator.dart        # CLI entry point
│
├── lib/
│   ├── builder.dart                 # build_runner Builder implementation
│   ├── cli.dart                     # Public CLI API
│   ├── excel_translator.dart        # Public library exports
│   │
│   └── src/
│       ├── cli.dart                 # ExcelTranslatorCLI — argument parsing
│       ├── translator_service.dart  # Orchestration layer
│       │
│       ├── parsers/
│       │   ├── file_parser_interface.dart   # FileParser interface
│       │   ├── parser_factory.dart          # Format detection
│       │   ├── excel_parser.dart            # .xlsx via table_parser
│       │   ├── csv_parser.dart              # .csv (RFC 4180 + quoted commas)
│       │   └── ods_parser.dart              # .ods via table_parser
│       │
│       ├── generators/
│       │   ├── sheet_class_generator.dart   # Per-sheet class generation
│       │   ├── main_class_generator.dart    # Root AppLocalizations class
│       │   └── extension_generator.dart     # BuildContext extension
│       │
│       ├── services/
│       │   ├── config_service.dart          # pubspec.yaml config loading
│       │   └── language_service.dart        # ISO 639-1 validation + names
│       │
│       ├── models/
│       │   ├── localization_sheet.dart      # Sheet + translations model
│       │   ├── translation.dart             # Key + language map
│       │   ├── language.dart                # Language metadata
│       │   └── config.dart                  # Configuration model
│       │
│       └── utils/
│           ├── string_utils.dart            # camelCase, sanitization
│           ├── validators.dart              # Input validation
│           ├── logger.dart                  # Structured output
│           └── errors.dart                  # Typed exceptions
```

### Data Flow

```
Excel/CSV/ODS file
       │
       ▼
  FileParserFactory.createParser()
       │  selects parser by file extension
       ▼
  FileParser.parseFile() / parseFileFromBytes()
       │  produces List<LocalizationSheet>
       ▼
  Generators (SheetClassGenerator, MainClassGenerator, ExtensionGenerator)
       │
       ├─── CLI mode  → writes N+2 files (N sheets + main + extension)
       │
       └─── Builder   → writes 2 files (inline merged + extension)
```

### Generator Modes Side by Side

```
CLI mode                          build_runner mode
─────────────────────────────     ─────────────────────────────
login_localizations.dart          ┐
buttons_localizations.dart        │ inlined into
errors_localizations.dart         ┘ generated_localizations.dart
generated_localizations.dart      generated_localizations.dart
build_context_extension.dart      build_context_extension.dart
```

---

## Migration Notes

### From 2.0.x to 2.1.x

- Dart SDK minimum raised to `>=3.8.0`. Update your `pubspec.yaml` environment constraint if needed.
- `build_runner` mode now inlines all sheet classes into `generated_localizations.dart`. If you were importing per-sheet files generated by a previous `build_runner` run, update those imports to point to `generated_localizations.dart` instead.
- `initializeGlobal()`, `initializeGlobalWithLanguage()`, and related global instance methods have been removed in favour of `AppLocalizations.current` and the constructor `AppLocalizations(languageCode)`. Replace call sites accordingly.
- CSV parser now correctly handles commas inside quoted fields (RFC 4180 compliance).

### From 1.x to 2.x

- Configuration moved from CLI flags to `pubspec.yaml`. The `excel_translator` section is now the canonical configuration source.
- Sheet name sanitization changed: hyphens and spaces in sheet names are now converted to underscores before camelCasing. A sheet named `My Sheet` becomes `.mySheet`, not `.mysheet`. Audit your access sites.
- The global executable name is now `excel_translator` (previously varied by install method). Update scripts accordingly.

---

## FAQ

**Can I use this without Flutter?**

Yes. Pass `--no-delegates` to the CLI or set `include_flutter_delegates: false` in `pubspec.yaml`. The generated classes have no Flutter dependency and work in any Dart project.

**Does CSV support multiple sheets?**

No. CSV is a single-sheet format. Use Excel or ODS if you need per-module organization.

**Can I customise the output directory in build_runner mode?**

Partially. You can set `output_dir` in `pubspec.yaml`, but it must be `lib/generated`. The builder's `buildExtensions` declares the output paths statically. Changing `output_dir` to a different value in `pubspec.yaml` affects the content of the generated file but not its location on disk — the file is always written to `lib/generated/`.

**Can I run both CLI and build_runner in the same project?**

Yes, but they will both write to `lib/generated/`. CLI generates per-sheet files; `build_runner` generates a single merged file. Running one after the other will leave stale files from whichever ran first. Pick one mode as canonical and delete the other's outputs.

**Why are language getters only generated for the first 5 languages?**

Named getters like `AppLocalizations.english` and `AppLocalizations.en` are generated for the first 5 language codes found in the workbook, to avoid unbounded code growth. All languages remain accessible via the constructor: `AppLocalizations('pt_BR')`.

**How do I add a new language?**

Add a new column to your Excel sheet with the ISO 639-1 language code as the header. Re-run the generator. The new language appears in `supportedLanguages` and is immediately accessible.

**What happens if a translation is missing for a key?**

The generated `switch` statement includes a `default:` case that falls back to the first language value found for that key (typically `en`). No exception is thrown.

**Can I rename the root class from `AppLocalizations`?**

Yes. Use `--class-name=MyL10n` with the CLI or set `class_name: MyL10n` in `pubspec.yaml`.

**Are the generated files safe to commit?**

Yes, and it is recommended. Committing generated files means your project builds without requiring contributors to run the generator, and generated diffs are reviewable in pull requests.

---

## Deal Breakers / Important Limitations

Read this section before choosing `build_runner` mode for a production project.

### build_runner Cannot Generate Per-Sheet Files

This is a fundamental, non-negotiable constraint of the `build` package — not a bug or a missing feature in `excel_translator`.

The `build_runner` asset graph requires that every builder declares its output files **statically**, before any code runs. Sheet names exist only inside the Excel binary. There is no way to declare `login_localizations.dart` as an output before reading the file, because the string `"login"` is only discovered during parsing.

**There is no workaround.** Per-sheet file output requires the CLI.

### build_runner output_dir Is Effectively Fixed at lib/generated

The `buildExtensions` map in `builder.dart` is declared as a Dart `const`. The paths `lib/generated/generated_localizations.dart` and `lib/generated/build_context_extension.dart` are hardcoded. Setting `output_dir` to a different value in `pubspec.yaml` does not change where `build_runner` writes the files.

If your project requires output in a path other than `lib/generated`, use CLI mode.

### build_runner Mode Is Not Suitable as the Sole Generation Method in CI

`build_runner` is designed for development-time use. In CI:

- It requires installing `build_runner` as a dev dependency
- It performs cache invalidation checks that slow down cold builds
- The merged single-file output makes pull request diffs harder to review for translation changes

The CLI is faster, has no extra dependencies, and produces cleaner per-sheet diffs. Use CLI in CI.

### Single Excel Workbook Constraint

Both modes consume a single source file. There is no built-in support for merging multiple Excel files into one set of generated classes. If your project needs multi-file sources, merge them at the spreadsheet level before generation.

### Sheet Names Drive Public API Shape

Sheet names become Dart class names and property names. Renaming a sheet is a **breaking change** in the generated API. All call sites (`loc.login.title`) must be updated. Plan your sheet naming convention early.

### Language Names in Getters Are Capped at 5

Named convenience getters (`AppLocalizations.english`, `AppLocalizations.en`) are only generated for the first 5 languages. Projects with more than 5 languages should use the constructor (`AppLocalizations('fr')`) or `AppLocalizations.current` for all language access beyond the first 5.

---

## License

[MIT](LICENSE)
