/// Configuration for Excel Translator
class ExcelTranslatorConfig {
  final String? excelFilePath;
  final String? outputDir;
  final String? className;
  final bool? includeFlutterDelegates;

  /// Whether to generate one file per sheet (true) or a single inline file (false).
  /// Defaults to true when null.
  final bool? multiFile;

  const ExcelTranslatorConfig({
    this.excelFilePath,
    this.outputDir,
    this.className,
    this.includeFlutterDelegates,
    this.multiFile,
  });

  /// Create a copy with modified fields
  ExcelTranslatorConfig copyWith({
    String? excelFilePath,
    String? outputDir,
    String? className,
    bool? includeFlutterDelegates,
    bool? multiFile,
  }) {
    return ExcelTranslatorConfig(
      excelFilePath: excelFilePath ?? this.excelFilePath,
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
      outputDir: other.outputDir ?? outputDir,
      className: other.className ?? className,
      includeFlutterDelegates:
          other.includeFlutterDelegates ?? includeFlutterDelegates,
      multiFile: other.multiFile ?? multiFile,
    );
  }

  @override
  String toString() {
    return 'ExcelTranslatorConfig(excelFilePath: $excelFilePath, outputDir: $outputDir, className: $className, includeFlutterDelegates: $includeFlutterDelegates, multiFile: $multiFile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExcelTranslatorConfig &&
        other.excelFilePath == excelFilePath &&
        other.outputDir == outputDir &&
        other.className == className &&
        other.includeFlutterDelegates == includeFlutterDelegates &&
        other.multiFile == multiFile;
  }

  @override
  int get hashCode {
    return excelFilePath.hashCode ^
        outputDir.hashCode ^
        className.hashCode ^
        includeFlutterDelegates.hashCode ^
        multiFile.hashCode;
  }
}
