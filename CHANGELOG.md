# Changelog

## [2.1.1] - 2026-01-09

### Changes

- Add version management script to automate version updates and changelog generation (Added: bin/increase_version.dart)
- Update generated localization files with new timestamps and formatting improvements (Deleted: .github/workflows/publish.yml)

## [2.1.0] - 2026-01-08

### New Features

- Added --version and -v flags to CLI for checking package version
- Display version information in help output
- Improved version detection to show main package version consistently across directories

### Bug Fixes

- Fixed Dart keyword conflict in generated property names (e.g., 'default' -> 'defaultValue')
- Resolved compilation errors when sheet names match Dart reserved keywords

### Internal Improvements

- Enhanced CLI argument parsing and help display
- Better error handling for version reading
- Improved code generation robustness

### Major Architecture Refactoring

- **Simplified Structure**: Replaced complex Clean Architecture with streamlined service-oriented design
- **Removed Layers**: Eliminated unnecessary domain/data/application/presentation layers
- **Unified Models**: Consolidated entities into single `models` package
- **Streamlined Services**: Merged repositories and use cases into `services` layer
- **Enhanced Parsers**: Split data sources into dedicated `parsers` for input processing
- **Optimized Generators**: Created focused `generators` for output code generation
- **Improved Utils**: Centralized utilities in dedicated `utils` package

### Bug Fixes

- Fixed CLI exit handling for better testability
- Resolved config merging issues with nullable types
- Fixed table alignment in README.md documentation

### Internal Improvements

- Better error handling and validation
- Improved code maintainability and readability
- Enhanced type safety throughout the codebase

## [1.0.7] - 2025-10-08

- Fix running without arguments, automatically loading configuration from `pubspec.yaml`
- Added `dart run excel_translator log` to print current pubspec configuration

## [1.0.6] - 2025-10-08

- Skip invalid columns, not entire sheets
- Fixed hyphenated names: auth-errors → AuthErrorsLocalizations
- Fixed interpolation: %param$s → {param}

## [1.0.5] - 2025-09-06

### Fixes

- Improved pub.dev analysis score and compliance
- Fixed Web/WASM compatibility issues
- Enhanced code formatting and organization
- Optimized package structure for better performance

### Documentation

- Updated installation instructions
- Improved code documentation and comments

## [1.0.4] - 2025-09-06

### Major Dependency Update

- **Unified Parser**: Replaced individual packages (`excel`, `csv`, `spreadsheet_decoder`) with unified `table_parser` package
- **Enhanced Performance**: Better memory handling and parsing performance for large files
- **Improved CSV Support**: Enhanced CSV parsing with better quote handling and custom separators
- **Simplified Dependencies**: Reduced from 3 separate packages to 1 unified solution

### � Improvements

- Fixed CSV and ODS file parsing issues
- Resolved missing language data file issues
- Improved error handling across all file formats

## [1.0.3] - 2025-09-04

### Bug Fixes

- Fixed CSV and ODS file parsing issues
- Resolved missing language data file issues

## [1.0.2] - 2025-09-04

### New Features

- **Multi-Format File Support**: Added CSV (.csv) and ODS (.ods) format support
- **ODS Format Support**: Full OpenDocument Spreadsheet (.ods) support using spreadsheet_decoder
- Added `spreadsheet_decoder` package dependency for ODS parsing
- Added `csv` package dependency for CSV parsing
- ODS files now support multiple sheets (same as Excel)
- Enhanced `FileFormat` enum with modern Dart enhanced enum features
- Comprehensive multi-format support: Excel (.xlsx), CSV (.csv), and ODS (.ods)

### Enhanced

- **CLI Help**: Updated help text to reflect full multi-format support
- **Documentation**: Added CSV and ODS examples and usage instructions
- **Example Files**: Added CSV and ODS example files in `example/assets/`
- **Format Detection**: Improved file format detection with better error messages

## [1.0.1] - 2025-09-04

### Fixed

- **WASM Compatibility**: Generated localizations now work in WASM environments
- **Static Analysis**: Fixed CLI import issues for better compatibility

### Improvements

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
