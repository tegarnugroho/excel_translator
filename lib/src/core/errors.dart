// Core errors for Excel Translator

/// Base exception class for Excel Translator
abstract class ExcelTranslatorException implements Exception {
  final String message;
  final dynamic cause;

  const ExcelTranslatorException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'ExcelTranslatorException: $message\nCause: $cause';
    }
    return 'ExcelTranslatorException: $message';
  }
}

/// Exception thrown when file parsing fails
class FileParsingException extends ExcelTranslatorException {
  const FileParsingException(String message, [dynamic cause]) : super(message, cause);
}

/// Exception thrown when language validation fails
class LanguageValidationException extends ExcelTranslatorException {
  const LanguageValidationException(String message, [dynamic cause]) : super(message, cause);
}

/// Exception thrown when code generation fails
class CodeGenerationException extends ExcelTranslatorException {
  const CodeGenerationException(String message, [dynamic cause]) : super(message, cause);
}

/// Exception thrown when file format is not supported
class UnsupportedFileFormatException extends ExcelTranslatorException {
  final String filePath;
  final List<String> supportedFormats;

  UnsupportedFileFormatException(
    this.filePath,
    this.supportedFormats,
  ) : super('Unsupported file format for: $filePath. Supported formats: ${supportedFormats.join(', ')}');
}

/// Exception thrown when file is not found
class FileNotFoundException extends ExcelTranslatorException {
  final String filePath;

  FileNotFoundException(this.filePath) : super('File not found: $filePath');
}
