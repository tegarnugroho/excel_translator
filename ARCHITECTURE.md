# Refactored Architecture Documentation

## Overview
Package `excel_translator` telah berhasil di-refaktor menggunakan **Clean Architecture** dengan struktur yang lebih maintainable dan scalable.

## New Architecture Structure

```
lib/
├── excel_translator.dart          # Entry point / public API
│
├── src/                           # Semua implementasi internal (tidak diekspos langsung)
│   ├── domain/                    # Business rules (independen dari package/framework)
│   │   ├── entities/              # Entity murni (Translation, Language, LocalizationSheet)
│   │   ├── repositories/          # Abstraksi contract repo (IFileParserRepository, etc.)
│   │   └── usecases/              # Use case (ParseLocalizationFileUseCase, etc.)
│   │
│   ├── data/                      # Implementasi dari domain repositories
│   │   ├── models/                # DTO/Model untuk parsing + mapper
│   │   ├── sources/               # Data sources (ExcelFileDataSource, CsvFileDataSource)
│   │   └── repositories_impl/     # Implementasi repo (FileParserRepositoryImpl, etc.)
│   │
│   ├── application/               # Coordinator / service logic
│   │   └── translator_service.dart # Orchestration, combine usecases + repos
│   │
│   ├── presentation/              # CLI/command interface
│   │   └── cli.dart               # Command line handling
│   │
│   ├── core/                      # Shared utils & constants
│   │   ├── errors.dart
│   │   ├── logger.dart
│   │   ├── string_utils.dart
│   │   └── validators.dart
│   │
│   ├── generators/                # Existing code generators (kept for compatibility)
│   ├── infrastructure/            # Legacy code (kept for compatibility)
│   └── runtime/                   # Runtime exports
│
└── generated/                     # (generated files output destination)
```

## Key Components

### Domain Layer (Business Logic)

#### Entities
- **`Translation`**: Represents a single translation entry with key-value pairs
- **`Language`**: Represents a language with code, name, and optional region
- **`LocalizationSheet`**: Represents a sheet containing multiple translations

#### Repositories (Contracts)
- **`IFileParserRepository`**: Contract for parsing different file formats
- **`ICodeGeneratorRepository`**: Contract for generating Dart code
- **`ILanguageValidationRepository`**: Contract for language validation

#### Use Cases
- **`ParseLocalizationFileUseCase`**: Parse files and convert to domain entities
- **`GenerateLocalizationClassesUseCase`**: Generate Dart localization classes
- **`ValidateLanguageCodesUseCase`**: Validate language codes

### Data Layer (Infrastructure)

#### Data Sources
- **`ExcelFileDataSource`**: Parse .xlsx files
- **`CsvFileDataSource`**: Parse .csv files  
- **`OdsFileDataSource`**: Parse .ods files

#### Repository Implementations
- **`FileParserRepositoryImpl`**: Implements file parsing using data sources
- **`CodeGeneratorRepositoryImpl`**: Implements code generation using legacy generators
- **`LanguageValidationRepositoryImpl`**: Implements language validation

#### Models & Mappers
- **`EntityModelMapper`**: Maps between domain entities and legacy models
- Legacy models maintained for backward compatibility

### Application Layer

#### Service
- **`TranslatorService`**: Main orchestrator that coordinates all use cases
- Provides high-level API for file processing
- Handles error management and logging

### Presentation Layer

#### CLI
- **`ExcelTranslatorCLI`**: Command-line interface
- Argument parsing and validation
- User-friendly error messages and help

### Core Layer

#### Utilities
- **`Logger`**: Structured logging with different levels
- **`StringUtils`**: String manipulation utilities
- **`Validators`**: Common validation functions
- **`Errors`**: Custom exception classes

## Benefits of New Architecture

### 1. **Separation of Concerns**
- Domain logic terpisah dari infrastructure
- Business rules tidak bergantung pada framework eksternal
- Easy to test dan modify

### 2. **Dependency Inversion**
- High-level modules tidak bergantung pada low-level modules
- Dependencies di-inject melalui contracts/interfaces
- Mudah untuk mock dan test

### 3. **Single Responsibility**
- Setiap class memiliki tanggung jawab yang jelas
- Use cases fokus pada satu operasi bisnis
- Repository fokus pada data access

### 4. **Scalability**
- Mudah menambah file format baru (tinggal buat DataSource baru)
- Mudah menambah use case baru
- Mudah menambah validation rules

### 5. **Testability**
- Domain entities pure/immutable
- Use cases mudah di-unit test
- Dependencies bisa di-mock dengan mudah

### 6. **Maintainability**
- Code structure yang konsisten
- Clear layer boundaries
- Documentation yang jelas

## Migration Guide

### For Library Users
- **API tetap sama**: Public API di `excel_translator.dart` tidak berubah
- **CLI tetap kompatibel**: Command line interface sama
- **Generated code sama**: Output yang dihasilkan tetap sama

### For Contributors
- **Domain entities**: Gunakan entities di `domain/entities/`
- **New features**: Tambah use case di `domain/usecases/`
- **New file formats**: Tambah data source di `data/sources/`
- **Business logic**: Letakkan di domain layer
- **Infrastructure**: Letakkan di data layer

## Usage Examples

### Using the Service Directly
```dart
import 'package:excel_translator/excel_translator.dart';

void main() async {
  final service = TranslatorService.create();
  
  await service.generateFromFile(
    filePath: 'assets/localizations.xlsx',
    outputDir: 'lib/generated',
    className: 'AppLocalizations',
  );
}
```

### Using Individual Use Cases
```dart
import 'package:excel_translator/excel_translator.dart';

void main() async {
  final parseUseCase = ParseLocalizationFileUseCase(
    FileParserRepositoryImpl(),
  );
  
  final sheets = await parseUseCase.execute('assets/localizations.xlsx');
  print('Found ${sheets.length} sheets');
}
```

## Testing

Semua test masih passing setelah refaktor:
- Unit tests untuk utilities
- Integration tests untuk file parsing
- End-to-end tests untuk CLI

## Backward Compatibility

- Legacy code di `infrastructure/` dan `generators/` dipertahankan
- API public tidak berubah
- Generated code format tetap sama
- CLI interface tetap kompatibel

## Future Improvements

1. **Add more file formats**: JSON, YAML, XML
2. **Plugin system**: Allow custom data sources
3. **Validation rules**: Configurable validation
4. **Templates**: Customizable code generation templates
5. **Caching**: Cache parsed results for better performance

---

**Note**: Refactoring ini berhasil dilakukan tanpa breaking changes pada public API, sehingga existing users tidak perlu mengubah kode mereka.
