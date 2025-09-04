# Changelog

## [1.0.3] - 2025-09-04

### 🐛 Fixes

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
