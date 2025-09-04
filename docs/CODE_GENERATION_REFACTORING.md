# Code Generation Refactoring Documentation

## Problem Statement

Generator code di `lib/src/generators/implementations/` tidak sesuai dengan Clean Architecture principles:

1. **Mixed Responsibilities**: Generator melakukan file I/O, business logic, dan formatting dalam satu class
2. **Wrong Layer**: Code generation seharusnya di Data Layer, bukan sebagai separate generator layer
3. **Tight Coupling**: Generator langsung menggunakan domain entities tanpa proper abstraction
4. **Violates SOLID**: Single Responsibility Principle dilanggar

## Solution: Move to Data Sources

### Before (❌ Violates Clean Architecture)
```
lib/src/generators/implementations/
├── sheet_class_generator.dart      # File I/O + Business Logic
├── main_class_generator.dart       # File I/O + Business Logic  
└── extension_generator.dart        # File I/O + Business Logic
```

### After (✅ Clean Architecture Compliant)
```
lib/src/data/sources/
├── sheet_code_data_source.dart     # Data Layer - File generation
├── main_code_data_source.dart      # Data Layer - File generation
└── extension_code_data_source.dart # Data Layer - File generation
```

## Implementation Details

### 1. **SheetCodeDataSource**
- **Location**: `lib/src/data/sources/sheet_code_data_source.dart`
- **Responsibility**: Generate individual sheet localization classes
- **Input**: `LocalizationSheet` domain entity
- **Output**: Dart class file with type-safe translation methods

### 2. **MainCodeDataSource**  
- **Location**: `lib/src/data/sources/main_code_data_source.dart`
- **Responsibility**: Generate main localization class with Flutter delegates
- **Input**: List of `LocalizationSheet` entities + configuration
- **Output**: Main app localization class with static methods

### 3. **ExtensionCodeDataSource**
- **Location**: `lib/src/data/sources/extension_code_data_source.dart` 
- **Responsibility**: Generate BuildContext extension for easy access
- **Input**: Class name and output directory
- **Output**: Optional BuildContext extension (commented out by default)

### 4. **Updated Repository Implementation**
```dart
class CodeGeneratorRepositoryImpl implements ICodeGeneratorRepository {
  final MainCodeDataSource _mainCodeDataSource;
  final SheetCodeDataSource _sheetCodeDataSource;
  final ExtensionCodeDataSource _extensionCodeDataSource;
  
  // Uses dependency injection for data sources
  // Follows Repository pattern correctly
}
```

## Clean Architecture Benefits

### ✅ **Proper Layer Separation**
- **Domain Layer**: Pure business entities (`LocalizationSheet`, `Translation`)
- **Data Layer**: File generation data sources (implementation details)
- **Repository**: Contracts for code generation without knowing implementation

### ✅ **Single Responsibility**
- Each data source has ONE job: generate specific type of file
- Repository coordinates data sources but doesn't do file I/O
- Clear separation between what to generate vs how to generate

### ✅ **Dependency Inversion**
- High-level repository depends on abstractions (data sources)
- Data sources can be easily mocked for testing
- Implementation can be swapped without changing business logic

### ✅ **Testability**
- Data sources can be unit tested independently
- Repository can be tested with mocked data sources
- Domain entities remain pure and easily testable

## Migration Impact

### ✅ **No Breaking Changes**
- Public API remains exactly the same
- Generated code format unchanged
- CLI interface still works identically
- All existing tests still pass (54/54)

### ✅ **Better Architecture**
- Code generation is now properly in Data Layer
- Follows Clean Architecture principles
- Easier to extend with new file formats
- Better separation of concerns

### ✅ **Legacy Cleanup**
- Removed `lib/src/generators/implementations/` folder
- Eliminated duplicate generator code
- Cleaner project structure

## Future Benefits

1. **Extensibility**: Easy to add new code generation formats (JSON, YAML, etc.)
2. **Testability**: Each data source can be tested in isolation
3. **Maintainability**: Clear boundaries between layers
4. **Flexibility**: Data sources can be composed differently for different use cases

---

**Result**: Code generation is now properly architected according to Clean Architecture principles while maintaining 100% backward compatibility.
