// Implementation of file parser repository
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../sources/sources.dart';

/// Implementation of file parser repository
class FileParserRepositoryImpl implements IFileParserRepository {
  const FileParserRepositoryImpl();

  @override
  Future<List<LocalizationSheet>> parseFile(String filePath) async {
    final dataSource = FileDataSourceFactory.createDataSource(filePath);
    return await dataSource.parseFile(filePath);
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
