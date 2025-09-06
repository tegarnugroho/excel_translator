// Implementation of code generator repository
import 'dart:io';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../sources/main_code_data_source.dart';
import '../sources/sheet_code_data_source.dart';
import '../sources/extension_code_data_source.dart';

/// Implementation of code generator repository using data sources
class CodeGeneratorRepositoryImpl implements ICodeGeneratorRepository {
  final MainCodeDataSource _mainCodeDataSource;
  final SheetCodeDataSource _sheetCodeDataSource;
  final ExtensionCodeDataSource _extensionCodeDataSource;

  CodeGeneratorRepositoryImpl({
    MainCodeDataSource? mainCodeDataSource,
    SheetCodeDataSource? sheetCodeDataSource,
    ExtensionCodeDataSource? extensionCodeDataSource,
  })  : _mainCodeDataSource = mainCodeDataSource ?? MainCodeDataSource(),
        _sheetCodeDataSource = sheetCodeDataSource ?? SheetCodeDataSource(),
        _extensionCodeDataSource =
            extensionCodeDataSource ?? ExtensionCodeDataSource();
  @override
  Future<void> generateLocalizationClasses({
    required List<LocalizationSheet> sheets,
    required String outputDir,
    required String className,
    bool includeFlutterDelegates = true,
  }) async {
    // Create output directory if it doesn't exist
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    // Generate all classes using data sources
    await Future.wait([
      _mainCodeDataSource.generateMainClass(
        sheets,
        outputDir,
        className,
        includeFlutterDelegates,
      ),
      _extensionCodeDataSource.generateBuildContextExtension(
        outputDir,
        className,
      ),
      ...sheets.map((sheet) => _sheetCodeDataSource.generateSheetClass(
            sheet,
            outputDir,
          )),
    ]);
  }

  @override
  Future<void> generateSheetClass({
    required LocalizationSheet sheet,
    required String outputDir,
  }) async {
    await _sheetCodeDataSource.generateSheetClass(sheet, outputDir);
  }

  @override
  Future<void> generateMainClass({
    required List<LocalizationSheet> sheets,
    required String outputDir,
    required String className,
    bool includeFlutterDelegates = true,
  }) async {
    await _mainCodeDataSource.generateMainClass(
      sheets,
      outputDir,
      className,
      includeFlutterDelegates,
    );
  }

  @override
  Future<void> generateBuildContextExtension({
    required String outputDir,
    required String className,
  }) async {
    await _extensionCodeDataSource.generateBuildContextExtension(
      outputDir,
      className,
    );
  }
}
