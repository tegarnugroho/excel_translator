// Implementation of code generator repository
import 'dart:io';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../generators/implementations/implementations.dart';
import '../models/entity_model_mapper.dart';

/// Implementation of code generator repository
class CodeGeneratorRepositoryImpl implements ICodeGeneratorRepository {
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

    // Generate all classes
    await Future.wait([
      generateMainClass(
        sheets: sheets,
        outputDir: outputDir,
        className: className,
        includeFlutterDelegates: includeFlutterDelegates,
      ),
      generateBuildContextExtension(
        outputDir: outputDir,
        className: className,
      ),
      ...sheets.map((sheet) => generateSheetClass(
        sheet: sheet,
        outputDir: outputDir,
      )),
    ]);
  }

  @override
  Future<void> generateSheetClass({
    required LocalizationSheet sheet,
    required String outputDir,
  }) async {
    final oldModelSheet = EntityModelMapper.toOldModel(sheet);
    await SheetClassGenerator.generate(oldModelSheet, outputDir);
  }

  @override
  Future<void> generateMainClass({
    required List<LocalizationSheet> sheets,
    required String outputDir,
    required String className,
    bool includeFlutterDelegates = true,
  }) async {
    final oldModelSheets = EntityModelMapper.toOldModels(sheets);
    await MainClassGenerator.generate(
      oldModelSheets,
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
    final emptySheets = <dynamic>[]; // Empty list as ExtensionGenerator doesn't actually use sheets
    await ExtensionGenerator.generate(emptySheets.cast(), outputDir, className);
  }
}
