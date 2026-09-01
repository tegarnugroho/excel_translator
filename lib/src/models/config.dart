/// Configuration for Excel Translator
class ExcelTranslatorConfig {
  final String? excelFilePath;
  final List<String>? files;
  final String? outputDir;
  final String? className;
  final bool? includeFlutterDelegates;

  /// Whether to generate one file per sheet (true) or a single inline file (false).
  /// Defaults to true when null.
  final bool? multiFile;

  const ExcelTranslatorConfig({
    this.excelFilePath,
    this.files,
    this.outputDir,
    this.className,
    this.includeFlutterDelegates,
    this.multiFile,
  });

  /// Create a copy with modified fields
  ExcelTranslatorConfig copyWith({
    String? excelFilePath,
    List<String>? files,
    String? outputDir,
    String? className,
    bool? includeFlutterDelegates,
    bool? multiFile,
  }) {
    return ExcelTranslatorConfig(
      excelFilePath: excelFilePath ?? this.excelFilePath,
      files: files ?? this.files,
      outputDir: outputDir ?? this.outputDir,
      className: className ?? this.className,
      includeFlutterDelegates:
          includeFlutterDelegates ?? this.includeFlutterDelegates,
      multiFile: multiFile ?? this.multiFile,
    );
  }

  /// Merge this config with another, giving priority to the other
  ExcelTranslatorConfig mergeWith(ExcelTranslatorConfig? other) {
    if (other == null) return this;

    return ExcelTranslatorConfig(
      excelFilePath: other.excelFilePath ?? excelFilePath,
      files: other.files ?? files,
      outputDir: other.outputDir ?? outputDir,
      className: other.className ?? className,
      includeFlutterDelegates:
          other.includeFlutterDelegates ?? includeFlutterDelegates,
      multiFile: other.multiFile ?? multiFile,
    );
  }

  @override
  String toString() {
    return 'ExcelTranslatorConfig(excelFilePath: $excelFilePath, files: $files, outputDir: $outputDir, className: $className, includeFlutterDelegates: $includeFlutterDelegates, multiFile: $multiFile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExcelTranslatorConfig &&
        other.excelFilePath == excelFilePath &&
        _listEquals(other.files, files) &&
        other.outputDir == outputDir &&
        other.className == className &&
        other.includeFlutterDelegates == includeFlutterDelegates &&
        other.multiFile == multiFile;
  }

  @override
  int get hashCode {
    return Object.hash(
      excelFilePath,
      files == null ? null : Object.hashAll(files!),
      outputDir,
      className,
      includeFlutterDelegates,
      multiFile,
    );
  }

  static bool _listEquals(List<String>? first, List<String>? second) {
    if (identical(first, second)) return true;
    if (first == null || second == null || first.length != second.length) {
      return false;
    }
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }
}
