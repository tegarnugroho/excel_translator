import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Use case for generating localization classes
class GenerateLocalizationClassesUseCase {
  final ICodeGeneratorRepository _codeGeneratorRepository;

  const GenerateLocalizationClassesUseCase(this._codeGeneratorRepository);

  /// Execute the use case
  Future<void> execute({
    required List<LocalizationSheet> sheets,
    required String outputDir,
    required String className,
    bool includeFlutterDelegates = true,
  }) async {
    await _codeGeneratorRepository.generateLocalizationClasses(
      sheets: sheets,
      outputDir: outputDir,
      className: className,
      includeFlutterDelegates: includeFlutterDelegates,
    );
  }
}
