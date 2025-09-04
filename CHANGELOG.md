# Changelog

## [1.0.3] - 2025-09-04

### ✨ Major Architecture Overhaul - Clean Architecture Implementation

**🏗️ Complete Clean Architecture Refactoring**
- **Domain Layer**: Pure business logic with entities, repositories contracts, and use cases
- **Data Layer**: Implementation layer with data sources and repository implementations
- **Application Layer**: Service orchestration with TranslatorService
- **Presentation Layer**: CLI interface separated from business logic
- **Core Layer**: Shared utilities and cross-cutting concerns

**📂 New Architecture Structure**
```
lib/src/
├── domain/           # Business rules (entities, repositories, use cases)
├── data/            # Implementation (sources, repository implementations)
├── application/     # Service coordination (TranslatorService)
├── presentation/    # CLI interface
└── core/           # Shared utilities
```

**🔧 Configuration & Language Management Refactored**
- Moved `ExcelTranslatorConfig` to domain entity with proper merging logic
- Replaced static `LanguageData` with Repository pattern
- Added `LoadConfigurationUseCase` for configuration orchestration
- Created data sources for JSON loading and fallback data
- Configuration priority: CLI args > pubspec.yaml > defaults

**🎯 Code Generation Moved to Data Layer**
- Migrated generators from separate layer to data sources
- `SheetClassGenerator` → `SheetCodeDataSource`
- `MainClassGenerator` → `MainCodeDataSource`
- `ExtensionGenerator` → `ExtensionCodeDataSource`
- Proper dependency injection in `CodeGeneratorRepositoryImpl`

**📁 File Organization**
- Moved `lang.json` from `lib/src/data/lang/` to `assets/` folder
- Removed legacy configuration and language data folders
- Updated all exports for clean module boundaries

**✅ Benefits**
- **SOLID Principles**: Single Responsibility, Dependency Inversion
- **Testability**: Each component isolated and mockable
- **Maintainability**: Clear layer boundaries and responsibilities
- **Extensibility**: Easy to add new file formats and features
- **Zero Breaking Changes**: All public APIs remain compatible

**📊 Impact**
- 54/54 tests passing
- CSV/ODS parsing restored and working
- No lint errors in codebase
- Backward compatible CLI and API

### 🐛 Fixes
- Fixed CSV and ODS file parsing after architecture refactoring
- Resolved missing language data file issues

### 📚 Documentation
- Added comprehensive Clean Architecture documentation
- Created `CODE_GENERATION_REFACTORING.md` guide
- Updated architecture diagrams and examples

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
- **File Parser**: Modernized enum implementation using Dart 2.17+ enhanced enum features
- **Example Files**: Added CSV and ODS example files in `example/assets/`
- **Format Detection**: Improved file format detection with better error messages
- **Unified API**: Refactored to use `generateFromFile` with backward compatibility

### Technical

- Created FileParserFactory for handling different file formats
- Implemented CsvFileParser with proper line ending handling
- Implemented OdsFileParser with comprehensive error handling
- Refactored `FileFormat` enum to use enhanced enum with extension values
- Simplified format detection logic by eliminating manual switch statements
- Added comprehensive format comparison documentation
- All three formats now have feature parity where applicable
- Maintained legacy `generateFromExcel` method for backward compatibility

### Style

- **Code Formatting**: Applied `dart format` to all source files
- Fixed formatting issues reported by pub.dev static analysis
- Ensures compliance with official Dart style guidelines

## [1.0.1] - 2025-09-04

### Fixed

- **WASM Compatibility**: Removed `dart:io` dependency from generated code
- Generated localizations now work in WASM environments
- System language detection uses only `PlatformDispatcher` (WASM compatible)
- Separated runtime exports from build-time dependencies
- **Static Analysis**: Fixed CLI import issues for pub.dev scoring
- Resolved relative import warnings in `bin/excel_translator.dart`
- Created dedicated CLI export file (`lib/cli.dart`) for build-time dependencies

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
