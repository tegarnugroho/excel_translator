// Implementation of file parser repository
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../../core/core.dart';
import '../sources/sources.dart';

/// Implementation of file parser repository
class FileParserRepositoryImpl implements IFileParserRepository {
  final LanguageValidationService? _languageValidationService;

  const FileParserRepositoryImpl({
    LanguageValidationService? languageValidationService,
  }) : _languageValidationService = languageValidationService;

  @override
  Future<List<LocalizationSheet>> parseFile(String filePath) async {
    final dataSource = FileDataSourceFactory.createDataSource(filePath);
    return await dataSource.parseFile(filePath, languageValidator: _languageValidationService);
  }

  @override
  bool isFormatSupported(String filePath) {
    return FileDataSourceFactory.isSupportedFormat(filePath);
  }

  @override
  List<String> get supportedExtensions {
    return FileDataSourceFactory.supportedExtensions;
  }
}
