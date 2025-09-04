import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Use case for parsing localization files
class ParseLocalizationFileUseCase {
  final IFileParserRepository _fileParserRepository;

  const ParseLocalizationFileUseCase(this._fileParserRepository);

  /// Execute the use case
  Future<List<LocalizationSheet>> execute(String filePath) async {
    if (!_fileParserRepository.isFormatSupported(filePath)) {
      throw UnsupportedError(
        'Unsupported file format. Supported formats: ${_fileParserRepository.supportedExtensions.join(', ')}'
      );
    }

    return await _fileParserRepository.parseFile(filePath);
  }
}
