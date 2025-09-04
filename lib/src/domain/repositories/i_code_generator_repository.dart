import '../entities/entities.dart';

/// Repository contract for code generation
abstract class ICodeGeneratorRepository {
  /// Generate localization classes from sheets
  Future<void> generateLocalizationClasses({
    required List<LocalizationSheet> sheets,
    required String outputDir,
    required String className,
    bool includeFlutterDelegates = true,
  });

  /// Generate individual sheet class
  Future<void> generateSheetClass({
    required LocalizationSheet sheet,
    required String outputDir,
  });

  /// Generate main localization class
  Future<void> generateMainClass({
    required List<LocalizationSheet> sheets,
    required String outputDir,
    required String className,
    bool includeFlutterDelegates = true,
  });

  /// Generate BuildContext extension
  Future<void> generateBuildContextExtension({
    required String outputDir,
    required String className,
  });
}
