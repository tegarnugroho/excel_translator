# Changelog

## [1.0.1] - 2025-09-04

### Fixed

- **WASM Compatibility**: Removed `dart:io` dependency from generated code
- Generated localizations now work in WASM environments
- System language detection uses only `PlatformDispatcher` (WASM compatible)
- Separated runtime exports from build-time dependencies
- **Static Analysis**: Fixed CLI import issues for pub.dev scoring
- Resolved relative import warnings in `bin/excel_translator.dart`
- Created dedicated CLI export file (`lib/cli.dart`) for build-time dependencies

### Changed

- Improved language detection fallback mechanism
- Better error handling for environments without platform access

## [1.0.0] - 2024-12-19

### Added

- Initial release of Excel Translator
- Multi-sheet Excel file support
- Type-safe localization generation
- BuildContext extension for easy access
- String interpolation with dynamic parameters
- Command-line generation tool
- Comprehensive example application
- Support for multiple languages per sheet
- Automatic fallback handling
- Clean, modular code generation

### Features

- Generate localizations from Excel files with multiple sheets
- Access translations via `context.loc.sheetName.key`
- String interpolation support with `{variable}` syntax
- Type-safe parameter handling
- Automatic code generation with proper imports
- Support for unlimited languages and sheets
